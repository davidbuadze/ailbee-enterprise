from fastapi import APIRouter, Depends, HTTPException, Header
from pydantic import BaseModel, Field
from typing import Optional

from services.firebase import FirebaseService, AuthenticatedUser
from services.vertex_agent import VertexAgentService

router = APIRouter()
firebase_service = FirebaseService()
vertex_agent_service = VertexAgentService()

class ChatRequest(BaseModel):
    query: str = Field(..., description="Текст вопроса ИИ-Агенту")
    agent_id: str = Field(..., description="ID в Google Cloud (App ID)")
    conversation_id: Optional[str] = Field(None, description="ID сессии диалога")

class ChatResponse(BaseModel):
    reply: str = Field(..., description="Ответ, сгенерированный Gemini Enterprise Агентом")
    conversation_id: str = Field(..., description="ID текущей сессии диалога")

def get_current_user(authorization: str = Header(None)) -> AuthenticatedUser:
    try:
        return firebase_service.verify_firebase_token(authorization)
    except ValueError as e:
        raise HTTPException(status_code=401, detail=str(e))

@router.post("/converse", response_model=ChatResponse, summary="Диалог с междисциплинарным Агентом")
async def converse_with_agent(
    request: ChatRequest, 
    user: AuthenticatedUser = Depends(get_current_user)
):
    try:
        print(f"[{user.uid}] Запрос к Агенту: {request.query[:50]}...")
        
        reply_text, next_conv_id = vertex_agent_service.converse_chat_agent(
            query=request.query,
            agent_id=request.agent_id,
            conversation_id=request.conversation_id
        )
        
        return ChatResponse(reply=reply_text, conversation_id=next_conv_id)

    except RuntimeError as e:
        raise HTTPException(status_code=502, detail=str(e))
    except Exception as e:
        import traceback
        print(f"!!! КРИТИЧЕСКИЙ СБОЙ БЭКЕНДА ЧАТА: {str(e)}")
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=f"Внутренняя ошибка бэкенда: {str(e)}")
        