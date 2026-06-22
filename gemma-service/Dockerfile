FROM ollama/ollama:latest

# Переключаем Ollama на порт Cloud Run
ENV OLLAMA_HOST=0.0.0.0:8080
# Отключаем логирование отладки GPU, так как сборка идет на CPU
ENV OLLAMA_NOPRUNE=1

# Увеличиваем sleep до 15 секунд и скачиваем быструю CPU-оптимизированную модель gemma2:2b
RUN apt-get update && apt-get install -y curl && \
    ollama serve & \
    sleep 15 && \
    ollama pull gemma2:2b && \
    pkill ollama

EXPOSE 8080

ENTRYPOINT ["ollama", "serve"]
