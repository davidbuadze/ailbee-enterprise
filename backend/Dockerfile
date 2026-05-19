FROM python:3.11-slim

WORKDIR /workspace

ENV PYTHONUNBUFFERED=1

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

# Копируем всё содержимое папки backend (включая config.py) внутрь контейнера
COPY . .

# Запускаем main:app напрямую, так как main.py теперь лежит в корне контейнера (/workspace)
CMD ["sh", "-c", "uvicorn main:app --host 0.0.0.0 --port ${PORT}"]
