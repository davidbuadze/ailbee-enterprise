# backend/api/chat.py
# Роутер FastAPI для ведения диалога с умным междисциплинарным Агентом

import os
import uuid
import httpx
import asyncio

from fastapi import APIRouter, Depends, HTTPException, Header, status
from pydantic import BaseModel, Field
from typing import Optional, List

from services.firebase import FirebaseService
from services.vertex_agent import VertexAgentService
from config import settings

router = APIRouter()
firebase_service = FirebaseService()
vertex_service = VertexAgentService()

# Обязательная системная инструкция для удержания грузинского языка
GEORGIAN_SYSTEM_INSTRUCTION = (
    "You are an educational AI tutor for Georgian schools. "
    "Always think and respond fluently in Georgian language (ქართული ენა). "
    "Maintain high pedagogical tone and accurate grammar.\n\n"
)

class ChatRequest(BaseModel):
    prompt: str = Field(..., description="მოთხოვნა AI-აგენტის მიმართ")
    # Доступные агенты: gemini-online, gemma-offline-mobile, gemma-dedicated-server, gemma-vertex-gpu, gemma-cloudrun
    agent_id: str = Field(default="gemini-online", description="აგენტის ID GCP-ში")
    conversation_id: Optional[str] = Field(None, description="მიმდინარე დიალოგის სესიის ID")

class ChatResponse(BaseModel):
    reply: str = Field(..., description="AI-აგენტის პასუხი")
    conversation_id: str = Field(..., description="სესიის ID")
    execution_mode: str = Field("cloud", description="მოთხოვნა შეასრულა: cloud | offline_device | dedicated_server")
    offline_token: Optional[str] = Field(None, description="Token სმარტფონში G-ჩასატვირთად")
    subjects_involved: List[str] = Field(default_factory=list, description="გამოყენებული მეცნიერებები")

async def get_optional_user(authorization: Optional[str] = Header(None)) -> Optional[str]:
    if not authorization or not authorization.startswith("Bearer "):
        return None
    try:
        return await firebase_service.verify_firebase_token(authorization)
    except Exception:
        return None

async def verify_premium_user(user_uid: Optional[str]) -> bool:
    if not user_uid:
        return False
    user_doc = await firebase_service.get_user_profile(user_uid)
    return user_doc.get("is_premium", False) if user_doc else False

