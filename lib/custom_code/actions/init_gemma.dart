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

Future initGemma() async {
  try {
    await FlutterGemma.initialize(
      inferenceEngines: [MediaPipeEngine()],
    );
    print("Локальный ИИ Gemma успешно инициализирован на устройстве.");
  } catch (e) {
    print("Ошибка при запуске Gemma: $e");
  }
}
