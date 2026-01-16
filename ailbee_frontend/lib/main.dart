// lib/main.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:ailbee_frontend/screens/main_chat_screen.dart'; 
import 'package:ailbee_frontend/screens/document_list.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

// заглушки вы указали (AuthGate, FirebaseOptions, AuthService)
import 'package:ailbee_frontend/auth_gate.dart';
import 'package:ailbee_frontend/firebase_options.dart';
import 'package:ailbee_frontend/services/auth_service.dart';

Future<void> main() async {
  // 1. Обязательное условие для асинхронных операций
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. Инициализация переменных окружения
  try {
    await dotenv.load(fileName: ".env");
    debugPrint("✅ Переменные окружения загружены.");
  } catch (e) {
    debugPrint("⚠️ Ошибка загрузки .env файла: $e. Используем хардкод.");
  }

  // 3. Инициализация Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint("✅ Firebase инициализирован.");
  } catch (e) {
    debugPrint("❌ Ошибка инициализации Firebase: $e.");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>(
          create: (_) => AuthService(),
        ),
        // Предоставляем Stream, который отслеживает состояние аутентификации (User?)
        StreamProvider<User?>.value(
          // Получаем поток пользователя из экземпляра AuthService
          value: Provider.of<AuthService>(context, listen: false).user,
          initialData: null,
          catchError: (context, error) {
            debugPrint("Ошибка в потоке аутентификации: $error");
            return null;
          },
        ),
      ],
      child: MaterialApp(
        title: 'Ailbee',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        // Главный вход, который решает, что показать: экран входа или главный экран
        home: const AuthGate(),
      ),
    );
  }
}
