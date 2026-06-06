from fastapi import APIRouter, Depends, HTTPException, Header
from pydantic import BaseModel, Field
from typing import Optional, List
from services.firebase import FirebaseService, AuthenticatedUser
from services.vertex_agent import VertexAgentService

router = APIRouter()
firebase_service = FirebaseService()
vertex_agent_service = VertexAgentService()

class SearchRequest(BaseModel):
    query: str = Field(..., description="Поисковый междисциплинарный запрос к книгам")
    agent_id: str = Field(..., description="ID Хранилища данных (Data Store ID)")
    conversation_id: Optional[str] = Field(None, description="ID сессии поиска")

class CitationMetadata(BaseModel):
    source_title: str
    uri: str
    text_segment: str

class SearchResponse(BaseModel):
    reply: str = Field(..., description="Сгенерированный ИИ ответ на основе книг")
    conversation_id: str = Field(..., description="ID сессии")
    citations: List[CitationMetadata] = Field(default_factory=list, description="Список первоисточников")

def get_current_user(authorization: str = Header(None)) -> AuthenticatedUser:
    try:
        return firebase_service.verify_firebase_token(authorization)
    except ValueError as e:
        raise HTTPException(status_code=401, detail=str(e))

@router.post("/converse", response_model=SearchResponse, summary="Академический RAG поиск по книгам")
async def search_in_library(
    request: SearchRequest, 
    user: AuthenticatedUser = Depends(get_current_user)
):
    try:
        print(f"[{user.uid}] Поиск по книгам (Query): {request.query[:50]}...")
        reply_text, next_conv_id, citations_list = vertex_agent_service.converse_search_rag(
            query=request.query,
            agent_id=request.agent_id,
            conversation_id=request.conversation_id
        )
        return SearchResponse(
            reply=reply_text,
            conversation_id=next_conv_id,
            citations=[CitationMetadata(**c) for c in citations_list]
        )
    except RuntimeError as e:
        raise HTTPException(status_code=502, detail=str(e))
    except Exception as e:
        import traceback
        print(f"!!! КРИТИЧЕСКИЙ СБОЙ БЭКЕНДА ПОИСКА: {str(e)}")
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=f"Внутренняя ошибка бэкенда: {str(e)}")
        