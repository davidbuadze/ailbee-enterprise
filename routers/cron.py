# backend/routers/cron.py
# Роутер FastAPI для выполнения регламентных задач обслуживания и удержания пользователей

import datetime
import asyncio
from fastapi import APIRouter, HTTPException, Request
from firebase_admin import firestore
from services.firebase import FirebaseService
from config import settings

router = APIRouter()
firebase_service = FirebaseService()
db = firestore.client()

@router.post("/sync-user-statuses", summary="Синхронизация статусов активности учеников")
async def sync_user_statuses(request: Request):
    """
    Cron-задача для перевода неактивных пользователей в пассивные статусы.
    Строго соблюдает RULE 2 (Никаких сложных queries - фильтрация в памяти Python)
    """
    auth_header = request.headers.get("X-Cron-Backdoor")
    if auth_header != settings.CRON_SECRET_TOKEN:
        raise HTTPException(status_code=403, detail="Доступ запрещен.")

    try:
        now = datetime.datetime.now(datetime.timezone.utc)
        threshold_30_days = now - datetime.timedelta(days=30)
        threshold_180_days = now - datetime.timedelta(days=180)

        # Соблюдаем RULE 1: Читаем корневую коллекцию пользователей приложения
        users_ref = db.collection('artifacts').document(settings.APP_ID).collection('users')
        
        # RULE 2 COMPLIANT: Просто стримим все документы, никакой сложной фильтрации на уровне БД
        all_users = await asyncio.to_thread(users_ref.stream)
        
        count_30 = 0
        count_180 = 0

        for user_doc in all_users:
            # Считываем детальный профиль пользователя (RULE 1)
            profile_ref = user_doc.reference.collection('profile').document('details')
            profile_snapshot = await asyncio.to_thread(profile_ref.get)
            
            if not profile_snapshot.exists:
                continue
                
            user_data = profile_snapshot.to_dict() or {}
            last_activity = user_data.get("last_activity")
            status = user_data.get("status", "active")

            if last_activity and isinstance(last_activity, datetime.datetime):
                # Фильтруем полностью в памяти Python
                if last_activity <= threshold_180_days and status == "active":
                    await asyncio.to_thread(profile_ref.update, {"status": "passive_180"})
                    count_180 += 1
                elif last_activity <= threshold_30_days and last_activity > threshold_180_days and status == "active":
                    await asyncio.to_thread(profile_ref.update, {"status": "passive_30"})
                    count_30 += 1

        return {
            "status": "success",
            "processed_passive_30": count_30,
            "processed_passive_180": count_180
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Ошибка синхронизации: {str(e)}")
        