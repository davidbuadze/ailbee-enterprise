# app/services/vertex_agent.py
import os
from typing import Optional, Tuple, List
from google.cloud import discoveryengine_v1alpha as discoveryengine
from google.api_core.exceptions import GoogleAPICallError

class VertexAgentService:
    def __init__(self):
        """
        Инициализация сервиса. Переменные окружения считываются динамически,
        что упрощает деплой в Google Cloud Run.
        """
        self.project_id = os.environ.get("GCP_PROJECT_ID", "ailbee")
        # Для Agent Builder / Discovery Engine по умолчанию используется локация global
        self.location = os.environ.get("GCP_LOCATION", "global")
        self.client = discoveryengine.ConversationalSearchServiceClient()

    def _get_serving_config_path(self, data_store_id: str) -> str:
        """Вспомогательный метод для сборки пути к конфигурации Агента."""
        return self.client.serving_config_path(
            project=self.project_id,
            location=self.location,
            data_store=data_store_id,
            serving_config="default_config"
        )

    def converse(
        self, 
        query: str, 
        data_store_id: str, 
        conversation_id: Optional[str] = None
    ) -> Tuple[str, str, List[dict]]:
        """
        Основной метод оркестрации диалога со специализированным Агентом.
        
        Args:
            query: Вопрос студента (например, междисциплинарный запрос).
            data_store_id: Идентификатор базы знаний Агента в Google Cloud.
            conversation_id: ID существующей сессии. Если None — Google создаст новую.
            
        Returns:
            Tuple содержащий:
            - reply_text (str): Очищенный ответ от Gemini Enterprise.
            - next_conversation_id (str): ID сессии (нужно вернуть во FlutterFlow для продолжения чата).
            - citations (list): Список первоисточников (книг) с метаданными, на основе которых дан ответ.
        """
        serving_config_path = self._get_serving_config_path(data_store_id)

        # Если мы продолжаем старую беседу, собираем полный путь к ней
        if conversation_id:
            conversation_name = self.client.conversation_path(
                project=self.project_id,
                location=self.location,
                data_store=data_store_id,
                conversation=conversation_id
            )
            # Создаем запрос в рамках существующего контекста
            request = discoveryengine.ConverseConversationRequest(
                name=serving_config_path,
                query=discoveryengine.TextInput(input=query),
                conversation=conversation_name
            )
        else:
            # Создаем запрос для новой сессии
            request = discoveryengine.ConverseConversationRequest(
                name=serving_config_path,
                query=discoveryengine.TextInput(input=query)
            )

        try:
            # Отправка запроса в ядро Gemini Enterprise Agent Platform
            response = self.client.converse_conversation(request=request)
            
            # 1. Извлекаем текст ответа (сгенерированное суммаризированное заключение)
            reply_text = response.reply.summary.summary_text
            
            # 2. Получаем ID сессии (Google возвращает полный путь, мы забираем только финальный ID)
            next_conversation_name = response.conversation.name
            next_conversation_id = next_conversation_name.split("/")[-1]
            
            # 3. Извлекаем цитаты и привязку к первоисточникам (Grounding)
            citations = []
            if response.reply.summary.summary_with_metadata:
                metadata = response.reply.summary.summary_with_metadata
                for citation_entry in metadata.citation_entries:
                    # Собираем данные о документах, которые ИИ использовал для ответа
                    citations.append({
                        "source_title": citation_entry.title,
                        "uri": citation_entry.uri,
                        "text_segment": citation_entry.text # конкретный кусок из книги
                    })

            return reply_text, next_conversation_id, citations

        except GoogleAPICallError as e:
            # Промышленная обработка ошибок API Google
            raise RuntimeError(f"Vertex AI Agent API Error: {e.message} (Code: {e.code})")
        except Exception as e:
            raise RuntimeError(f"Unexpected error in VertexAgentService: {str(e)}")
            