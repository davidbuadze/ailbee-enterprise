# backend/services/vertex_agent.py
# Интеграционный адаптер для работы с Vertex AI Search (Discovery Engine RAG) и LLM

import os
from typing import Optional, Tuple, List, Dict, Any
from google.cloud import discoveryengine_v1alpha as discoveryengine
from google.api_core.exceptions import GoogleAPICallError
from config import settings

class VertexAgentService:
    def __init__(self):
        self.project_id = settings.GCP_PROJECT_ID
        self.location = settings.GCP_LOCATION
        
        endpoint = f"{self.location}-discoveryengine.googleapis.com"
        self.client = discoveryengine.ConversationalSearchServiceClient(
            client_options={"api_endpoint": endpoint}
        )

    def converse_with_gemini_enterprise(
        self, query: str, engine_id: str, conversation_id: Optional[str] = None
    ) -> Tuple[str, str, List[Dict[str, Any]]]:
        """
        Метод взаимодействия с Vertex AI Search RAG.
        Извлекает структурированный ответ и цитируемые источники.
        """
        clean_engine = engine_id.strip("[] ")
        conv_id_path = "-"
        
        if conversation_id:
            clean_id = conversation_id.strip("[] \"'")
            if clean_id and "conversation_id" not in clean_id and clean_id != "null" and clean_id != "":
                conv_id_path = clean_id

        # Формирование полного пути к диалогу
        conversation_path = f"projects/{self.project_id}/locations/{self.location}/collections/default_collection/engines/{clean_engine}/conversations/{conv_id_path}"

        request = discoveryengine.ConverseConversationRequest(
            name=conversation_path,
            query=discoveryengine.TextInput(input=query)
        )

        try:
            response = self.client.converse_conversation(request=request)
            reply_text = response.reply.summary.summary_text
            next_conversation_id = response.conversation.name.split("/")[-1]
            
            citations = []
            if hasattr(response, "search_results") and response.search_results:
                for result in response.search_results:
                    doc = getattr(result, "document", None)
                    if not doc:
                        continue
                    
                    derived = getattr(doc, "derived_struct_data", {})
                    struct = getattr(doc, "struct_data", {})
                    data = derived if derived else struct
                    
                    if hasattr(data, "get"):
                        title = data.get("title", getattr(doc, "id", "Книга"))
                        uri = data.get("link", "")
                        
                        text_segment = ""
                        snippets = data.get("extractive_snippets", data.get("snippets", []))
                        if snippets and isinstance(snippets, list) and len(snippets) > 0:
                            if isinstance(snippets[0], dict):
                                text_segment = snippets[0].get("snippet", "")
                            else:
                                text_segment = str(snippets[0])
                        
                        citations.append({
                            "source_title": str(title),
                            "uri": str(uri),
                            "text_segment": str(text_segment)
                        })
            
            return reply_text, next_conversation_id, citations

        except GoogleAPICallError as e:
            raise RuntimeError(f"Vertex AI Search Error: {e.message} (Code: {e.code})")
            