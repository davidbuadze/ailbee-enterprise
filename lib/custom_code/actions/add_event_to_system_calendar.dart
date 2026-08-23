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

import 'package:device_calendar/device_calendar.dart';
import 'package:timezone/timezone.dart' as tz;

Future<String?> addEventToSystemCalendar(
  String title,
  String? description,
  DateTime startDate,
  DateTime endDate,
) async {
  final DeviceCalendarPlugin deviceCalendarPlugin = DeviceCalendarPlugin();

  // 1. Проверяем и запрашиваем системные разрешения
  var permissions = await deviceCalendarPlugin.hasPermissions();
  if (permissions.isSuccess && !permissions.data!) {
    permissions = await deviceCalendarPlugin.requestPermissions();
    if (!permissions.isSuccess || !permissions.data!) {
      return null; // Пользователь отклонил доступ
    }
  }

  // 2. Находим основной календарь устройства
  final calendarsResult = await deviceCalendarPlugin.retrieveCalendars();
  if (!calendarsResult.isSuccess || calendarsResult.data!.isEmpty) {
    return null;
  }

  final defaultCalendar = calendarsResult.data!.firstWhere(
    (cal) => cal.isReadOnly == false && (cal.isDefault ?? false),
    orElse: () => calendarsResult.data!.firstWhere((cal) => !cal.isReadOnly!),
  );

  // 3. Формируем и фоново записываем событие
  final event = Event(
    defaultCalendar.id,
    title: title,
    description: description ?? '',
    start: tz.TZDateTime.from(startDate, tz.local),
    end: tz.TZDateTime.from(endDate, tz.local),
  );

  final createResult = await deviceCalendarPlugin.createOrUpdateEvent(event);

  if (createResult != null && createResult.isSuccess) {
    return createResult.data; // Уникальный ID записи
  }

  return null;
}
