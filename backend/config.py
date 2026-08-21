# config.py
# Системная конфигурация Ailbee Enterprise Hub
import os
from typing import List, Union
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    # Системные переменные Google Cloud Platform
    GCP_PROJECT_ID: str = os.getenv("GCP_PROJECT_ID", "ailbee")
    GCP_LOCATION: str = os.getenv("GCP_LOCATION", "us-central1")
    GCS_BUCKET_NAME: str = os.getenv("GCS_BUCKET_NAME", "ailbee-books")
    
    # Идентификатор приложения для соблюдения правила путей RULE 1
    APP_ID: str = os.getenv("APP_ID", "ailbee-app-prod")
    
    # Идентификаторы агентов по умолчанию
    DEFAULT_SCHOOL_AGENT_ID: str = os.getenv("DEFAULT_SCHOOL_AGENT_ID", "school_public_agent")
    DEFAULT_RESEARCH_AGENT_ID: str = os.getenv("DEFAULT_RESEARCH_AGENT_ID", "core_assistant")
    
    # Ключ безопасности для внутренних Cron-сервисов
    CRON_SECRET_TOKEN: str = os.getenv("CRON_SECRET_TOKEN", "cron_secret_bypass_key")
    
    # Ссылка на локальный/облачный сервер Gemma (Ollama API / Cloud Run)
    GEMMA_SERVER_URL: str = os.getenv("GEMMA_SERVER_URL", "http://localhost:11434")
    
    # Разрешенные адреса для CORS-политики (включая FlutterFlow и локальную разработку)
    ALLOWED_ORIGINS: List[str] = [
        "*",  # Разрешает запросы со всех доменов (включая тестовый веб-плейграунд FlutterFlow)
        "https://app.flutterflow.io",
        "https://ailbee.web.app",
        "https://ailbee.firebaseapp.com",
        "https://ailbee-ff-app-0ty350.flutterflow.app",
        "http://localhost:3000",
        "http://localhost:5000",
        "http://localhost:8080",
        "http://localhost:9005"
    ]

    class Config:
        env_file = ".env"
        extra = "ignore"

settings = Settings()
