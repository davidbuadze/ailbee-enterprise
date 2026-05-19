# app/services/firebase.py
import firebase_admin
from firebase_admin import auth, credentials
from pydantic import BaseModel
from typing import Optional

# --- Модель для представления авторизованного пользователя ---
class AuthenticatedUser(BaseModel):
    uid: str
    email: Optional[str] = None
    is_anonymous: bool = False
    # Сюда в будущем можно добавить роли, например: role: str = "student"

class FirebaseService:
    def __init__(self):
        """
        Инициализация Firebase Admin SDK.
        В среде Google Cloud (Cloud Run / Cloud Workstations) SDK автоматически
        подтягивает сервисный аккаунт по умолчанию (Application Default Credentials),
        поэтому нам не нужно жестко прописывать путь к JSON-ключам безопасности.
        """
        try:
            firebase_admin.get_app()
        except ValueError:
            # Если приложение еще не инициализировано, запускаем его
            firebase_admin.initialize_app()

    def verify_firebase_token(self, auth_header: Optional[str]) -> AuthenticatedUser:
        """
        Декодирует и валидирует JWT-токен, пришедший из фронтенда FlutterFlow.
        
        Args:
            auth_header: Строка из заголовка запроса вида "Bearer <TOKEN>"
            
        Returns:
            AuthenticatedUser: Объект с подтвержденными данными пользователя.
            
        Raises:
            ValueError: Если токен отсутствует, просрочен или подделан.
        """
        # 1. Проверяем наличие и базовый формат заголовка
        if not auth_header or not auth_header.startswith("Bearer "):
            raise ValueError("Missing or invalid Authorization header format. Expected 'Bearer <token>'.")

        # 2. Очищаем строку, оставляя только чистый криптографический токен
        token = auth_header.split("Bearer ")[1].strip()

        try:
            # 3. Отправляем токен на проверку в криптографический контур Firebase Auth
            decoded_token = auth.verify_id_token(token)
            
            # 4. Проверяем, не является ли пользователь анонимным (гостевой вход в приложении)
            firebase_meta = decoded_token.get("firebase", {})
            sign_in_provider = firebase_meta.get("sign_in_provider")
            is_anonymous = sign_in_provider == "anonymous"

            # 5. Собираем проверенный профиль для передачи в эндпоинты FastAPI
            return AuthenticatedUser(
                uid=decoded_token["uid"],
                email=decoded_token.get("email"),
                is_anonymous=is_anonymous
            )

        except auth.ExpiredIdTokenError:
            raise ValueError("The provided Firebase ID token has expired. Please refresh it in the app.")
        except auth.InvalidIdTokenError:
            raise ValueError("The provided Firebase ID token is invalid or tampered with.")
        except Exception as e:
            raise ValueError(f"Firebase authentication failed: {str(e)}")
            