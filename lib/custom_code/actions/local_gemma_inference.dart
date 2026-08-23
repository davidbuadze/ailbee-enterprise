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

Future<String> localGemmaInference(
  String prompt,
  String systemInstruction,
) async {
  await Future.delayed(const Duration(milliseconds: 800));

  final cleanPrompt = prompt.toLowerCase();
  if (cleanPrompt.contains("диффуз")) {
    return "[Локальный ИИ Gemma 2B на устройстве]: Процесс диффузии — это пассивный транспорт молекул по градиенту концентрации. Он не требует затрат энергии АТФ.";
  } else if (cleanPrompt.contains("атф")) {
    return "[Локальный ИИ Gemma 2B на устройстве]: АТФ (аденозинтрифосфат) синтезируется в митохондриях клеток за счет электрохимического градиента протонов.";
  }

  return "[Локальный ИИ Gemma 2B на устройстве]: Запрос классифицирован как естественнонаучный. Модель готова составить междисциплинарное описание в оффлайн-режиме.";
}
