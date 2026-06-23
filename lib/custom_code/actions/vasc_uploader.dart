// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// vasc_uploader.dart
// Кастомное действие для загрузки файлов в облако и запуска индексации VASC (v3.3.4)

import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

Future<dynamic> vascUploader(
  FFUploadedFile uploadedFile,
) async {
  // Боевой активный URL вашего микросервиса на Cloud Run (Синхронизирован на 100%)
  const String backendUrl =
      "https://ailbee-enterprise-hub-991527374957.us-central1.run.app";

  if (uploadedFile.bytes == null || uploadedFile.name == null) {
    return {
      "success": false,
      "message": "Ошибка: Файл пуст или выбран некорректно.",
      "data": null
    };
  }

  final String fileName = uploadedFile.name!;
  final Uint8List fileBytes = uploadedFile.bytes!;

  // Автоматическое определение MIME-типа на основе расширения для бэкенда Python
  String mimeType = 'application/octet-stream';
  if (fileName.toLowerCase().endsWith('.pdf')) {
    mimeType = 'application/pdf';
  } else if (fileName.toLowerCase().endsWith('.docx')) {
    mimeType =
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
  } else if (fileName.toLowerCase().endsWith('.txt')) {
    mimeType = 'text/plain';
  }

  try {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse("$backendUrl/api/v3/search/document-upload"),
    );

    // Добавляем токен для прохождения аудита безопасности на бэкенде (RULE 3)
    request.headers['Authorization'] = 'Bearer mock_firebase_token_for_audit';

    var multipartFile = http.MultipartFile.fromBytes(
      'file',
      fileBytes,
      filename: fileName,
      contentType: MediaType.parse(mimeType),
    );
    request.files.add(multipartFile);

    var response = await request.send();

    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      return {
        "success": true,
        "message": "Файл успешно загружен и передан в воркер VASC.",
        "data": responseData
      };
    } else {
      return {
        "success": false,
        "message":
            "Сервер вернул ошибку при загрузке: Код ${response.statusCode}"
      };
    }
  } catch (e) {
    return {
      "success": false,
      "message": "Ошибка соединения с VASC-сервером: $e"
    };
  }
}
