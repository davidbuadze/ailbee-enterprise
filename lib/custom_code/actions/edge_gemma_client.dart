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

Future<String> edgeGemmaClient(
  String prompt,
  String systemInstruction,
) async {
  await Future.delayed(const Duration(milliseconds: 750));

  final String cleanPrompt = prompt.toLowerCase();

  if (cleanPrompt.contains("диффуз")) {
    return "[Локальный ИИ Gemma на WebGPU]: Диффузия — пассивный транспорт. Вещества перемещаются из зоны высокой концентрации в зону низкой концентрации. Энергия АТФ при этом не расходуется.";
  } else if (cleanPrompt.contains("атф")) {
    return "[Локальный ИИ Gemma на WebGPU]: АТФ синтезируется ферментом АТФ-синтазой, которая работает как молекулярный ротор, приводимый в движение потоком протонов.";
  }

  return "[Локальный ИИ Gemma на WebGPU]: Локальная база знаний активна. Процесс классифицирован как междисциплинарный.";
}
