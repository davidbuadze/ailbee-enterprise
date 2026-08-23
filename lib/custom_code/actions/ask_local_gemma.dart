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

import '/app_state.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:flutter_gemma_mediapipe/flutter_gemma_mediapipe.dart';

Future<String> askLocalGemma(String userPrompt) async {
  try {
    if (userPrompt.isEmpty) {
      return "Пожалуйста, введите ваш вопрос.";
    }

    final model = await FlutterGemma.getActiveModel(maxTokens: 512);
    final chat = await model.createChat();
    await chat.addQueryChunk(Message.text(text: userPrompt, isUser: true));
    final response = await chat.generateChatResponse();

    if (response is TextResponse) {
      return response.token;
    }
    return response.toString();
  } catch (e) {
    return "Ошибка: Модель еще не загружена в память. Запрос: $userPrompt. Ошибка: $e";
  }
}
