# Dockerfile
# Контейнеризация консолидированного бэкенда Ailbee Enterprise Hub v3.3.0

# Используем официальный легковесный образ Python
FROM python:3.11-slim

# Предотвращает запись Python файлов кэша (.pyc) на виртуальный диск контейнера
ENV PYTHONDONTWRITEBYTECODE=1

# Отключает буферизацию потоков вывода. Логи FastAPI мгновенно отправляются в Cloud Run Logs
ENV PYTHONUNBUFFERED=1

# Установка системных зависимостей для корректной работы библиотек
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libgomp1 \
    && rm -rf /var/lib/apt/lists/*

# Установка рабочей директории в контейнере
WORKDIR /app

# Копирование файла зависимостей
COPY requirements.txt .

# Установка зависимостей без кэширования для уменьшения размера образа
RUN pip install --no-cache-dir -r requirements.txt

# Копирование всего исходного кода бэкенда в контейнер
COPY . .

# Открываем порт 8080 (стандарт для Cloud Run)
EXPOSE 8080

# Команда для запуска приложения с использованием uvicorn
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080"]
