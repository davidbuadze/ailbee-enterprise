// api_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:async';
import 'dart:io';

// --- КОНСТАНТЫ ---
// Теперь BASE_URL будет загружаться из .env. Если файл .env не загрузился 
// или переменная BACKEND_BASE_URL отсутствует, будет использован локальный адрес 
// в качестве безопасной заглушки.
final String _kBaseUrl = dotenv.env['BACKEND_BASE_URL'] ?? 'http://127.0.0.1:8000';
const Duration STATUS_POLLING_INTERVAL = Duration(seconds: 3);

// --- КАСТОМНЫЕ ИСКЛЮЧЕНИЯ ДЛЯ ЛУЧШЕЙ ОБРАБОТКИ ---
class ApiException implements Exception {
  final int statusCode;
  final String message;
  final String endpoint;

  ApiException(this.statusCode, this.message, this.endpoint);

  @override
  String toString() => 'ApiException [$endpoint] ($statusCode): $message';
}

class AuthException extends ApiException {
  AuthException(String message, String endpoint) : super(401, message, endpoint);
}

/// Исключение для ошибок, возвращаемых API (например, 400, 403, 500).
class ApiServiceException implements Exception {
  final int statusCode;
  final String message;
  final String path;

  ApiServiceException(this.statusCode, this.message, this.path);

  @override
  String toString() => 'ApiServiceException(Status: $statusCode, Path: $path): $message';
}

/// Исключение для сетевых ошибок (например, таймаут, нет соединения).
class NetworkException implements Exception {
  final String message;

  NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}

// (UserProfile, UserDocument, JobStatus, AgentChatMessage - Модели остаются прежними)
// --- 1. МОДЕЛИ ДАННЫХ (Dart) ---

// Модель для данных профиля пользователя
class UserProfile {
  final String userId;
  final String email;
  final String displayName;
  final int age;
  final String preferredLanguage;
  final String initialGoal;
  // Добавляем Optional поля для полной синхронизации с бэкендом
  final String? ageCategory; 
  final String? qualificationLevel;
  final String status;
  final DateTime createdAt;

