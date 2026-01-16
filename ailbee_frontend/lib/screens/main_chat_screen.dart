import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/api_service.dart';
import '../screens/document_list.dart';
import 'document_upload_screen.dart';

class MainChatScreen extends StatefulWidget {
  const MainChatScreen({super.key});

  @override
  State<MainChatScreen> createState() => _MainChatScreenState();
}

class _MainChatScreenState extends State<MainChatScreen> {
  // Список сообщений для отображения
  final List<AgentChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  
  // Future для данных о биллинге и документах
  late Future<BillingStatus> _billingStatusFuture;
  late Future<List<UserDocument>> _documentsFuture;
  
  // НОВОЕ ПОЛЕ: ID хранилища данных VASC для RAG.
  // В рабочем проекте это должно загружаться или быть константой.
  // Используем заглушку, которая совпадает с ожиданием бэкенда.
  final String _vascDataStoreId = 'my-ailbee-rag-store';

  // Экземпляр ApiService
  late ApiService _apiService;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService(); 
    // Загружаем данные при инициализации
    _fetchInitialData();
  }

  void _fetchInitialData() {
    setState(() {
      _billingStatusFuture = _apiService.getFreeLimitStatus();
      _documentsFuture = _apiService.getUserDocuments();
    });
  }

  void _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    
    _textController.clear();
    
    // Добавляем сообщение пользователя
    setState(() {
      _messages.add(AgentChatMessage(
        sender: 'user', 
        message: text, 
        timestamp: DateTime.now(),
      ));
    });

    try {
      // ИСПРАВЛЕНО: Вызываем sendChatMessage с НОВЫМ обязательным параметром vascDataStoreId.
      final response = await _apiService.sendChatMessage(
        message: text,
        // *** НОВОЕ: Передаем ID хранилища данных VASC ***
        vascDataStoreId: _vascDataStoreId, 
      );
      
      final agentResponse = response['response'] as String? ?? 'Произошла ошибка в ответе агента.';
      final conversationId = response['conversationId'] as String? ?? 'new';
      
      // Бэкенд теперь возвращает 'response' и 'conversationId' (как в main.py)

      // Добавляем ответ агента
      setState(() {
        _messages.add(AgentChatMessage(
          sender: 'agent', 
          message: agentResponse, 
          timestamp: DateTime.now(),
        ));
        TODO: В реальном приложении, если conversationId == 'new', его нужно сохранить
      });

    } on ApiServiceException catch (e) {
      // Отображение API-ошибки в чате
      _showApiError(e);
    } on NetworkException catch (e) {
      // Отображение сетевой ошибки
      _showNetworkError(e);
    } catch (e) {
      // Общая ошибка
      _showGenericError(e);
    }
  }

  void _showApiError(ApiServiceException e) {
    setState(() {
      _messages.add(AgentChatMessage(
        sender: 'system', 
        message: '🚫 API Error (${e.statusCode}): ${e.message}', 
        timestamp: DateTime.now(),
      ));
    });
  }
  
  void _showNetworkError(NetworkException e) {
    setState(() {
      _messages.add(AgentChatMessage(
        sender: 'system', 
        message: '🔌 Network Error: ${e.message}', 
        timestamp: DateTime.now(),
      ));
    });
  }
  
  void _showGenericError(dynamic e) {
    setState(() {
      _messages.add(AgentChatMessage(
        sender: 'system', 
        message: '❌ Unknown Error: ${e.toString()}', 
        timestamp: DateTime.now(),
      ));
    });
  }

  // --- UI Components ---
  
  Widget _buildBillingStatus() {
    return FutureBuilder<BillingStatus>(
      future: _billingStatusFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Text('Загрузка статуса биллинга...'));
        }
        if (snapshot.hasError) {
          return Text('Ошибка загрузки биллинга: ${snapshot.error.toString()}', style: TextStyle(color: Colors.red));
        }
        if (snapshot.hasData) {
          final status = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Лимит LLM: ${status.freeLimitRemaining} запросов',
              style: TextStyle(
                color: status.isPremiumUser ? Colors.green.shade700 : Colors.orange.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildDocumentSection() {
    return FutureBuilder<List<UserDocument>>(
      future: _documentsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(),
          ));
        }
        if (snapshot.hasError) {
          return Text('Ошибка загрузки документов: ${snapshot.error.toString()}', style: TextStyle(color: Colors.red));
        }
        if (snapshot.hasData) {
          return DocumentList(documents: snapshot.data!);
        }
        return const SizedBox.shrink();
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ailbee Agent Chat'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            tooltip: 'Загрузить документ',
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const DocumentUploadScreen(),
              ));
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Обновить статусы',
            onPressed: _fetchInitialData,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Выйти',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          // Секция статуса биллинга
          _buildBillingStatus(),
          
          // Секция списка документов (для RAG контекста)
          _buildDocumentSection(),
          
          // Разделитель
          const Divider(height: 1),

          // Список сообщений чата
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              reverse: true, // Снизу вверх
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[_messages.length - 1 - index]; // Правильный порядок
                return _ChatMessageBubble(message: message);
              },
            ),
          ),
          
          // Поле ввода сообщения
          const Divider(height: 1),
          Container(
            decoration: BoxDecoration(color: Theme.of(context).cardColor),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration.collapsed(
                        hintText: 'Отправить сообщение агенту...',
                      ),
                      maxLines: null, // Позволяет вводить несколько строк
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _sendMessage,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Вспомогательный виджет для отображения пузырька сообщения
class _ChatMessageBubble extends StatelessWidget {
  final AgentChatMessage message;

  const _ChatMessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.sender == 'user';
    final isSystem = message.sender == 'system';
    
    final alignment = isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final color = isUser ? Colors.blue.shade100 : (isSystem ? Colors.red.shade100 : Colors.grey.shade200);
    final textColor = isSystem ? Colors.red.shade900 : Colors.black;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: alignment,
        children: <Widget>[
          Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: isUser ? const Radius.circular(16) : const Radius.circular(4),
                bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(16),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Text(
              message.message,
              style: TextStyle(color: textColor),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4.0, right: 8.0, left: 8.0),
            child: Text(
              isSystem ? 'Система' : (isUser ? 'Вы' : 'Агент'),
              style: TextStyle(
                fontSize: 10.0,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
