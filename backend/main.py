# backend/main.py
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

# Импортируем наши настройки и роутер
from config import settings
from api.chat import router as chat_router
from api.search import router as search_router

# --- 1. Инициализация FastAPI ---
app = FastAPI(
    title="Ailbee Enterprise Hub",
    description="Оркестратор междисциплинарных связей на базе Vertex AI Agent Builder",
    version="3.1.0"
)

# --- 2. Настройка CORS (Cross-Origin Resource Sharing) ---
# Это важнейшая настройка безопасности. Она говорит серверу: 
# "Отвечай только на запросы, которые пришли из приложения FlutterFlow"
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],  # Разрешаем все методы (GET, POST и т.д.)
    allow_headers=["*"],  # Разрешаем все заголовки (включая Authorization)
)

# --- 3. Подключение модулей (Роутеров) ---
# Мы подключаем наш модуль чата и задаем ему префикс.
# Теперь эндпоинт из chat.py будет доступен по адресу: /api/v3/chat/converse
app.include_router(chat_router, prefix="/api/v3/chat", tags=["Creative Agent"])
app.include_router(search_router, prefix="/api/v3/search", tags=["Academic RAG Search"])
# app.include_router(quiz_router, prefix="/api/v3/quiz")
# Мы обеспечили этим кодом:
# Модульность: Обратите внимание на app.include_router. Когда вы решите добавить новый модуль
# (например, quiz.py для тестирования студентов), ваш main.py практически не изменится.
# Вы просто добавите одну строчку: app.include_router(quiz_router, prefix="/api/v3/quiz").
# Это признак чистого кода.
# Версионирование: (/api/v3/): Мы заложили в адресную строку версию API.
# Если через год вы кардинально измените логику ИИ, вы сделаете версию v4, и старые приложения
# у студентов не сломаются, так как они продолжат обращаться к v3.
# Мониторинг: Эндпоинт / возвращает status: online. Это стандарт индустрии.
# Панель управления Google Cloud будет использовать его, чтобы рисовать красивые зеленые
# графики стабильности вашего сервера.

# --- 4. Системный эндпоинт (Health Check) ---
# Этот маршрут нужен для Google Cloud Run. Облако будет периодически
# "стучаться" сюда, чтобы проверить, что ваш бэкенд жив и не завис.
@app.get("/", summary="Health Check", tags=["System"])
def read_root():
    return {
        "status": "online", 
        "service": "Ailbee Enterprise Hub",
        "version": app.version,
        "project": settings.GCP_PROJECT_ID
    }

# --- 5. Локальный запуск (Только для тестов в JetBrains) ---
if __name__ == "__main__":
    import uvicorn
    # При запуске через облако (Cloud Run), uvicorn запускается снаружи контейнера.
    # Этот блок сработает, только если вы нажмете кнопку "Run" прямо в IntelliJ IDEA.
    uvicorn.run("main:app", host="0.0.0.0", port=settings.PORT, reload=True)