  UserProfile({
    required this.userId,
    required this.email,
    required this.displayName,
    required this.age,
    required this.preferredLanguage,
    required this.initialGoal,
    this.ageCategory,
    this.qualificationLevel,
    required this.status,
    required this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['userId'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String,
      // Используем безопасное приведение к int или default
      age: (json['age'] as int?) ?? 0, 
      preferredLanguage: json['preferredLanguage'] as String,
      initialGoal: json['initialGoal'] as String,
      ageCategory: json['age_category'] as String?,
      qualificationLevel: json['qualification_level'] as String?,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'email': email,
    'displayName': displayName,
    'age': age,
    'preferredLanguage': preferredLanguage,
    'initialGoal': initialGoal,
    // Не включаем optional поля, если они null, для корректного PUT-запроса
  };
}

// Модель для документа пользователя
class UserDocument {
  final String docId;
  final String title;
  final String filename;
  final String status;
  final String fileType;
  final DateTime uploadDate;
  final DateTime uploadedAt;

  UserDocument({
    required this.docId,
    required this.title,
    required this.filename,
    required this.status,
    required this.fileType,
    required this.uploadDate,
    required this.uploadedAt,
  });

  factory UserDocument.fromJson(Map<String, dynamic> json) {
    return UserDocument(
      docId: json['doc_id'] as String,
      title: json['title'] as String,
      filename: json['filename'] as String,
      status: json['status'] as String,
      fileType: json['file_type'] as String,
      uploadDate: DateTime.parse(json['upload_date'] as String),
      uploadedAt: DateTime.parse(json['uploaded_at'] as String),
    );
  }
}

// Модель для статуса асинхронной задачи (RAG/Export)
class JobStatus {
  final String status;
  final String? message;
  final String? downloadUrl;

  JobStatus({
    required this.status,
    this.message,
    this.downloadUrl,
  });

  factory JobStatus.fromJson(Map<String, dynamic> json) {
    return JobStatus(
      status: json['status'] as String? ?? 'UNKNOWN',
      message: json['message'] as String?,
      downloadUrl: json['downloadUrl'] as String?,
    );
  }
}

/// Модель для данных о биллинге и лимитах LLM.
class BillingStatus {
  final int freeLimitRemaining;
  final bool isPremiumUser;
  final String limitType;

  BillingStatus({
    required this.freeLimitRemaining,
    required this.isPremiumUser,
    required this.limitType,
  });

  factory BillingStatus.fromJson(Map<String, dynamic> json) {
    return BillingStatus(
      freeLimitRemaining: json['freeLimitRemaining'] as int,
      isPremiumUser: json['isPremiumUser'] as bool,
      limitType: json['limitType'] as String? ?? 'llm_queries',
    );
  }
}

// Модель для сообщения в чате (Agent Chat)
class AgentChatMessage {
  final String sender;
  final String message;
  final DateTime timestamp;

  AgentChatMessage({
    required this.sender,
    required this.message,
    required this.timestamp,
  });

  factory AgentChatMessage.fromJson(Map<String, dynamic> json) {
    return AgentChatMessage(
      sender: json['sender'] as String,
      message: json['message'] as String,
      // Предполагаем, что timestamp всегда приходит в строковом формате ISO
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}

// --- 2. СЕРВИС API ---

class ApiService {
  // Используем приватное поле для базового URL
  final String _baseUrl = _kBaseUrl;
  final String _authToken; 

  ApiService([this._authToken = '']);

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $_authToken',
  };

  // Вспомогательная функция для обработки ошибок
  void _handleResponseStatus(http.Response response, String endpoint) {
    // Реализация обработки ошибок
    if (response.statusCode >= 400) {
      // Пример простой обработки ошибки
      final responseBody = json.decode(response.body);
      throw Exception('Ошибка API на $endpoint (Код: ${response.statusCode}): ${responseBody['detail']}');
    }
  }

  // Добавляем метод _handleError, на который ссылаются все методы
  void _handleError(http.Response response, String methodName) {
      if (response.statusCode >= 400) {
          // Здесь вызывается ваша более общая функция, или можно сразу выбросить исключение.
          // Чтобы избежать дублирования логики, лучше вызвать _handleResponseStatus.
          _handleResponseStatus(response, methodName);
      }
      // Если статус < 400, ничего не делаем.
  }
  
  // Пример GET-запроса
  Future<Map<String, dynamic>> get(String endpoint) async {
    final uri = Uri.parse('$_baseUrl/$endpoint');
    
    try {
      final response = await http.get(uri, headers: _headers);
      _handleResponseStatus(response, endpoint);
      return json.decode(response.body);
    } catch (e) {
      // Логирование и переброс ошибки
      print('Ошибка при GET-запросе к $endpoint: $e');
      rethrow;
    }
  }

  // --- МЕТОДЫ ПРОФИЛЯ (СИНХРОННЫЕ CRUD) ---

  Future<UserProfile> getUserProfile() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/users/profile'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      return UserProfile.fromJson(data['profile'] as Map<String, dynamic>);
    } else {
      _handleError(response, 'getUserProfile');
      throw Exception('Failed to load profile'); // Заглушка, т.к. _handleError выбросит
    }
  }

  // --- МЕТОДЫ ЗАГРУЗКИ ---

  // 1. СИНХРОННАЯ ЗАГРУЗКА (HTTP 201) - Аватарки
  Future<String> uploadSimpleFile(File file, String filename) async {
    final uri = Uri.parse('$_baseUrl/uploads/simple');
    final request = http.MultipartRequest('POST', uri);
    request.headers.addAll(_headers);

    request.files.add(await http.MultipartFile.fromPath(
      'file',
      file.path,
      filename: filename,
      contentType: MediaType('application', 'octet-stream'),
    ));

    final response = await http.Response.fromStream(await request.send());

    if (response.statusCode == 201) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      return data['path'] as String; // Возвращает GCS-путь
    } else {
      _handleError(response, 'uploadSimpleFile');
      throw Exception('Failed to upload file');
    }
  }

  // 2. АСИНХРОННАЯ ИНИЦИАЦИЯ VASC ИНДЕКСАЦИИ (HTTP 201/202)
  // Мы используем /books вместо /documents/upload, как в новом main.py
  Future<String> initiateDocumentUpload(File file, String filename) async {
    // ИСПРАВЛЕНО: Используем эндпоинт /books, который инициирует VASC индексацию
    final uri = Uri.parse('$_baseUrl/books'); 
    final request = http.MultipartRequest('POST', uri);
    request.headers.addAll(_headers);

    request.files.add(await http.MultipartFile.fromPath(
      'file',
      file.path,
      filename: filename,
      contentType: MediaType('application', 'octet-stream'),
    ));

    final response = await http.Response.fromStream(await request.send());

    // Бэкенд возвращает 201, так как создает метаданные, но индексация асинхронна.
    if (response.statusCode == 201) { 
      final data = json.decode(utf8.decode(response.bodyBytes));
      // Ожидаем, что бэкенд вернет 'book_id'
      return data['book_id'] as String; 
    } else {
      _handleError(response, 'initiateDocumentUpload');
      throw Exception('Failed to initiate VASC indexing');
    }
  }

