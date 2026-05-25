import os
import uuid
from typing import Optional, Tuple, List
from google.cloud import discoveryengine_v1alpha as discoveryengine
from google.cloud import dialogflowcx_v3 as dialogflow
from google.api_core.exceptions import GoogleAPICallError

class VertexAgentService:
    def __init__(self):
        """Инициализация двух независимых SDK-клиентов Google Cloud."""
        self.project_id = os.environ.get("GCP_PROJECT_ID", "ailbee")
        self.location = os.environ.get("GCP_LOCATION", "global")
        
        # Клиент А: Для поискового RAG по книгам (Discovery Engine)
        self.search_client = discoveryengine.ConversationalSearchServiceClient()
        
        # Клиент Б: Для Чат-Агентов Gemini Enterprise (Dialogflow CX)
        endpoint = "global-dialogflow.googleapis.com" if self.location == "global" else f"{self.location}-dialogflow.googleapis.com"
        self.chat_client = dialogflow.SessionsClient(client_options={"api_endpoint": endpoint})

    def converse_search_rag(
        self, query: str, agent_id: str, conversation_id: Optional[str] = None
    ) -> Tuple[str, str, List[dict]]:
        """Автоматический RAG-поиск по книгам со структурированными цитатами."""
        agent_id = agent_id.strip("[] ")
        
        conversation_path = f"projects/{self.project_id}/locations/{self.location}/collections/default_collection/dataStores/{agent_id}/conversations/{conversation_id if conversation_id else '-'}"
        serving_config_path = f"projects/{self.project_id}/locations/{self.location}/collections/default_collection/dataStores/{agent_id}/servingConfigs/default_config"

        request = discoveryengine.ConverseConversationRequest(
            name=conversation_path,
            query=discoveryengine.TextInput(input=query),
            serving_config=serving_config_path
        )

        try:
            response = self.search_client.converse_conversation(request=request)
            reply_text = response.reply.summary.summary_text
            next_conversation_id = response.conversation.name.split("/")[-1]
            
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
            raise RuntimeError(f"Vertex Search API Error: {e.message} (Code: {e.code})")

    def converse_chat_agent(
        self, query: str, agent_id: str, conversation_id: Optional[str] = None
    ) -> Tuple[str, str]:
        """Свободный диалог с креативным Чат-Агентом Gemini Enterprise."""
        agent_id = agent_id.strip("[] ")
        
        session_id = conversation_id if conversation_id else str(uuid.uuid4())
        
        session_path = self.chat_client.session_path(
            project=self.project_id,
            location=self.location,
            agent=agent_id,
            session=session_id
        )

        text_input = dialogflow.TextInput(text=query)
        query_input = dialogflow.QueryInput(text=text_input, language_code="ru")
        request = dialogflow.DetectIntentRequest(session=session_path, query_input=query_input)

        try:
            response = self.chat_client.detect_intent(request=request)
            messages = response.query_result.response_messages
            reply_text = messages[0].text.text[0] if messages and messages[0].text else "Агент не вернул текстовый ответ."
            return reply_text, session_id
        except GoogleAPICallError as e:
            raise RuntimeError(f"Vertex Chat Agent API Error: {e.message} (Code: {e.code})")
            