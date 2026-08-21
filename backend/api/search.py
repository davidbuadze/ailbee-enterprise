# backend/api/search.py
# Роутер FastAPI для Школьного модуля (Gemma/RAG) и загрузки учебных документов

import os
import io
import json
import uuid
import httpx
import asyncio
from fastapi import APIRouter, Depends, HTTPException, Header, UploadFile, File
from pydantic import BaseModel, Field
from typing import Optional, List, Dict, Any

from google.cloud import storage, firestore
from services.firebase import FirebaseService
from services.vertex_agent import VertexAgentService
from config import settings

# Документ-парсеры
from pypdf import PdfReader
from docx import Document

router = APIRouter()
firebase_service = FirebaseService()
vertex_service = VertexAgentService()

# --- МОДЕЛИ ДАННЫХ ШКОЛЬНОГО МОДУЛЯ ---

class SearchConverseRequest(BaseModel):
    query: str = Field(..., description="მოსწავლის სასწავლო/საძიებელი მოთხოვნა")
    agent_id: Optional[str] = Field("school_public_agent", description="აგენტის ID GCP-ში")
    conversation_id: Optional[str] = Field(None, description="მიმდინარე დიალოგის სესიის ID")
    book_context: Optional[str] = Field("none", description="არჩეული სახელმძღვანელოს/პარაგრაფის კონტექსტი")

class SearchConverseResponse(BaseModel):
    reply: Dict[str, Any] = Field(..., description="სტრუქტურირებული GenUI პასუხი (JSON)")
    conversation_id: str = Field(..., description="სესიის ID")
    citations: List[str] = Field(default_factory=list, description="ბმული სახელმძღვანელოს გვერდზე")

async def get_current_user(authorization: str = Header(None)) -> str:
    """Зависимость для проверки токена (RULE 3)"""
    try:
        return await firebase_service.verify_firebase_token(authorization)
    except ValueError as e:
        raise HTTPException(status_code=401, detail=str(e))

async def extract_text(file_content: bytes, filename: str) -> str:
    """Парсинг текстового слоя документов на лету"""
    try:
        if filename.lower().endswith(".pdf"):
            reader = PdfReader(io.BytesIO(file_content))
            return "".join([page.extract_text() for page in reader.pages if page.extract_text()])
        elif filename.lower().endswith((".doc", ".docx")):
            doc = Document(io.BytesIO(file_content))
            return "\n".join([para.text for para in doc.paragraphs])
        return file_content.decode('utf-8', errors='ignore')
    except Exception as e:
        raise ValueError(f"Не удалось извлечь текст: {str(e)}")

def parse_llm_json_response(raw_text: str) -> Dict[str, Any]:
    """Вспомогательная функция для безопасного извлечения JSON из ответа LLM"""
    try:
        # Очистка от возможных markdown-тегов ```json ... ```
        clean_text = raw_text.strip()
        if clean_text.startswith("```json"):
            clean_text = clean_text[7:]
        if clean_text.startswith("```"):
            clean_text = clean_text[3:]
        if clean_text.endswith("```"):
            clean_text = clean_text[:-3]
        
        return json.loads(clean_text.strip())
    except Exception:
        # Резервный фоллбек, если LLM выдала нестрогий JSON
        return {
            "quote": "📜 «სწავლება განუსჯელად უსარგებლოა და მსჯელობა უსწავლელად საშიშია» — კონფუცი",
            "base_answer": raw_text[:250],
            "ai_explanation": "🔬 ძირითადი კანონების შესწავლა გვეხმარება თანამედროვე (21-საუკუნის) ტექნოლოგიების აგებულების გაგებაში",
            "question": "❓ გსურს ამ თემის მეტად გაგება?",
            "suggested_chips": ["💡 მეტად გაგება", "🔍 მაგალითები რეალური ცხოვრებიდან"]
        }

# --- 1. ЭНДПОИНТ ШКОЛЬНОГО МОДУЛЯ (CONVERSE) ---

# Реальный Engine ID из GCP Vertex AI Search
DEFAULT_ENGINE_ID = os.getenv("AGENT_ID", "ailbee-enterprise-knowledg_1779121464248")

