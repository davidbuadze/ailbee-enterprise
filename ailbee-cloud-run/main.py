import os
from fastapi import FastAPI, APIRouter, Depends, HTTPException, Request
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from typing import Optional, List

# --- Импорт сервисов ---
# Предполагается, что в services.py добавлены методы get_user_profile, update_user_profile и save_fcm_token
from services import FirebaseService, VertexAISearchService, BillingService, User

# --- 1. Конфигурация и инициализация ---

GCP_PROJECT_ID = os.environ.get("GCP_PROJECT_ID", "ailbee")
GCP_LOCATION = os.environ.get("GCP_LOCATION", "us-central1")

app = FastAPI(
    title="Ailbee Backend Service",
    description="Управление данными, бизнес-логикой и интеграцией с Google Cloud.",
    version="2.1.0",
)

# Настройка CORS
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

# Инициализация сервисов
firebase_service = FirebaseService()
vertex_ai_service = VertexAISearchService(project_id=GCP_PROJECT_ID, location=GCP_LOCATION)
billing_service = BillingService()

# --- 2. Модели запросов и ответов (Pydantic) ---

class AskRequest(BaseModel):
    query: str
    data_store_id: str = Field(description="ID хранилища данных Vertex AI Search")
    conversation_id: Optional[str] = None

class BillingRequest(BaseModel):
    payment_token: str = Field(description="Токен от Google Pay API")
    product_id: str = Field(description="ID продукта или подписки")

class UserProfileUpdate(BaseModel):
    displayName: Optional[str] = None
    age: Optional[int] = None
    preferredLanguage: Optional[str] = None

class FCMTokenRequest(BaseModel):
    fcmToken: str = Field(..., description="Регистрационный токен Firebase Cloud Messaging")

# --- 3. Аутентификация (Dependency) ---

async def get_current_user(request: Request) -> User:
    """
    Зависимость для получения текущего пользователя.
    Корректно обрабатывает анонимных и авторизованных пользователей.
    """
    auth_header = request.headers.get('Authorization')
    return firebase_service.verify_token(auth_header)

# --- 4. Роутеры API ---

root_router = APIRouter()
rag_router = APIRouter(prefix="/ask", tags=["Vertex AI RAG"])
billing_router = APIRouter(prefix="/billing", tags=["Платежи"])
users_router = APIRouter(prefix="/users", tags=["Пользователи"])

# --- Корневые эндпоинты ---
@root_router.get("/", summary="Health Check")
@root_router.get("/api/", summary="Health Check Alternative")
def read_root():
    return {"status": "ok", "service": "Ailbee Backend", "version": "2.1.0"}

# --- Эндпоинты Пользователей (Восстановлено) ---
@users_router.get("/profile", summary="Получить профиль пользователя")
async def get_profile_endpoint(user: User = Depends(get_current_user)):
    if user.is_anonymous:
        return {"status": "anonymous", "uid": user.uid}
    
    # Вызываем метод получения профиля из FirebaseService
    profile = await firebase_service.get_user_profile(user.uid)
    return {"status": "success", "profile": profile}

@users_router.put("/profile", summary="Обновить профиль пользователя")
async def update_profile_endpoint(req: UserProfileUpdate, user: User = Depends(get_current_user)):
    if user.is_anonymous:
        raise HTTPException(status_code=403, detail="Анонимные пользователи не могут иметь профиль")
    
    update_data = req.model_dump(exclude_unset=True)
    result = await firebase_service.update_user_profile(user.uid, update_data)
    return {"status": "success", "data": result}

@users_router.post("/save-fcm-token", summary="Сохранить FCM токен")
async def save_fcm_token_endpoint(req: FCMTokenRequest, user: User = Depends(get_current_user)):
    # Сохраняем токен даже для анонимов, если логика приложения это позволяет
    result = await firebase_service.save_fcm_token(user.uid, req.fcmToken)
    return {"status": "success", "message": "Токен сохранен"}

# --- Эндпоинт RAG ---
@rag_router.post("/", summary="Запрос к Vertex AI Search")
async def ask_rag_endpoint(req: AskRequest, user: User = Depends(get_current_user)):
    try:
        user_filter = user.uid if not user.is_anonymous else None
        result = vertex_ai_service.ask(
            query=req.query,
            data_store_id=req.data_store_id,
            user_id_for_filter=user_filter
        )
        return {"status": "success", "data": result}
    except RuntimeError as e:
        raise HTTPException(status_code=502, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Ошибка сервера: {e}")

# --- Эндпоинт Биллинга ---
@billing_router.post("/google-pay", summary="Обработка платежа Google Pay")
async def process_google_pay_payment(req: BillingRequest, user: User = Depends(get_current_user)):
    if user.is_anonymous:
        raise HTTPException(status_code=403, detail="Платежи недоступны для анонимных пользователей")
        
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
    # Cloud Run слушает порт 8080 по умолчанию
    port = int(os.environ.get("PORT", 8080))
    # Для продакшена в Cloud Run убираем reload=True и настраиваем логи
    uvicorn.run("main:app", host="0.0.0.0", port=port, log_level="info")
    