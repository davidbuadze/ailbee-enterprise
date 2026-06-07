import os
from pydantic import BaseModel
from typing import List

class Settings(BaseModel):
    """
    Класс конфигурации приложения Ailbee Enterprise.
    Использует Pydantic для типизации и безопасного чтения переменных окружения.
    """
    GCP_PROJECT_ID: str = os.environ.get("GCP_PROJECT_ID", "ailbee")
    GCP_LOCATION: str = os.environ.get("GCP_LOCATION", "global")
    PORT: int = int(os.environ.get("PORT", 8080))
    
    ALLOWED_ORIGINS: List[str] = [
        "https://app.flutterflow.io",  
        "http://localhost:3000",       
    ]

    CRON_SECRET_TOKEN: str = os.getenv("CRON_SECRET_TOKEN", "AilbeeCronSecure2026_x97Fq_Kron26SysKey")

settings = Settings()
