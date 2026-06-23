# backend/api/chat.py
# Роутер FastAPI для ведения диалога с умным междисциплинарным Агентом

import os
import uuid
import httpx
import asyncio
from fastapi import APIRouter, Depends, HTTPException, Header
from pydantic import BaseModel, Field
from typing import Optional, List, Dict, Any

# Импорт сервисов из папки services/ и конфигурации из корня
from services.firebase import FirebaseService
from services.vertex_agent import VertexAgentService
from config import settings

router = APIRouter()
firebase_service = FirebaseService()
vertex_service = VertexAgentService()

class ChatRequest(BaseModel):
    prompt: str = Field(..., description="Промпт для ИИ-Агента")
    agent_id: str = Field(..., description="ID Агента в GCP")
    conversation_id: Optional[str] = Field(None, description="ID текущей сессии диалога")

class ChatResponse(BaseModel):
    reply: str = Field(..., description="Ответ ИИ-Агента")
    conversation_id: str = Field(..., description="ID сессии")
    subjects_involved: List[str] = Field(default_factory=list, description="Задействованные науки")

async def get_current_user(authorization: str = Header(None)) -> str:
    """Зависимость для строгой проверки токена (RULE 3 - Auth Before Queries)"""
    try:
        return await firebase_service.verify_firebase_token(authorization)
    except ValueError as e:
        raise HTTPException(status_code=401, detail=str(e))

@router.post("/converse", response_model=ChatResponse, summary="Междисциплинарный творческий чат")
async def converse_endpoint(
    request: ChatRequest,
    user_uid: str = Depends(get_current_user)
):
    try:
        incoming_id = request.agent_id.strip() if request.agent_id else ""
        trace_id = str(uuid.uuid4())

        # Читаем долгосрочную память Mem0 (Пункт 1 Карты Ailbee)
        user_memory = await firebase_service.get_mem0_memory(user_uid)

        # СЦЕНАРИЙ А: Gemma 4 на выделенной GPU Vertex AI (Премиум)
        if incoming_id == "gemma-4-vertex-gpu":
            await firebase_service.log_audit_event(user_uid, "PREMIUM_GEMMA_GPU_REQUEST", {"trace_id": trace_id})
            return ChatResponse(
                reply="🌟 Премиум-доступ с максимальной скоростью Gemma 4 на выделенных GPU появится совсем скоро! Оформить предзаказ можно в профиле.",
                conversation_id=request.conversation_id or "preview_gpu_session",
                subjects_involved=["Инфраструктура GPU"]
            )

        # СЦЕНАРИЙ Б: Локальный WebGPU режим (Edge Исполнение)
        elif incoming_id == "gemma-4-local":
            await firebase_service.log_audit_event(user_uid, "LOCAL_WEBGPU_REQUEST", {"trace_id": trace_id})
            return ChatResponse(
                reply="Система переведена в локальный режим. Вычисления происходят на вашем устройстве через WebGPU.",
                conversation_id=request.conversation_id or "local_session",
                subjects_involved=["Локальный WebGPU"]
            )

        # СЦЕНАРИЙ В: Gemma 4 на Cloud Run через Ollama API
        elif incoming_id == "gemma-4-cloudrun":
            gemma_url = settings.GEMMA_SERVER_URL.strip()
            if not gemma_url:
                raise HTTPException(status_code=500, detail="GEMMA_SERVER_URL не настроен.")

            async with httpx.AsyncClient(timeout=90.0) as client:
                try:
                    response = await client.post(
                        f"{gemma_url}/api/generate",
                        json={
                            "model": "gemma2:2b",
                            "prompt": f"Контекст ученика: {user_memory}\nЗапрос: {request.prompt}",
                            "stream": False
                        }
                    )
                    response.raise_for_status()
                    ollama_data = response.json()
                    reply_text = ollama_data.get("response", "Сбой: Gemma вернула пустой ответ.")
                except Exception as e:
                    raise HTTPException(status_code=502, detail=f"Ошибка соединения с Gemma Server: {str(e)}")

            await firebase_service.log_audit_event(user_uid, "CONVERSE_GEMMA_CLOUDRUN", {"trace_id": trace_id})
            return ChatResponse(
                reply=reply_text,
                conversation_id=request.conversation_id or "gemma_cloud_session",
                subjects_involved=["Автономный синтез"]
            )

        # СЦЕНАРИЙ Г (Основной): Умный академический RAG-поиск в Vertex AI
        else:
            engine_id = os.getenv("AGENT_ID", "gemini-enterprise-research_1779706550201") if incoming_id in ["", "null", "agent_id"] else incoming_id

            # Формируем комплексный системный промпт с учетом памяти Mem0
            prompt_with_memory = f"Долгосрочный профиль знаний ученика: {user_memory}\nВопрос: {request.prompt}"

            reply_text, next_conv_id, citations = await asyncio.to_thread(
                vertex_service.converse_with_gemini_enterprise,
                query=prompt_with_memory,
                engine_id=engine_id,
                conversation_id=request.conversation_id
            )

            # Анализ задействованных предметных областей в ответе
            subjects = ["Естествознание"]
            lower_reply = reply_text.lower()
            if "физик" in lower_reply: subjects.append("Физика")
            if "биолог" in lower_reply or "клетк" in lower_reply: subjects.append("Биология")
            if "хими" in lower_reply or "атф" in lower_reply: subjects.append("Химия")
            if "энерги" in lower_reply: subjects.append("Термодинамика")

            # Записываем новые факты в Mem0 при их обнаружении
            for sub in subjects:
                if sub != "Естествознание" and sub not in user_memory:
                    await firebase_service.update_mem0_memory(user_uid, f"Изучил раздел {sub}")

            await firebase_service.log_audit_event(user_uid, "CONVERSE_GEMINI_ENTERPRISE", {
                "trace_id": trace_id,
                "subjects": subjects,
                "citations_count": len(citations)
            })

            return ChatResponse(
                reply=reply_text,
                conversation_id=next_conv_id,
                subjects_involved=list(set(subjects))
            )

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Внутренняя ошибка бэкенда: {str(e)}")
        