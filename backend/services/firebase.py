# backend/services/firebase.py
# Безопасный асинхронный адаптер Firebase Admin SDK и Firestore
# Строго соблюдает правила путей (RULE 1), лимиты запросов (RULE 2) и аутентификацию (RULE 3)

import asyncio
import datetime
from typing import Optional, Dict, Any, List
import firebase_admin
from firebase_admin import credentials, auth, firestore
from google.cloud.firestore_v1.base_document import DocumentSnapshot
from config import settings

# Инициализация Firebase Admin (гарантирует Singleton запуск)
if not firebase_admin._apps:
    firebase_admin.initialize_app(credentials.ApplicationDefault())

db = firestore.client()

class FirebaseService:
    @staticmethod
    async def verify_firebase_token(auth_header: Optional[str]) -> str:
        """
        Проверка токена пользователя (RULE 3 - Auth Before Queries)
        Возвращает проверенный UID.
        """
        if not auth_header or not auth_header.startswith("Bearer "):
            raise ValueError("Отсутствует или поврежден заголовок Authorization.")
        
        token = auth_header.split("Bearer ")[1]
        try:
            # Асинхронный вызов блокирующей функции SDK
            decoded_token = await asyncio.to_thread(auth.verify_id_token, token)
            return decoded_token['uid']
        except Exception as e:
            raise ValueError(f"Ошибка верификации токена Firebase: {str(e)}")

    @staticmethod
    def get_private_doc_ref(user_id: str, collection_name: str, doc_id: str):
        """
        Строгое соблюдение RULE 1 для приватных данных:
        Путь: /artifacts/{appId}/users/{userId}/{collectionName}/{docId}
        """
        return db.collection('artifacts').document(settings.APP_ID) \
                 .collection('users').document(user_id) \
                 .collection(collection_name).document(doc_id)

    @staticmethod
    def get_private_collection_ref(user_id: str, collection_name: str):
        """Ссылка на приватную коллекцию пользователя (RULE 1 Compliant)"""
        return db.collection('artifacts').document(settings.APP_ID) \
                 .collection('users').document(user_id) \
                 .collection(collection_name)

    @staticmethod
    def get_public_collection_ref(collection_name: str):
        """
        Строгое соблюдение RULE 1 для публичных данных:
        Путь: /artifacts/{appId}/public/data/{collectionName}
        """
        return db.collection('artifacts').document(settings.APP_ID) \
                 .collection('public').document('data') \
                 .collection(collection_name)

    async def get_user_profile(self, user_id: str) -> Dict[str, Any]:
        """Получение профиля пользователя (RULE 1, RULE 3)"""
        doc_ref = self.get_private_doc_ref(user_id, "profile", "details")
        doc: DocumentSnapshot = await asyncio.to_thread(doc_ref.get)
        if doc.exists:
            data = doc.to_dict() or {}
            # Конвертируем временные метки Firestore для корректного JSON вывода
            for k, v in data.items():
                if isinstance(v, datetime.datetime):
                    data[k] = v.isoformat()
            return data
        return {}

    async def update_user_profile(self, user_id: str, data: Dict[str, Any]) -> None:
        """Обновление профиля пользователя (RULE 1, RULE 3)"""
        doc_ref = self.get_private_doc_ref(user_id, "profile", "details")
        data["updated_at"] = firestore.SERVER_TIMESTAMP
        await asyncio.to_thread(doc_ref.set, data, merge=True)

    async def log_audit_event(self, user_id: str, action: str, details: Dict[str, Any]) -> None:
        """Запись логов аудита во внутреннее хранилище пользователя (RULE 1)"""
        collection_ref = self.get_private_collection_ref(user_id, "audit_logs")
        log_entry = {
            "action": action,
            "details": details,
            "timestamp": firestore.SERVER_TIMESTAMP
        }
        await asyncio.to_thread(collection_ref.add, log_entry)

    async def save_fcm_token(self, user_id: str, fcm_token: str) -> None:
        """Сохранение токена push-уведомлений во вложенную коллекцию (RULE 1)"""
        doc_ref = self.get_private_doc_ref(user_id, "fcm_tokens", fcm_token)
        await asyncio.to_thread(doc_ref.set, {"updated_at": firestore.SERVER_TIMESTAMP}, merge=True)

    async def get_mem0_memory(self, user_id: str) -> str:
        """Считывание долгосрочного контекста Mem0 (RULE 1)"""
        doc_ref = self.get_private_doc_ref(user_id, "mem0_profile", "memory")
        doc: DocumentSnapshot = await asyncio.to_thread(doc_ref.get)
        if doc.exists:
            return doc.to_dict().get("compiled_context", "")
        return "Пользователь исследует законы физики, биологии и единства природы."

    async def update_mem0_memory(self, user_id: str, new_context: str) -> None:
        """Обновление долгосрочного контекста Mem0 (RULE 1)"""
        doc_ref = self.get_private_doc_ref(user_id, "mem0_profile", "memory")
        doc: DocumentSnapshot = await asyncio.to_thread(doc_ref.get)
        current = doc.to_dict().get("compiled_context", "") if doc.exists else ""
        
        # Накапливаем контекст через сепаратор
        updated = f"{current} | {new_context}".strip(" |")
        await asyncio.to_thread(doc_ref.set, {
            "compiled_context": updated,
            "last_updated": firestore.SERVER_TIMESTAMP
        }, merge=True)
        