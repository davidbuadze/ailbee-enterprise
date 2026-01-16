import os
import json
import base64
import logging
import firebase_admin
from fastapi import FastAPI, Request, HTTPException
from firebase_admin import firestore, initialize_app
from google.cloud import discoveryengine_v1 as discoveryengine

# Настройка логирования
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# --- ГЛОБАЛЬНЫЙ КЭШ ДЛЯ КЛИЕНТОВ (Warm Start) ---
_db_client = None
_doc_client = None
_parent_resource = None
_VASC_CONFIG = {}

def initialize_clients_and_config():
    """Инициализация клиентов один раз при запуске контейнера (без functions_framework)."""
    global _db_client, _doc_client, _parent_resource, _VASC_CONFIG

    if _doc_client is not None and _VASC_CONFIG:
        return
    
    if not _VASC_CONFIG:
        _VASC_CONFIG = {
            "PROJECT_ID": os.environ.get("GCP_PROJECT_ID", "ailbee"),
            "LOCATION": os.environ.get("VASC_LOCATION", "global"),
            "DATA_STORE_ID": os.environ.get("VASC_DATA_STORE_ID", "ailbee-books-data-store_001"),
        }
        if not _VASC_CONFIG["PROJECT_ID"]:
             raise ValueError("Переменная окружения GCP_PROJECT_ID не установлена.")

    project_id = _VASC_CONFIG["PROJECT_ID"]

    # Инициализация Firebase Admin
    if not firebase_admin._apps:
        initialize_app()
    
    if _db_client is None:
        _db_client = firestore.client()
        logger.info("Клиент Firestore кэширован.")

    # Инициализация Discovery Engine Client
    if _doc_client is None:
        _doc_client = discoveryengine.DocumentServiceClient()
        _parent_resource = _doc_client.data_store_path(
            project=project_id,
            location=_VASC_CONFIG["LOCATION"],
            data_store=_VASC_CONFIG["DATA_STORE_ID"],
        )
        logger.info("Клиент Vertex AI Search кэширован.")

# --- Инициализация FastAPI ---
app = FastAPI(title="Ailbee Indexing Worker")

@app.get("/")
async def health_check():
    return {"status": "alive"}

@app.post("/index-book")
async def handle_indexing(request: Request):
    """
    Обработчик POST-запросов. Принимает сигнал о новом файле и запускает импорт.
    """
    try:
        initialize_clients_and_config()
        
        # 1. Получение данных из Pub/Sub
        envelope = await request.json()
        
        if envelope.get("message") and envelope["message"].get("data"):
            data_str = base64.b64decode(envelope["message"]["data"]).decode("utf-8")
            payload = json.loads(data_str)
        else:
            payload = envelope

        book_id = payload.get("book_id")
        gcs_uri = payload.get("gcs_uri")
        user_id = payload.get("user_id")

        # Если URI не передан явно (например, прямой триггер GCS)
        if not gcs_uri:
            bucket = payload.get("bucket")
            name = payload.get("name")
            if bucket and name:
                gcs_uri = f"gs://{bucket}/{name}"
            else:
                return {"status": "ignored", "reason": "No valid GCS URI found"}

        logger.info(f"Инициирована индексация: {gcs_uri}")

        # 2. Обновление статуса в Firestore
        if user_id and book_id:
            book_ref = _db_client.collection('user_book_status').document(user_id).collection('books').document(book_id)
            book_ref.update({
                "vasc_indexing_status": "INDEXING_STARTED",
                "updated_at": firestore.SERVER_TIMESTAMP
            })

        # 3. Запуск импорта в Vertex AI Search
        # Мы НЕ ждем завершения операции здесь, чтобы не блокировать воркер
        gcs_source = discoveryengine.GcsSource(
            input_uris=[gcs_uri],
            data_schema="document",
        )

        import_request = discoveryengine.ImportDocumentsRequest(
            parent=_parent_resource,
            gcs_source=gcs_source,
            reconciliation_mode=discoveryengine.ImportDocumentsRequest.ReconciliationMode.INCREMENTAL
        )

        # Выполняем асинхронный вызов API
        operation = _doc_client.import_documents(request=import_request)
        
        logger.info(f"LRO операция создана в Google Cloud: {operation.operation.name}")

        # Обновляем Firestore именем операции для возможности отслеживания в будущем
        if user_id and book_id:
             book_ref.update({"vasc_operation_id": operation.operation.name})

        return {
            "status": "success", 
            "operation_id": operation.operation.name
        }

    except Exception as e:
        logger.error(f"Ошибка в работе воркера: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    # Cloud Run слушает порт 8080 по умолчанию
    port = int(os.environ.get("PORT", 8080))
    # Для продакшена используем строковую ссылку "main:app" и настраиваем логи
    uvicorn.run("main:app", host="0.0.0.0", port=port, log_level="info")
    