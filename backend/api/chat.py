# backend/api/chat.py
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
    query: str = Field(..., description="Текст вопроса ИИ-Агенту")
    agent_id: str = Field(..., description="ID в Google Cloud")
    conversation_id: Optional[str] = Field(None, description="ID сессии диалога")

class ChatResponse(BaseModel):
    reply: str = Field(..., description="Ответ, сгенерированный Gemini Enterprise Агентом")
    conversation_id: str = Field(..., description="ID текущей сессии диалога")

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
        reply_text, next_conv_id = vertex_agent_service.converse_chat_agent(
            query=request.query,
            agent_id=request.agent_id,
            conversation_id=request.conversation_id
        )
        
        # Упаковываем ответ в строгий формат ChatResponse
        return ChatResponse(
            reply=reply_text,
            conversation_id=next_conv_id,
        )

    except RuntimeError as e:
        # Ошибки от Google Cloud (например, агент не найден или таймаут)
        raise HTTPException(status_code=502, detail=str(e))
    except Exception as e:# Импортируем стандартный модуль отслеживания ошибок Linux/Python
        import traceback
        print(f"!!! КРИТИЧЕСКИЙ СБОЙ БЭКЕНДА: {str(e)}")
        traceback.print_exc()  # Это отправит полный Traceback прямо в панель Cloud Run Logs!
        
        # Для удобства тестирования выводим реальную ошибку в тело ответа
        raise HTTPException(status_code=500, detail=f"Внутренняя ошибка бэкенда: {str(e)}")
        