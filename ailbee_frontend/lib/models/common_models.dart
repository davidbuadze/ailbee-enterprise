import 'package:flutter/material.dart';

// --- ИСКЛЮЧЕНИЯ ДЛЯ API ---

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

// --- МОДЕЛИ ДАННЫХ ---

/// Модель для данных о документе пользователя.
class UserDocument {
  final String docId;
  final String filename;
  final String status; // Например, 'uploaded', 'processing', 'ready'
  final DateTime uploadDate;

  UserDocument({
    required this.docId,
    required this.filename,
    required this.status,
    required this.uploadDate,
  });

  factory UserDocument.fromJson(Map<String, dynamic> json) {
    return UserDocument(
      docId: json['doc_id'] as String,
      filename: json['filename'] as String,
      status: json['status'] as String,
      uploadDate: DateTime.parse(json['upload_date'] as String),
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

/// Модель для сообщения в чате.
class AgentChatMessage {
  final String sender; // 'user', 'agent', 'system'
  final String message;
  final DateTime timestamp;

  AgentChatMessage({
    required this.sender,
    required this.message,
    required this.timestamp,
  });
}
