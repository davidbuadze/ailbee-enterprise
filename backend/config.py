# app/config.py
import os
from pydantic import BaseModel
from typing import List

class Settings(BaseModel):
    """
    Класс конфигурации приложения Ailbee Enterprise Light.
    Использует Pydantic для типизации и безопасного чтения переменных окружения.
    """
    # ID вашего проекта в Google Cloud Console
    GCP_PROJECT_ID: str = os.environ.get("GCP_PROJECT_ID", "ailbee")
    
    # Локация для Vertex AI Agent Builder (для эндпоинтов развертывания чаще всего "global")
    GCP_LOCATION: str = os.environ.get("GCP_LOCATION", "global")
    
    # Порт, на котором будет запускаться контейнер в Cloud Run (Google выставляет его сам)
    PORT: int = int(os.environ.get("PORT", 8080))
    
    # Список доверенных адресов для CORS (защита от несанкционированных браузерных запросов)
    ALLOWED_ORIGINS: List[str] = [
        "https://app.flutterflow.io",  # Среда разработки FlutterFlow
        "http://localhost:3000",       # Локальное тестирование фронтенда
        # Вы можете добавить сюда домен вашего готового веб-приложения Ailbee
    ]

# Создаем синглтон (единый объект настроек) для импорта в другие модули
settings = Settings()
