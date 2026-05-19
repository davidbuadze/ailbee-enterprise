# app/api/chat.py
from fastapi import APIRouter, Depends, HTTPException, Header
from pydantic import BaseModel, Field
from typing import Optional, List

# Импортируем наши сервисы и модели
from services.firebase import FirebaseService, AuthenticatedUser
from services.vertex_agent import VertexAgentService

# Инициализируем роутер (префикс будет задан в main.py)
router = APIRouter()

# Инициализируем сервисы (они создадутся один раз при старте сервера)
firebase_service = FirebaseService()
vertex_agent_service = VertexAgentService()

# --- 1. Pydantic-схемы для валидации данных (Контракт с FlutterFlow) ---

class ChatRequest(BaseModel):
    query: str = Field(..., description="Текст вопроса от студента")
    data_store_id: str = Field(..., description="ID хранилища базы знаний в Google Cloud")
    conversation_id: Optional[str] = Field(None, description="ID сессии для продолжения диалога")

class CitationMetadata(BaseModel):
    source_title: str
    uri: str
    text_segment: str

class ChatResponse(BaseModel):
    reply: str = Field(..., description="Ответ, сгенерированный ИИ")
    conversation_id: str = Field(..., description="ID текущей сессии диалога")
    citations: List[CitationMetadata] = Field(default_factory=list, description="Список первоисточников")

# --- 2. Зависимость (Пограничный контроль) ---

def get_current_user(authorization: str = Header(None)) -> AuthenticatedUser:
    """
    Dependency-функция для FastAPI.
    Перехватывает заголовок Authorization, проверяет токен и возвращает пользователя.
    """
    try:
        return firebase_service.verify_firebase_token(authorization)
    except ValueError as e:
        # Если токен невалиден, прерываем запрос с ошибкой 401 (Unauthorized)
        raise HTTPException(status_code=401, detail=str(e))

# --- 3. Эндпоинты ---

@router.post("/converse", response_model=ChatResponse, summary="Диалог с междисциплинарным Агентом")
async def converse_with_agent(
    request: ChatRequest, 
    user: AuthenticatedUser = Depends(get_current_user)
):
    """
    Главный эндпоинт для связи FlutterFlow и Gemini Enterprise Agent Platform.
    Защищен проверкой токена Firebase.
    """
    try:
        # Логируем (по желанию) ID пользователя, который делает запрос
        print(f"[{user.uid}] Запрос к Агенту: {request.query[:50]}...")
        
        # Передаем данные в сервис Vertex AI
        reply_text, next_conv_id, citations_list = vertex_agent_service.converse(
            query=request.query,
            data_store_id=request.data_store_id,
            conversation_id=request.conversation_id
        )
        
        # Упаковываем ответ в строгий формат ChatResponse
        return ChatResponse(
            reply=reply_text,
            conversation_id=next_conv_id,
            citations=[CitationMetadata(**c) for c in citations_list]
        )

    except RuntimeError as e:
        # Ошибки от Google Cloud (например, агент не найден или таймаут)
        raise HTTPException(status_code=502, detail=str(e))
    except Exception as e:
        # Любые непредвиденные сбои бэкенда
        raise HTTPException(status_code=500, detail="Внутренняя ошибка сервера")
        