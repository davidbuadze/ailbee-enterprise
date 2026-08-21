import firebase_admin
from firebase_admin import credentials, firestore

# 1. Авторизация в Firebase через сервисный ключ
cred = credentials.Certificate("serviceAccountKey.json")
firebase_admin.initialize_app(cred)

db = firestore.client()


def create_tasks_structure():
    # 2. Создание структуры коллекции 'tasks' с шаблонной записью
    doc_ref = db.collection("tasks").document("_schema_template")

    doc_ref.set(
        {
            "title": "Пример названия задачи",
            "due_date": firestore.SERVER_TIMESTAMP,
            "is_completed": False,
            "calendar_event_id": "000000",
            "created_at": firestore.SERVER_TIMESTAMP,
            "user_ref": db.document("users/placeholder"),
        }
    )

    print("Коллекция 'tasks' успешно инициализирована в Firestore!")


if __name__ == "__main__":
    create_tasks_structure()
    