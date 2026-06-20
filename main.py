# backend/main.py
# Центральная точка входа FastAPI Gateway для Ailbee Enterprise Hub v3.3.2
# Настроена под модульную структуру папок: api/, routers/, services/

import os
import uvicorn
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from config import settings

# Импорты модулей с учетом реальной вложенности папок (Решение ошибки ModuleNotFoundError)
from api.chat import router as chat_router
from api.search import router as search_router
from routers.cron import router as cron_router

app = FastAPI(
    title="Ailbee Enterprise Hub",
    description="Оркестратор междисциплинарных связей на базе Vertex AI, Mem0 памяти и LangGraph",
    version="3.3.2"
)

# Настройка CORS для защищенной связи со всеми клиентами и FlutterFlow
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Регистрация модулей с указанием путей
app.include_router(chat_router, prefix="/api/v3/chat", tags=["Creative AI Agent"])
app.include_router(search_router, prefix="/api/v3/search", tags=["Academic RAG Search"])
app.include_router(cron_router, prefix="/api/v3/cron", tags=["System Maintenance Cron"])

@app.get("/", summary="Health Check", tags=["System"])
def read_root():
    return {
        "status": "online",
        "service": "Ailbee Enterprise Hub",
        "version": app.version,
        "project_id": settings.GCP_PROJECT_ID,
        "location": settings.GCP_LOCATION
    }

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 8080))
    uvicorn.run("main:app", host="0.0.0.0", port=port, log_level="info")
    