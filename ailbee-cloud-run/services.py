import os
import datetime
import firebase_admin
from firebase_admin import auth, firestore
from pydantic import BaseModel
from typing import Optional, List

from google.cloud import discoveryengine_v1 as discoveryengine
from google.api_core.exceptions import GoogleAPICallError

# --- 1. Модели данных ---

class User(BaseModel):
    """Модель для внутреннего представления пользователя."""
    uid: str
    email: Optional[str] = None
    is_anonymous: bool

# --- 2. Сервис для работы с Firebase (Auth и Firestore) ---

class FirebaseService:
    def __init__(self):
        try:
            firebase_admin.get_app()
        except ValueError:
            # Инициализация Firebase Admin SDK
            firebase_admin.initialize_app()
        self.db = firestore.client()

    def verify_token(self, auth_header: Optional[str]) -> User:
        """
        Проверяет токен из заголовка Authorization.
        Если токена нет или он невалиден, возвращает анонимного пользователя.
        """
        if not auth_header or not auth_header.startswith('Bearer '):
            # Генерируем временный ID для анонима, если заголовка нет
            return User(uid=f"anonymous_{os.urandom(4).hex()}", is_anonymous=True)

        token = auth_header.split('Bearer ')[1]
        
        try:
            decoded_token = auth.verify_id_token(token)
            # Проверяем провайдера в метаданных Firebase
            is_anon = decoded_token.get('firebase', {}).get('sign_in_provider') == 'anonymous'
            
            return User(
                uid=decoded_token['uid'], 
                email=decoded_token.get('email'),
                is_anonymous=is_anon
            )
        except Exception:
            # В случае ошибки токена (истек или подделан) откатываемся к анонимному доступу
            return User(uid=f"guest_{os.urandom(4).hex()}", is_anonymous=True)

    async def get_user_profile(self, user_id: str) -> dict:
        """Получает данные профиля пользователя из коллекции 'users'."""
        doc_ref = self.db.collection('users').document(user_id)
        doc = doc_ref.get()
        if doc.exists:
            profile = doc.to_dict()
            # Преобразуем объекты datetime в строки ISO для корректной передачи в JSON
            for k, v in profile.items():
                if isinstance(v, datetime.datetime):
                    profile[k] = v.isoformat()
            return profile
        return {}

    async def update_user_profile(self, user_id: str, data: dict) -> dict:
        """Обновляет или создает профиль пользователя в Firestore."""
        user_ref = self.db.collection('users').document(user_id)
        user_ref.set(data, merge=True)
        return data

    async def save_fcm_token(self, user_id: str, fcm_token: str) -> dict:
        """Регистрирует токен устройства для отправки пуш-уведомлений."""
        token_ref = self.db.collection('users').document(user_id).collection('fcm_tokens').document(fcm_token)
        token_ref.set({'updated_at': firestore.SERVER_TIMESTAMP}, merge=True)
        return {"status": "success"}

# --- 3. Сервис для работы с Vertex AI Search (RAG) ---

class VertexAISearchService:
    def __init__(self, project_id: str, location: str):
        self.project_id = project_id
        self.location = location
        self.client = discoveryengine.SearchServiceClient()
        # Приоритетный ID хранилища из файла .env
        self.default_data_store_id = os.environ.get("VASC_DATA_STORE_ID")

    def ask(self, query: str, data_store_id: Optional[str] = None, user_id_for_filter: Optional[str] = None) -> dict:
        """
        Выполняет RAG-запрос: поиск по книгам + генерация ответа с цитатами.
        """
        # Логика выбора ID: приоритет у того, что прислал фронтенд, иначе берем из .env
        ds_id = data_store_id or self.default_data_store_id
        
        if not ds_id:
            raise RuntimeError("VASC_DATA_STORE_ID не найден. Проверьте файл .env")
            
        # Формируем путь к конфигурации. Для Vertex AI Search location всегда 'global'
        serving_config_path = self.client.serving_config_path(
            project=self.project_id,
            location="global",
            data_store=ds_id, # ИСПОЛЬЗУЕМ ds_id
            serving_config="default_serving_config",
        )

        # Настройка параметров саммаризации и извлечения (Grounding)
        content_search_spec = discoveryengine.SearchRequest.ContentSearchSpec(
            summary_spec=discoveryengine.SearchRequest.ContentSearchSpec.SummarySpec(
                summary_result_count=3,
                include_citations=True, # Включаем ссылки на источники
            ),
            extractive_content_spec=discoveryengine.SearchRequest.ContentSearchSpec.ExtractiveContentSpec(
                max_extractive_answer_count=1
            )
        )
        
        # Если в будущем вы добавите метаданные user_id к документам, этот фильтр сработает
        request_filter = f'user_id:"{user_id_for_filter}"' if user_id_for_filter else ""

        request = discoveryengine.SearchRequest(
            serving_config=serving_config_path,
            query=query,
            page_size=3,
            content_search_spec=content_search_spec,
            filter=request_filter,
            query_expansion_spec=discoveryengine.SearchRequest.QueryExpansionSpec(
                condition=discoveryengine.SearchRequest.QueryExpansionSpec.Condition.AUTO,
            ),
        )

        try:
            response = self.client.search(request=request)
            
            # Извлекаем сгенерированный текст ответа
            summary = response.summary.summary_text if response.summary else "Извините, я не нашел ответа в ваших книгах."
            
            # Собираем список документов, которые использовал AI
            source_documents = []
            for result in response.results:
                doc_meta = result.document.derived_struct_data
                source_documents.append({
                    "id": result.document.id,
                    "title": doc_meta.get("title", "Документ без заголовка"),
                    "link": doc_meta.get("link", "") # Ссылка на GCS или метаданные
                })

            return {
                "answer": summary,
                "source_documents": source_documents,
            }
            
        except GoogleAPICallError as e:
            raise RuntimeError(f"Ошибка Vertex AI (API): {e.message}")
        except Exception as e:
            raise RuntimeError(f"Техническая ошибка поиска: {str(e)}")

# --- 4. Сервис для работы с платежами ---

class BillingService:
    def __init__(self):
        self.db = firestore.client()

    async def process_google_pay_token(self, user_id: str, payment_token: str, product_id: str) -> dict:
        """
        Логика подтверждения покупки и активации премиум-функций.
        """
        # Здесь будет вызов Google Play Developer API для проверки токена
        is_token_valid = True 
        
        if not is_token_valid:
            return {"status": "error", "message": "Платеж не подтвержден Google Play."}

        user_ref = self.db.collection("users").document(user_id)
        
        try:
            # Используем транзакцию для надежности
            @firestore.transactional
            def update_subscription_in_transaction(transaction, ref):
                transaction.update(ref, {
                    "subscription_status": "active",
                    "premium_until": datetime.datetime.now() + datetime.timedelta(days=30),
                    "product_id": product_id,
                    "last_payment_at": firestore.SERVER_TIMESTAMP,
                })

            update_subscription_in_transaction(self.db.transaction(), user_ref)
            return {"status": "success", "message": f"Доступ к '{product_id}' успешно открыт!"}

        except Exception as e:
            return {"status": "error", "message": f"Ошибка БД при активации: {str(e)}"}
            