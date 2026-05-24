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
        self.location = os.environ.get("GCP_LOCATION", "global")
        self.client = discoveryengine.ConversationalSearchServiceClient()

    def converse(
        self, 
        query: str, 
        agent_id: str, 
        conversation_id: Optional[str] = None
    ) -> Tuple[str, str, List[dict]]:
        """
        Основной метод оркестрации диалога со специализированным Агентом.
        
        Args:
            query: Вопрос студента.
            agent_id: Идентификатор базы знаний Агента in Google Cloud.
            conversation_id: ID существующей сессии. Если None — создается новая беседа.
        """
        # ЗАЩИТА ОТ ОПЕЧАТОК: Автоматически удаляем квадратные скобки, если они прилетели из фронтенда
        agent_id = agent_id.strip("[] ")
        
        # 1. Сборка пути к беседе (используем dataStores для совместимости с внутренним контуром)
        conversation_path = f"projects/{self.project_id}/locations/{self.location}/collections/default_collection/dataStores/{agent_id}/conversations/{conversation_id if conversation_id else '-'}"

        # 2. Путь к конфигурации (СТРОГО dataStores, как потребовала ошибка в логе)
        serving_config_path = f"projects/{self.project_id}/locations/{self.location}/collections/default_collection/dataStores/{agent_id}/servingConfigs/default_config"

        # 3. Подготовка текстового ввода
        text_input = discoveryengine.TextInput(input=query)

        # 4. Собираем объект запроса
        request = discoveryengine.ConverseConversationRequest(
            name=conversation_path,
            query=text_input,
            serving_config=serving_config_path
        )

        try:
            # Отправка запроса в ядро Gemini Enterprise Agent Platform
            response = self.client.converse_conversation(request=request)
            
            # Извлекаем текст ответа
            reply_text = response.reply.summary.summary_text
            
            # Получаем ID сессии
            next_conversation_name = response.conversation.name
            next_conversation_id = next_conversation_name.split("/")[-1]
            
            # Извлекаем цитаты
            citations = []
            if response.reply.summary.summary_with_metadata:
                metadata = response.reply.summary.summary_with_metadata
                for citation_entry in metadata.citation_entries:
                    citations.append({
                        "source_title": citation_entry.title,
                        "uri": citation_entry.uri,
                        "text_segment": citation_entry.text 
                    })

            return reply_text, next_conversation_id, citations

        except GoogleAPICallError as e:
            raise RuntimeError(f"Vertex AI Agent API Error: {e.message} (Code: {e.code})")
        except Exception as e:
            raise RuntimeError(f"Ошибка при обработке ответа Vertex API: {str(e)}")
            