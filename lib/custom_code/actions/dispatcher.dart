// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/actions/actions.dart' as action_blocks;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_gemma/flutter_gemma.dart';

DateTime? _lastNetworkFailureTime;

Future<dynamic> dispatcher(
  String query,
  String userGrade,
  String processType,
  List<ChatMessageStruct> messagesHistory,
  bool networkStatus,
  bool deviceCapability,
  String queryComplexity,
  bool isManualOffline,
) async {
  const String backendUrl =
      "https://ailbee-enterprise-hub-991527374957.us-central1.run.app";

  final cleanQuery = query.trim().toLowerCase();

  // Конвертация списка объектов в список строк
  List<String> historyTextList = messagesHistory
      .map((msg) => msg.text)
      .where((text) => text.isNotEmpty)
      .toList();

  // 1. АНАЛИЗ НЕОДНОЗНАЧНОСТИ
  if (cleanQuery.length < 4 && processType == "Исследование") {
    return {
      "is_ambiguous": true,
      "answer":
          "Для глубокого исследования ваш запрос '$query' слишком короткий. Напишите подробнее...",
      "subjects_involved": ["Системное уведомление"],
      "sources": [],
      "should_dim_ui": isManualOffline,
      "is_auto_switch": false
    };
  }

  // 2. БЫСТРЫЙ ЛОКАЛЬНЫЙ ОФФЛАЙН ГЛОССАРИЙ
  final Map<String, Map<String, dynamic>> localGlossary = {
    "диффузия": {
      "answer":
          "Диффузия — физический процесс взаимного проникновения молекул...",
      "subjects": ["Физика", "Биология"],
      "sources": [
        {
          "title": "Основы мембранной биофизики",
          "uri": "local://books/membrane"
        }
      ]
    }
  };

  if (localGlossary.containsKey(cleanQuery)) {
    final cachedData = localGlossary[cleanQuery]!;
    return {
      "is_ambiguous": false,
      "answer": cachedData["answer"],
      "subjects_involved": cachedData["subjects"],
      "sources": cachedData["sources"],
      "should_dim_ui": isManualOffline,
      "is_auto_switch": false
    };
  }

  // 3. ПРОВЕРКА РЕЖИМА: РУЧНОЙ ОФФЛАЙН
  if (isManualOffline) {
    return await _fallbackToLocalAI(
        query,
        "🔋 Режим экономии энергии/трафика. Работает локальная Gemma.\n\n",
        true,
        false);
  }

  // 4. ПРОВЕРКА РЕЖИМА: АВТО-ОФФЛАЙН
  if (_lastNetworkFailureTime != null) {
    final timePassed = DateTime.now().difference(_lastNetworkFailureTime!);
    if (timePassed < const Duration(seconds: 60)) {
      final remainingSeconds = 60 - timePassed.inSeconds;
      return await _fallbackToLocalAI(
          query,
          "⏳ Сеть нестабильна. Авто-оффлайн (восстановление через $remainingSeconds сек).\n\n",
          true,
          true);
    }
  }

  // 5. СЕТЕВОЙ ВЫЗОВ К FastAPI
  try {
    final bool isSchool = processType == "AI-სკოლა" || processType == "school";

    final String endpoint = isSchool
        ? "$backendUrl/api/v3/search/converse"
        : "$backendUrl/api/v3/chat/converse";

    final Map<String, dynamic> requestPayload = isSchool
        ? {
            "query": query,
            "agent_id": "ailbee-enterprise-knowledg_1779121464248",
            "conversation_id": "session_${userGrade.replaceAll(' ', '_')}",
            "chat_history": historyTextList,
          }
        : {
            "prompt": query,
            "agent_id": "gemini-enterprise-research",
            "conversation_id": "session_${userGrade.replaceAll(' ', '_')}",
            "chat_history": historyTextList,
          };

    final response = await http
        .post(
          Uri.parse(endpoint),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer mock_firebase_token_for_audit",
          },
          body: jsonEncode(requestPayload),
        )
        .timeout(const Duration(seconds: 8));

    if (response.statusCode == 200) {
      _lastNetworkFailureTime = null;
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      return {
        "is_ambiguous": false,
        "answer": decoded["reply"] ?? "Синтез выполнен успешно.",
        "subjects_involved": decoded["subjects_involved"] ?? ["Естествознание"],
        "sources": decoded["sources"] ?? [],
        "should_dim_ui": false,
        "is_auto_switch": true
      };
    } else {
      throw Exception();
    }
  } on TimeoutException catch (_) {
    _lastNetworkFailureTime = DateTime.now();
    return await _fallbackToLocalAI(
        query,
        "⚠️ Превышено время ожидания сети (8 сек). Авто-оффлайн.\n\n",
        true,
        true);
  } on SocketException catch (_) {
    _lastNetworkFailureTime = DateTime.now();
    return await _fallbackToLocalAI(
        query, "📴 Нет подключения к сети. Авто-оффлайн.\n\n", true, true);
  } catch (e) {
    _lastNetworkFailureTime = DateTime.now();
    return await _fallbackToLocalAI(
        query, "⚠️ Ошибка сервера. Авто-оффлайн.\n\n", true, true);
  }
}

Future<Map<String, dynamic>> _fallbackToLocalAI(String query,
    String warningMessage, bool shouldDim, bool isAutoSwitch) async {
  String localAnswer = "";
  try {
    final model = await FlutterGemma.getActiveModel(maxTokens: 512);
    final chat = await model.createChat();
    await chat.addQueryChunk(Message.text(text: query, isUser: true));
    final response = await chat.generateChatResponse();

    if (response is TextResponse) {
      localAnswer = response.token;
    } else {
      localAnswer = response.toString();
    }
  } catch (e) {
    localAnswer =
        "ИИ работает в режиме эмуляции (модель не загружена). Ваш запрос: $query";
  }

  return {
    "is_ambiguous": false,
    "answer": "$warningMessage$localAnswer",
    "subjects_involved": ["Локальная Gemma"],
    "sources": [
      {"title": "Процессор смартфона", "uri": "local://gemma"}
    ],
    "should_dim_ui": shouldDim,
    "is_auto_switch": isAutoSwitch
  };
}
