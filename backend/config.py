# config.py
# Системная конфигурация Ailbee Enterprise Hub
import os
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    # Системные переменные Google Cloud Platform
    GCP_PROJECT_ID: str = os.getenv("GCP_PROJECT_ID", "ailbee")
    GCP_LOCATION: str = os.getenv("GCP_LOCATION", "us-central1")
    GCS_BUCKET_NAME: str = os.getenv("GCS_BUCKET_NAME", "ailbee-books")
    
    # Идентификатор приложения для соблюдения правила путей RULE 1
    APP_ID: str = os.getenv("APP_ID", "ailbee-app-prod")
    
    # Ключ безопасности для внутренних Cron-сервисов
    CRON_SECRET_TOKEN: str = os.getenv("CRON_SECRET_TOKEN", "cron_secret_bypass_key")
    
    # Ссылка на локальный/облачный сервер Gemma (Ollama API)
    GEMMA_SERVER_URL: str = os.getenv("GEMMA_SERVER_URL", "http://localhost:11434")
    
    # Разрешенные адреса для CORS-политики (включая FlutterFlow)
    ALLOWED_ORIGINS: list = [
        "https://app.flutterflow.io",
        "https://ailbee.web.app",
        "https://ailbee.firebaseapp.com",
        "http://localhost:3000",
        "http://localhost:8080",
        "http://localhost:9005"
    ]

    class Config:
        env_file = ".env"
        extra = "ignore"

settings = Settings()
