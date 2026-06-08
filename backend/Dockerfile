FROM python:3.11-slim

WORKDIR /workspace

ENV PYTHONUNBUFFERED=1

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

# Копируем всё содержимое папки backend (включая config.py и подпапки) внутрь контейнера
COPY . .

# Запускаем uvicorn напрямую из корня контейнера
CMD ["sh", "-c", "uvicorn main:app --host 0.0.0.0 --port ${PORT}"]

# Указываем Cloud Build, куда сохранять логи сборки этого контейнера
LABEL com.google.cloudbuild.logs_bucket="gs://ailbee-cloudbuild-logs"
