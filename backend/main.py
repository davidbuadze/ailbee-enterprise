from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

# Чистые импорты из текущего корня контейнера
from config import settings
from api.chat import router as chat_router
from api.search import router as search_router
from routers import cron

app = FastAPI(
    title="Ailbee Enterprise Hub",
    description="Оркестратор междисциплинарных связей на базе Vertex AI Agent Builder",
    version="3.1.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(chat_router, prefix="/api/v3/chat", tags=["Creative Agent"])
app.include_router(search_router, prefix="/api/v3/search", tags=["Academic RAG Search"])
app.include_router(cron.router, prefix="/api/v3/cron", tags=["System Cron Services"])

@app.get("/", summary="Health Check", tags=["System"])
def read_root():
    return {
        "status": "online", 
        "service": "Ailbee Enterprise Hub",
        "version": app.version,
        "project": settings.GCP_PROJECT_ID
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=settings.PORT)
    