@router.post("/converse", response_model=ChatResponse, summary="საგანთაშორისი შემოქმედებითი საუბარი")
async def converse_endpoint(
    request: ChatRequest,
    user_uid: Optional[str] = Depends(get_optional_user)
):
    try:
        incoming_id = request.agent_id.strip() if request.agent_id else "gemini-online"
        trace_id = str(uuid.uuid4())
        
        # Глобальная инициализация ID сессии для всех сценариев
        conversation_id = request.conversation_id or str(uuid.uuid4())

        # =========================================================================
        # СЦЕНАРИЙ 1: Premium Offline Mobile (Edge AI)
        # Описание: Пользователь качает Gemma 2B на смартфон. Бэкенд только дает доступ.
        # =========================================================================
        if incoming_id == "gemma-offline-mobile":
            is_premium = await verify_premium_user(user_uid)
            if not is_premium:
                raise HTTPException(status_code=403, detail="Оффлайн-репетитор доступен только в Premium.")
            
            return ChatResponse(
                reply="[SYSTEM] Разрешение получено. Переключаю на локальный инференс устройства.",
                conversation_id=conversation_id,
                execution_mode="offline_device",
                offline_token=f"auth_{uuid.uuid4().hex}"
            )

        # =========================================================================
        # СЦЕНАРИЙ 2: ЗАГЛУШКА - Выделенный сервер (Hetzner / On-Premise)
        # Описание: Будущая реализация запросов к собственной мощной RTX-станции с Gemma 27B.
        # =========================================================================
        elif incoming_id == "gemma-dedicated-server":
            is_premium = await verify_premium_user(user_uid)
            if not is_premium:
                raise HTTPException(status_code=403, detail="Выделенный сервер доступен только в Premium.")
            
            # TODO: HTTP-запрос к API вашего железного сервера
            return ChatResponse(
                reply="🌟 [ЗАГЛУШКА] Ваш запрос будет обработан на приватном сервере Hetzner (Gemma 27B). Эта функция скоро появится!",
                conversation_id=conversation_id,
                execution_mode="dedicated_server",
                subjects_involved=["Инфраструктура Premium"]
            )

        # =========================================================================
        # СЦЕНАРИЙ 3: ЗАГЛУШКА - Vertex AI GPU Endpoint
        # Описание: Оставлено на случай, если проект получит грант и вернется к Google GPU.
        # =========================================================================
        elif incoming_id == "gemma-vertex-gpu":
            if user_uid:
                await firebase_service.log_audit_event(user_uid, "PREMIUM_GEMMA_GPU_REQUEST", {"trace_id": trace_id})
            return ChatResponse(
                reply="🌟 [ЗАГЛУШКА] Доступ к выделенным GPU Vertex AI временно отключен в целях оптимизации.",
                conversation_id=conversation_id,
                execution_mode="cloud"
            )

        # =========================================================================
        # СЦЕНАРИЙ 4: ЗАГЛУШКА - Cloud Run + Ollama
        # Описание: Резервный эконом-вариант запуска легкой Gemma 2B в Google Cloud.
        # =========================================================================
        elif incoming_id == "gemma-cloudrun":
            gemma_url = settings.GEMMA_SERVER_URL.strip() if hasattr(settings, 'GEMMA_SERVER_URL') else ""
            if not gemma_url:
                raise HTTPException(status_code=500, detail="GEMMA_SERVER_URL не настроен.")

            user_memory = await firebase_service.get_mem0_memory(user_uid) if user_uid else "Гостевой сеанс"
            
            # ВАЖНО: Добавляем грузинскую инструкцию
            prompt_payload = f"{GEORGIAN_SYSTEM_INSTRUCTION}Контекст ученика: {user_memory}\nЗапрос: {request.prompt}"

            async with httpx.AsyncClient(timeout=90.0) as client:
                try:
                    response = await client.post(
                        f"{gemma_url}/api/generate",
                        json={"model": "gemma2:2b", "prompt": prompt_payload, "stream": False}
                    )
                    response.raise_for_status()
                    reply_text = response.json().get("response", "Сбой Ollama.")
                except Exception as e:
                    raise HTTPException(status_code=502, detail=f"Ошибка соединения с Gemma Cloud Run: {str(e)}")

            if user_uid:
                await firebase_service.log_audit_event(user_uid, "CONVERSE_GEMMA_CLOUDRUN", {"trace_id": trace_id})

            return ChatResponse(
                reply=reply_text,
                conversation_id=conversation_id,
                execution_mode="cloud",
                subjects_involved=["Автономный синтез"]
            )

        # =========================================================================
        # СЦЕНАРИЙ 5 (ОСНОВНОЙ): Умный RAG-поиск Vertex AI / Gemini Online
        # Описание: Дешевый, быстрый и основной движок платформы с оплатой за токены.
        # =========================================================================
        else:
            engine_id = os.getenv("AGENT_ID", "gemini-enterprise-research_1779706550201")

            # Контекст формируется с учетом авторизации и ГРУЗИНСКОГО ЯЗЫКА
            if user_uid:
                user_memory = await firebase_service.get_mem0_memory(user_uid)
                prompt_with_memory = f"{GEORGIAN_SYSTEM_INSTRUCTION}Долгосрочный профиль: {user_memory}\nВопрос: {request.prompt}"
            else:
                prompt_with_memory = f"{GEORGIAN_SYSTEM_INSTRUCTION}Обучающий вопрос гостя: {request.prompt}"

            # Запрос к Gemini Enterprise / Vertex AI Search
            reply_text, next_conv_id, citations = await asyncio.to_thread(
                vertex_service.converse_with_gemini_enterprise,
                query=prompt_with_memory,
                engine_id=engine_id,
                conversation_id=request.conversation_id # Здесь передаем изначальный
            )

            # Анализ задействованных наук (Ищем грузинские корни слов!)
            subjects = ["General Science"] # Естествознание
            lower_reply = reply_text.lower()
            if "ფიზიკა" in lower_reply: subjects.append("Physics")
            if "ბიოლოგია" in lower_reply or "უჯრედი" in lower_reply: subjects.append("Biology")
            if "ქიმია" in lower_reply: subjects.append("Chemistry")
            if "ენერგია" in lower_reply: subjects.append("Thermodynamics")

            # Обновление памяти Mem0 и логов
            if user_uid:
                for sub in subjects:
                    if sub != "General Science" and sub not in user_memory:
                        await firebase_service.update_mem0_memory(user_uid, f"Studied subject: {sub}")

                await firebase_service.log_audit_event(user_uid, "CONVERSE_GEMINI_ONLINE", {
                    "trace_id": trace_id,
                    "subjects": subjects,
                    "citations_count": len(citations)
                })

            return ChatResponse(
                reply=reply_text,
                conversation_id=next_conv_id or conversation_id,
                execution_mode="cloud",
                subjects_involved=list(set(subjects))
            )

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"ბექენდის შინაგანი შეცდომა: {str(e)}")