  // 3. АСИНХРОННЫЙ МОНИТОРИНГ (ОПРОС СТАТУСА ДОКУМЕНТА)
  Stream<JobStatus> pollDocumentStatus(String docId) async* {
    JobStatus status = JobStatus(status: 'PROCESSING');

    while (status.status == 'PROCESSING') {
      await Future.delayed(STATUS_POLLING_INTERVAL);
      
      final response = await http.get(
        Uri.parse('$_baseUrl/documents/$docId/status'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        status = JobStatus.fromJson(json.decode(utf8.decode(response.bodyBytes)));
        yield status;
      } else {
        // Завершаем стрим при ошибке
        status = JobStatus(status: 'FAILED', message: 'Error checking status: ${response.statusCode}');
        yield status;
        break; 
      }
    }
  }

  // 4. ПОЛУЧЕНИЕ СПИСКА ДОКУМЕНТОВ
  Future<List<UserDocument>> getUserDocuments() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/documents'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      return (data['documents'] as List)
          .map((docJson) => UserDocument.fromJson(docJson as Map<String, dynamic>))
          .toList();
    } else {
      _handleError(response, 'getUserDocuments');
      throw Exception('Failed to load documents');
    }
  }

  // --- МЕТОДЫ ЭКСПОРТА ДАННЫХ ---
  // Инициирует экспорт данных (HTTP 202)
  Future<String> initiateDataExport() async {
    final response = await http.post(
      Uri.parse('$_baseUrl/exports'),
      headers: _headers,
    );

    if (response.statusCode == 202) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      return data['job_id'] as String; 
    } else {
      _handleError(response, 'initiateDataExport');
      throw Exception('Failed to initiate data export');
    }
  }

  // Опрос статуса экспорта
  Stream<JobStatus> pollExportStatus(String jobId) async* {
    JobStatus status = JobStatus(status: 'PROCESSING');

    while (status.status == 'PROCESSING') {
      await Future.delayed(STATUS_POLLING_INTERVAL);

      final response = await http.get(
        Uri.parse('$_baseUrl/exports/$jobId/status'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        status = JobStatus.fromJson(json.decode(utf8.decode(response.bodyBytes)));
        yield status;

        if (status.status == 'completed' && status.downloadUrl != null) {
          break;
        }
      } else {
        status = JobStatus(status: 'FAILED', message: 'Error checking export status: ${response.statusCode}');
        yield status;
        break;
      }
    }
  }

  // --- МЕТОДЫ ЧАТА --- возвращает только результат последнего сообщения
  Future<Map<String, dynamic>> sendChatMessage({
    required String message, 
    String? conversationId, 
    // ИСПРАВЛЕНО: Заменяем documentIds на ID хранилища данных VASC 
    // (Managed RAG требует указания источника)
    required String vascDataStoreId, // <-- КЛЮЧЕВОЕ ИЗМЕНЕНИЕ
  }) async {
    final body = {
      'message': message,
      if (conversationId != null) 'conversationId': conversationId,
      // НОВОЕ ПОЛЕ: Передаем ID хранилища данных VASC
      'vasc_data_store_id': vascDataStoreId, 
    };

    final response = await http.post(
      Uri.parse('$_baseUrl/agent/chat'),
      headers: _headers,
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      // Возвращаем сырой ответ, чтобы UI сам управлял обновлением истории
      return json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    } else {
      _handleError(response, 'sendChatMessage');
      throw Exception('Failed to send chat message');
    }
  }

  // Получение истории чата (для обновления UI после отправки сообщения)
  Future<List<AgentChatMessage>> getChatHistory(String conversationId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/agent/chat/history/$conversationId'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      return (data['messages'] as List)
          .map((msgJson) => AgentChatMessage.fromJson(msgJson as Map<String, dynamic>))
          .toList();
    } else {
      _handleError(response, 'getChatHistory');
      throw Exception('Failed to load chat history');
    }
  }
  
  // --- НОВЫЙ БЛОК: МЕТОДЫ БИЛЛИНГА ---

  // 5. Проверка статуса лимитов пользователя (СИНХРОННЫЙ)
  Future<BillingStatus> getFreeLimitStatus() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/billing/free-limit-status'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      // Ответ Fast API содержит "status": "success" и остальные поля
      return BillingStatus.fromJson(data);
    } else {
      _handleError(response, 'getFreeLimitStatus');
      throw Exception('Failed to get free limit status');
    }
  }
  
  // 6. Проверка статуса подписки пользователя (СИНХРОННЫЙ)
  Future<BillingStatus> getSubscriptionStatus() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/billing/subscription-status'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      return BillingStatus.fromJson(data);
    } else {
      _handleError(response, 'getSubscriptionStatus');
      throw Exception('Failed to get subscription status');
    }
  }
}