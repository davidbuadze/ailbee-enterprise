# Dockerfile
# Use the official Python 3.12 slim image
FROM python:3.12-slim

# Установка переменных окружения
ENV PYTHONUNBUFFERED True

# Set the working directory in the container
WORKDIR /app

# Copy requirements.txt and install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code
COPY . /app

# Expose the port that FastAPI will run on (Cloud Run expects 8080 by default)
EXPOSE 8080

# Command to run the application using uvicorn
# This is the standard way to run FastAPI applications.
CMD exec uvicorn main:app --host 0.0.0.0 --port ${PORT:-8080}