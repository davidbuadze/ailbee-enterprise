import os
from typing import Optional, Tuple, List
from google.cloud import discoveryengine_v1alpha as discoveryengine
from google.api_core.exceptions import GoogleAPICallError

class VertexAgentService:
    def __init__(self):
        self.project_id = os.environ.get("GCP_PROJECT_ID", "ailbee")
        self.location = os.environ.get("GCP_LOCATION", "global")
        
        endpoint = f"{self.location}-discoveryengine.googleapis.com"
        self.client = discoveryengine.ConversationalSearchServiceClient(
            client_options={"api_endpoint": endpoint}
        )

    def _converse_with_gemini_enterprise(
        self, query: str, engine_id: str, conversation_id: Optional[str] = None
    ) -> Tuple[str, str, List[dict]]:
        engine_id = engine_id.strip("[] ")
        
        conv_id_path = "-"
        if conversation_id:
            clean_id = conversation_id.strip("[] \"'")
            if clean_id and "conversation_id" not in clean_id and clean_id != "null" and clean_id != "":
                conv_id_path = clean_id

        conversation_path = f"projects/{self.project_id}/locations/{self.location}/collections/default_collection/engines/{engine_id}/conversations/{conv_id_path}"

        request = discoveryengine.ConverseConversationRequest(
            name=conversation_path,
            query=discoveryengine.TextInput(input=query)
        )

        try:
            response = self.client.converse_conversation(request=request)
            reply_text = response.reply.summary.summary_text
            next_conversation_id = response.conversation.name.split("/")[-1]
            
            citations = []
            try:
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
            except Exception as citation_err:
                print(f"Предупреждение: не удалось распарсить цитаты: {str(citation_err)}")

            return reply_text, next_conversation_id, citations

        except GoogleAPICallError as e:
            raise RuntimeError(f"Gemini Enterprise App Error: {e.message} (Code: {e.code})")

    def converse_search_rag(
        self, query: str, agent_id: str, conversation_id: Optional[str] = None
    ) -> Tuple[str, str, List[dict]]:
        return self._converse_with_gemini_enterprise(query, agent_id, conversation_id)

    def converse_chat_agent(
        self, query: str, agent_id: str, conversation_id: Optional[str] = None
    ) -> Tuple[str, str]:
        reply_text, next_conversation_id, _ = self._converse_with_gemini_enterprise(query, agent_id, conversation_id)
        return reply_text, next_conversation_id
        