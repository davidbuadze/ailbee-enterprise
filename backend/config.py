import os
from pydantic import BaseModel
from typing import List

class Settings(BaseModel):
    """
    Класс конфигурации приложения Ailbee Enterprise.
    Использует Pydantic для безопасного чтения переменных окружения.
    Секретные токены больше не хранятся в открытом виде.
    """
    GCP_PROJECT_ID: str = os.environ.get("GCP_PROJECT_ID", "ailbee")
    GCP_LOCATION: str = os.environ.get("GCP_LOCATION", "global")
    PORT: int = int(os.environ.get("PORT", 8080))

    ALLOWED_ORIGINS: List[str] = [
        "https://app.flutterflow.io",
        "http://localhost:3000",
    ]

    # В продакшене значение будет браться из настроек Cloud Run.
    # Значение "local-dev-placeholder" сработает только внутри вашей Workstation.
    CRON_SECRET_TOKEN: str = os.environ.get("CRON_SECRET_TOKEN", "local-dev-placeholder")

settings = Settings()