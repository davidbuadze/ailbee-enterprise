from datetime import datetime, timedelta, timezone
from fastapi import APIRouter, HTTPException, Security
from fastapi.security import APIKeyHeader
from google.cloud import firestore
from config import settings

router = APIRouter()
db = firestore.Client()

api_key_header = APIKeyHeader(name="X-Cron-Backdoor", auto_error=False)

@router.post("/sync-user-statuses")
async def sync_user_statuses(token: str = Security(api_key_header)):
    if token != settings.CRON_SECRET_TOKEN:
        raise HTTPException(status_code=403, detail="Access Denied")
    
    try:
        # ТУТ ВАШ ТЕКУЩИЙ КОД ЦИКЛА И СИНХРОНИЗАЦИИ С Firestore
        # ...
        return {"status": "success"}
        
    except Exception as e:
        # Если код упадет, мы увидим точную причину прямо в ответе curl!
        return {"status": "error", "details": str(e)}
        
    now = datetime.now(timezone.utc)
    threshold_30_days = now - timedelta(days=30)
    threshold_180_days = now - timedelta(days=180)
    
    users_ref = db.collection("users")
    
    # 1. Находим и переводим глубоко пассивных (более 180 дней)
    passive_180_query = users_ref.where("last_activity", "<=", threshold_180_days).where("status", "==", "active")
    docs_180 = passive_180_query.stream()
    count_180 = 0
    for doc in docs_180:
        doc.reference.update({"status": "passive_180"})
        count_180 += 1
        
    # 2. Находим умеренно пассивных (от 30 до 180 дней) без пересечений
    passive_30_query = (
        users_ref
        .where("last_activity", "<=", threshold_30_days)
        .where("last_activity", ">", threshold_180_days)
        .where("status", "==", "active")
    )
    docs_30 = passive_30_query.stream()
    count_30 = 0
    for doc in docs_30:
        doc.reference.update({"status": "passive_30"})
        count_30 += 1
        
    return {
        "status": "success", 
        "message": "User retention statuses synchronized successfully.",
        "processed_passive_30": count_30,
        "processed_passive_180": count_180
    }
