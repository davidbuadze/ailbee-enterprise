import os
import logging
from fastapi import FastAPI, APIRouter, Depends, HTTPException, Request
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from typing import Optional, List

# --- Импорт сервисов ---
# UnifiedResearchService заменяет VertexAISearchService для поддержки междисциплинарных связей
from services import FirebaseService, UnifiedResearchService, BillingService, User

# Настройка логирования для отслеживания процесса развертывания
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("ailbee-backend")

# --- 1. Конфигурация и инициализация ---

GCP_PROJECT_ID = os.environ.get("GCP_PROJECT_ID", "ailbee")

app = FastAPI(
    title="Ailbee Backend Service",
    description="Интерактивная доска естествознания: единство природы через AI.",
    version="2.2.1",
)

# Настройка CORS для связи с FlutterFlow
allowed_origins = [
    "https://app.flutterflow.io",
    "http://localhost:3000",
    "http://localhost:8080",
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=allowed_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Инициализация сервисов с обработкой ошибок для безопасного первого запуска
try:
    firebase_service = FirebaseService()
    unified_research_service = UnifiedResearchService(project_id=GCP_PROJECT_ID)
    billing_service = BillingService()
    logger.info("Все сервисы Ailbee успешно инициализированы.")
except Exception as e:
    logger.error(f"Ошибка при инициализации сервисов: {e}")
    # Мы не останавливаем приложение, чтобы Health Check мог пройти успешно
    # Ошибки будут обработаны непосредственно в эндпоинтах

# --- 2. Модели запросов и ответов (Pydantic) ---

class AskRequest(BaseModel):
    query: str = Field(..., description="Вопрос по естествознанию или исследовательской работе")
    conversation_id: Optional[str] = None

class BillingRequest(BaseModel):
    payment_token: str = Field(..., description="Токен от Google Pay API")
    product_id: str = Field(..., description="ID продукта или подписки")

class UserProfileUpdate(BaseModel):
    displayName: Optional[str] = None
    age: Optional[int] = None
    preferredLanguage: Optional[str] = None

class FCMTokenRequest(BaseModel):
    fcmToken: str = Field(..., description="Регистрационный токен Firebase Cloud Messaging")

# --- 3. Аутентификация (Dependency) ---

async def get_current_user(request: Request) -> User:
    """
    Зависимость для идентификации пользователя (авторизован или гость).
    """
    auth_header = request.headers.get('Authorization')
    return firebase_service.verify_token(auth_header)

# --- 4. Роутеры API ---

root_router = APIRouter()
rag_router = APIRouter(prefix="/ask", tags=["Интерактивное исследование"])
billing_router = APIRouter(prefix="/billing", tags=["Платежи"])
users_router = APIRouter(prefix="/users", tags=["Пользователи"])

# --- Корневые эндпоинты ---
@root_router.get("/", summary="Health Check")
def read_root():
    return {
        "status": "ok", 
        "service": "Ailbee Unified Backend", 
        "version": "2.2.1",
        "project_id": GCP_PROJECT_ID
    }

# --- Эндпоинты Пользователей ---
@users_router.get("/profile", summary="Получить профиль пользователя")
async def get_profile_endpoint(user: User = Depends(get_current_user)):
    if user.is_anonymous:
        return {"status": "anonymous", "uid": user.uid}
    
    profile = await firebase_service.get_user_profile(user.uid)
    return {"status": "success", "profile": profile}

@users_router.put("/profile", summary="Обновить профиль пользователя")
async def update_profile_endpoint(req: UserProfileUpdate, user: User = Depends(get_current_user)):
    if user.is_anonymous:
        raise HTTPException(status_code=403, detail="Требуется авторизация для управления профилем")
    
    update_data = req.model_dump(exclude_unset=True)
    result = await firebase_service.update_user_profile(user.uid, update_data)
    return {"status": "success", "data": result}

@users_router.post("/save-fcm-token", summary="Сохранить FCM токен")
async def save_fcm_token_endpoint(req: FCMTokenRequest, user: User = Depends(get_current_user)):
    result = await firebase_service.save_fcm_token(user.uid, req.fcmToken)
    return {"status": "success", "message": "Токен сохранен"}

# --- Эндпоинт RAG (Заменен на Unified Research) ---
@rag_router.post("/", summary="Междисциплинарный синтез знаний")
async def ask_rag_endpoint(req: AskRequest, user: User = Depends(get_current_user)):
    """
    Основной эндпоинт 'Интерактивной доски'.
    """
    if not unified_research_service:
        raise HTTPException(status_code=503, detail="Сервис исследования временно недоступен")

    try:
        # Теперь мы используем асинхронный метод синтеза знаний
        result = await unified_research_service.research_unified(query=req.query)
        
        return {
            "status": "success",
            "data": {
                "answer": result.answer,
                "subjects_involved": result.relevant_subjects,
                "raw_contexts": result.context_data,
                "sources": result.sources
            }
        }
    except Exception as e:
        logger.error(f"Ошибка в Unified Research: {e}")
        raise HTTPException(status_code=500, detail=f"Ошибка синтеза знаний: {str(e)}")

# --- Эндпоинт Биллинга ---
@billing_router.post("/google-pay", summary="Обработка платежа Google Pay")
async def process_google_pay_payment(req: BillingRequest, user: User = Depends(get_current_user)):
    if user.is_anonymous:
        raise HTTPException(status_code=403, detail="Платежи доступны только авторизованным пользователям")
        
    try:
        result = await billing_service.process_google_pay_token(
            user_id=user.uid,
            payment_token=req.payment_token,
            product_id=req.product_id,
        )
        if result.get("status") == "error":
            raise HTTPException(status_code=400, detail=result["message"])
        return {"status": "success", "data": result}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Ошибка при обработке платежа: {e}")

# --- Регистрация роутеров ---
app.include_router(root_router)
app.include_router(users_router)
app.include_router(rag_router)
app.include_router(billing_router)

# --- Запуск ---
if __name__ == "__main__":
    import uvicorn
    port = int(os.environ.get("PORT", 8080))
    # В продакшене убираем reload=True для стабильности
    uvicorn.run("main:app", host="0.0.0.0", port=port, log_level="info")
    