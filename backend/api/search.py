# backend/api/search.py
# Роутер FastAPI для работы с поисковыми RAG-запросами и загрузки/парсинга документов на лету

import os
import io
import uuid
import asyncio
from fastapi import APIRouter, Depends, HTTPException, Header, UploadFile, File
from pydantic import BaseModel, Field
from typing import Optional, List, Dict, Any

from google.cloud import storage, firestore
from services.firebase import FirebaseService
from config import settings

# Документ-парсеры
from pypdf import PdfReader
from docx import Document

router = APIRouter()
firebase_service = FirebaseService()

# Локальная заглушка векторной базы данных для in-memory RAG
MOCKED_VECTOR_DB: Dict[str, Dict[str, Any]] = {}
MOCKED_DOC_CHUNKS_MAP: Dict[str, List[str]] = {}

class SearchRequest(BaseModel):
    query: str = Field(..., description="Поисковый запрос")
    document_ids: Optional[List[str]] = Field(None, description="Список документов для точечного RAG")

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

@router.post("/document-upload", summary="Загрузка и индексация книги VASC (RULE 1)")
async def upload_document_endpoint(
    file: UploadFile = File(...),
    user_uid: str = Depends(get_current_user)
):
    try:
        doc_id = str(uuid.uuid4())
        filename = file.filename
        file_content = await file.read()

        # 1. Загрузка в Cloud Storage
        storage_client = storage.Client(project=settings.GCP_PROJECT_ID)
        bucket = storage_client.bucket(settings.GCS_BUCKET_NAME)
        blob_path = f"user_documents/{user_uid}/{doc_id}/{filename}"
        blob = bucket.blob(blob_path)
        
        # Переносим блокирующую загрузку в пул потоков
        await asyncio.to_thread(blob.upload_from_string, file_content, content_type=file.content_type)
        gcs_url = f"https://storage.googleapis.com/{settings.GCS_BUCKET_NAME}/{blob_path}"

        # 2. Быстрый парсинг и индексация во временную векторную БД
        text = await extract_text(file_content, filename)
        chunks = [text[i:i + 1000] for i in range(0, len(text), 900)] # чанки по 1000 символов с перекрытием 100
        
        MOCKED_DOC_CHUNKS_MAP[doc_id] = []
        for i, chunk in enumerate(chunks):
            chunk_id = f"{doc_id}_chunk_{i}"
            MOCKED_VECTOR_DB[chunk_id] = {"text": chunk}
            MOCKED_DOC_CHUNKS_MAP[doc_id].append(chunk_id)

        # 3. Сохранение метаданных в Firestore СТРОГО по RULE 1
        doc_metadata = {
            "id": doc_id,
            "title": filename,
            "user_id": user_uid,
            "gcs_path": blob_path,
            "gcs_url": gcs_url,
            "uploaded_at": firestore.SERVER_TIMESTAMP,
            "vasc_indexing_status": "SUCCESS"
        }
        doc_ref = firebase_service.get_private_doc_ref(user_uid, "documents", doc_id)
        await asyncio.to_thread(doc_ref.set, doc_metadata)
        
        await firebase_service.log_audit_event(user_uid, "UPLOAD_DOCUMENT_SUCCESS", {"doc_id": doc_id, "title": filename})
        return {"status": "success", "doc_id": doc_id, "title": filename, "gcs_url": gcs_url}

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Ошибка обработки документа: {str(e)}")
        