import os
import datetime
import firebase_admin
import asyncio
from firebase_admin import auth, firestore
from pydantic import BaseModel
from typing import Optional, List, Dict, Set

from google.cloud import discoveryengine_v1 as discoveryengine
from google.api_core.exceptions import GoogleAPICallError

# --- 1. Модели данных ---

class User(BaseModel):
    """Модель для внутреннего представления пользователя."""
    uid: str
    email: Optional[str] = None
    is_anonymous: bool

class UnifiedSearchResponse(BaseModel):
    """Модель ответа междисциплинарного исследования."""
    answer: str
    relevant_subjects: List[str]
    context_data: Dict[str, str]
    sources: List[Dict] = []

# --- 2. Сервис для работы с Firebase (Auth и Firestore) ---

class FirebaseService:
    def __init__(self):
        try:
            firebase_admin.get_app()
        except ValueError:
            # Инициализация Firebase Admin SDK (Singleton)
            firebase_admin.initialize_app()
        self.db = firestore.client()

    def verify_token(self, auth_header: Optional[str]) -> User:
        """
        Проверяет токен из заголовка Authorization.
        Если токена нет или он невалиден, возвращает временного анонимного пользователя.
        """
        # Если заголовок отсутствует или некорректен
        if not auth_header or not auth_header.startswith('Bearer '):
            return User(uid=f"guest_{os.urandom(4).hex()}", is_anonymous=True)

        token = auth_header.split('Bearer ')[1]
        
        try:
            # Верификация токена через Firebase Admin SDK
            decoded_token = auth.verify_id_token(token)
            
            # Проверяем провайдера в метаданных (поддержка Anonymous Auth в Firebase)
            is_anon = decoded_token.get('firebase', {}).get('sign_in_provider') == 'anonymous'
            
            return User(
                uid=decoded_token['uid'], 
                email=decoded_token.get('email'),
                is_anonymous=is_anon
            )
        except Exception:
            # В случае ошибки (истекший токен и т.д.) не прерываем работу, 
            # а откатываемся к гостевому доступу
            return User(uid=f"guest_{os.urandom(4).hex()}", is_anonymous=True)

    async def get_user_profile(self, user_id: str) -> dict:
        """
        Получает данные профиля пользователя из коллекции 'users'.
        Метод async для интеграции в FastAPI, хотя SDK работает синхронно.
        """
        try:
            doc_ref = self.db.collection('users').document(user_id)
            doc = doc_ref.get() # Синхронный вызов в Firebase Admin
            if doc.exists:
                profile = doc.to_dict()
                # Конвертация дат в ISO формат для JSON-сериализации
                for k, v in profile.items():
                    if isinstance(v, datetime.datetime):
                        profile[k] = v.isoformat()
                return profile
            return {}
        except Exception as e:
            print(f"Firestore Error: {e}")
            return {}

    async def update_user_profile(self, user_id: str, data: dict) -> dict:
        """Обновляет или создает профиль пользователя в Firestore."""
        user_ref = self.db.collection('users').document(user_id)
        # merge=True позволяет обновлять только присланные поля
        user_ref.set(data, merge=True)
        return data

    async def save_fcm_token(self, user_id: str, fcm_token: str) -> dict:
        """Регистрирует токен устройства для пуш-уведомлений."""
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

# --- 4. Диспетчер Единства Природы (Unified Research Service) ---

class UnifiedResearchService:
    def __init__(self, project_id: str):
        self.project_id = project_id
        self.client = discoveryengine.SearchServiceClient()
        
        # Карта всех предметных хранилищ (Data Stores)
        self.subjects_map = {
            "physics": "physics-store",
            "math": "math-store",
            "chemistry": "chemistry-store",
            "biology": "biology-store",
            "geography": "geography-store",
            "it": "it-meta-store",
            "languages": "languages-meta-store"
        }
        
        # Ключевые слова для автоматического роутинга (упрощенно)
        self.keywords = {
            "physics": ["сила", "энергия", "квант", "давление", "движение", "атом", "диффузия"],
            "math": ["формула", "уравнение", "график", "функция", "модель", "дифференциал"],
            "biology": ["клетка", "организм", "жизнь", "дыхание", "фотосинтез", "белок"],
            "chemistry": ["реакция", "молекула", "элемент", "связь", "вещество"],
            "geography": ["земля", "планета", "климат", "атмосфера", "рельеф"]
        }

    def _get_relevant_stores(self, query: str) -> Set[str]:
        """Определяет, какие предметы (Data Stores) нужны для ответа."""
        query_lower = query.lower()
        relevant = {"physics"} # Физика всегда в приоритете как фундамент
        
        for subject, keywords in self.keywords.items():
            if any(kw in query_lower for kw in keywords):
                relevant.add(subject)
        
        return {self.subjects_map[s] for s in relevant if s in self.subjects_map}

    async def _search_in_store_async(self, query: str, store_id: str) -> Dict:
        """Асинхронный поиск в конкретном хранилище."""
        serving_config = self.client.serving_config_path(
            project=self.project_id,
            location="global",
            data_store=store_id,
            serving_config="default_serving_config",
        )

        content_spec = discoveryengine.SearchRequest.ContentSearchSpec(
            summary_spec=discoveryengine.SearchRequest.ContentSearchSpec.SummarySpec(
                summary_result_count=2,
                include_citations=True
            )
        )

        request = discoveryengine.SearchRequest(
            serving_config=serving_config,
            query=query,
            page_size=2,
            content_search_spec=content_spec
        )

        try:
            # Выполняем поиск (в реальном коде используем асинхронный клиент)
            response = self.client.search(request=request)
            return {
                "store": store_id,
                "text": response.summary.summary_text if response.summary else ""
            }
        except Exception as e:
            return {"store": store_id, "text": f"Ошибка поиска: {str(e)}"}

    async def research_unified(self, query: str) -> UnifiedSearchResponse:
        """
        Главный метод синтеза: опрашивает связанные дисциплины и объединяет знания.
        """
        target_stores = self._get_relevant_stores(query)
        
        # Параллельный запуск поиска по всем релевантным базам
        tasks = [self._search_in_store_async(query, sid) for sid in target_stores]
        results = await asyncio.gather(*tasks)

        context_data = {res["store"]: res["text"] for res in results}
        
        # Формирование "Синтезированного ответа"
        # На следующем этапе здесь добавится вызов Gemini 1.5 Pro для финального склеивания
        final_answer = f"Результаты междисциплинарного исследования:\n"
        for store, text in context_data.items():
            subj_name = [name for name, sid in self.subjects_map.items() if sid == store][0]
            final_answer += f"\n--- [{subj_name.upper()}] ---\n{text}\n"

        return UnifiedSearchResponse(
            answer=final_answer,
            relevant_subjects=list(target_stores),
            context_data=context_data,
            sources=[{"store": s, "status": "processed"} for s in target_stores]
        )

# --- 5. Сервис для работы с платежами ---

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
            