@router.post("/converse", response_model=SearchConverseResponse, summary="სასკოლი კვლევითი მოდული (Gemma/Vertex)")
async def school_search_converse_endpoint(
    request: SearchConverseRequest,
    user_uid: str = Depends(get_current_user)
):
    try:
        trace_id = str(uuid.uuid4())
        agent_id = request.agent_id or "school_public_agent"
        book_ctx = request.book_context or "none"
        gemma_url = getattr(settings, "GEMMA_SERVER_URL", "").strip()

        raw_reply = ""
        citations = []
        session_id = request.conversation_id or f"school_{uuid.uuid4().hex[:8]}"

        # СЦЕНАРИЙ А: Приоритетная бесплатная обработка через Gemma Service (Ollama / Cloud Run)
        if gemma_url and agent_id == "gemma-service":
            system_prompt = f"Контекст учебника: {book_ctx}\nЗапрос ученика: {request.query}\nშეადგინე პასუხი მკაცრად JSON ფორმატის ველებით: quote, base_answer, ai_explanation, question, suggested_chips."
            
            async with httpx.AsyncClient(timeout=60.0) as client:
                try:
                    response = await client.post(
                        f"{gemma_url}/api/generate",
                        json={
                            "model": "gemma2:2b",
                            "prompt": system_prompt,
                            "stream": False
                        }
                    )
                    if response.status_code == 200:
                        raw_reply = response.json().get("response", "")
                except Exception:
                    pass # Gemma შეცდომისნ შემთხვევაში გადადი Vertex AI Gemini

        # СЦЕНАРИЙ Б (ძირითადი / სათადარიგო): Запрос к Vertex AI Gemini (სასკოლო უფასო აგენტი)
        if not raw_reply:
            # Автоматическая подстановка реального Engine ID при передаче псевдонимов
            engine_id = DEFAULT_ENGINE_ID if agent_id in ["", "null", "agent_id", "school_public_agent"] else agent_id
            query_with_context = f"სახელმძღვანელოს კონტექსტი (book_context): {book_ctx}\nმოთხოვნა (query): {request.query}"

            try:
                raw_reply, session_id, citations = await asyncio.to_thread(
                    vertex_service.converse_with_gemini_enterprise,
                    query=query_with_context,
                    engine_id=engine_id,
                    conversation_id=request.conversation_id
                )
            except Exception as vertex_err:
                err_text = str(vertex_err)
                # Перехват ошибки истечения лицензии Vertex AI (EXPIRED) -> переключение на Gemma
                if ("EXPIRED" in err_text or "license" in err_text or "400" in err_text) and gemma_url:
                    system_prompt = f"სახელმძღვანელოს კონტექსტი: {book_ctx}\nმოსწავლის მოთხოვნა: {request.query}\nშეადგინე პასუხი მკაცრად JSON ფორმატის ველებით: quote, base_answer, ai_explanation, question, suggested_chips."
                    try:
                        async with httpx.AsyncClient(timeout=60.0) as client:
                            gemma_response = await client.post(
                                f"{gemma_url}/api/generate",
                                json={
                                    "model": "gemma2:2b",
                                    "prompt": system_prompt,
                                    "stream": False
                                }
                            )
                            if gemma_response.status_code == 200:
                                raw_reply = gemma_response.json().get("response", "")
                    except Exception:
                        pass
                
                # Если переключиться на Gemma не удалось, возвращаем исходную ошибку
                if not raw_reply:
                    raise vertex_err

        # Парсим сгенерированный текст в структурированный GenUI-объект JSON
        parsed_json = parse_llm_json_response(raw_reply)

        await firebase_service.log_audit_event(user_uid, "SCHOOL_MODULE_SEARCH", {
            "trace_id": trace_id,
            "agent_id": agent_id,
            "engine_id": engine_id if 'engine_id' in locals() else "gemma-service",
            "book_context": book_ctx
        })

        return SearchConverseResponse(
            reply=parsed_json,
            conversation_id=session_id,
            citations=citations
        )

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"სასკოლო მოდულის შეცდომა: {str(e)}")

# --- 2. ЭНДПОИНТ ЗАГРУЗКИ УЧЕБНИКОВ И ДОКУМЕНТОВ ---

@router.post("/document-upload", summary="სახელმძღვანელოს, ან საკუთარი მასალის (საბუთის) ჩატვირთვა")
async def upload_document_endpoint(
    file: UploadFile = File(...),
    is_public_textbook: bool = False,
    user_uid: str = Depends(get_current_user)
):
    try:
        doc_id = str(uuid.uuid4())
        filename = file.filename
        file_content = await file.read()

        # 1. Определение пути хранения (Общедоступные учебники vs личные файлы)
        storage_client = storage.Client(project=settings.GCP_PROJECT_ID)
        bucket = storage_client.bucket(settings.GCS_BUCKET_NAME)
        
        if is_public_textbook:
            blob_path = f"school_textbooks/{doc_id}/{filename}"
        else:
            blob_path = f"user_documents/{user_uid}/{doc_id}/{filename}"
            
        blob = bucket.blob(blob_path)
        await asyncio.to_thread(blob.upload_from_string, file_content, content_type=file.content_type)
        gcs_url = f"[https://storage.googleapis.com/](https://storage.googleapis.com/){settings.GCS_BUCKET_NAME}/{blob_path}"

        # 2. Быстрый парсинг текста
        text = await extract_text(file_content, filename)

        # 3. Сохранение метаданных в Firestore
        doc_metadata = {
            "id": doc_id,
            "title": filename,
            "user_id": user_uid,
            "gcs_path": blob_path,
            "gcs_url": gcs_url,
            "is_public_textbook": is_public_textbook,
            "uploaded_at": firestore.SERVER_TIMESTAMP,
            "indexing_status": "SUCCESS"
        }
        
        doc_ref = firebase_service.get_private_doc_ref(user_uid, "documents", doc_id)
        await asyncio.to_thread(doc_ref.set, doc_metadata)
        
        await firebase_service.log_audit_event(user_uid, "UPLOAD_DOCUMENT_SUCCESS", {"doc_id": doc_id, "title": filename})
        return {"status": "success", "doc_id": doc_id, "title": filename, "gcs_url": gcs_url}

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"შეცდომა საბუთის დამუშავებისას: {str(e)}")
        