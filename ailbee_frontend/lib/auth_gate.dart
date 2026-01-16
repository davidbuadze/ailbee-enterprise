import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'screens/main_chat_screen.dart';
import 'package:ailbee_frontend/screens/main_chat_screen.dart';

// --- Основной Шлюз Аутентификации с FirebaseUI ---

// Этот экран отображается, когда пользователь НЕ аутентифицирован.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  // Функция для обработки анонимного входа с визуальной обратной связью
  void _signInAnonymously(BuildContext context) async {
    try {
      // Имитация анонимного входа, чтобы продолжить разработку
      await FirebaseAuth.instance.signInAnonymously();
      
      // Показываем подтверждение, если виджет все еще в дереве
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Вход выполнен анонимно.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      // Обработка ошибок Firebase (например, нет соединения)
      if (context.mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка входа: ${e.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Вход / Регистрация'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.lock_open, 
                size: 80, 
                color: Colors.blueAccent
              ),
              const SizedBox(height: 32),
              const Text(
                'Добро пожаловать!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Пожалуйста, аутентифицируйтесь для доступа к чату.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 40),
              // Кнопка для имитации входа (Анонимный вход)
              ElevatedButton.icon(
                icon: const Icon(Icons.person_outline),
                label: const Text('Войти анонимно (для разработки)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 5,
                ),
                onPressed: () => _signInAnonymously(context),
              ),
              const SizedBox(height: 16),
              const Text(
                'В реальной версии здесь будут поля ввода логина/пароля.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Этот Виджет использует FirebaseUI для автоматического переключения
// между экраном входа (SignInScreen) и главным экраном (MainChatScreen).
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // Виджет, который слушает состояние аутентификации Firebase
    // и автоматически перенаправляет пользователя.
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {

        // Проверяем, аутентифицирован ли пользователь
        if (!snapshot.hasData) {
          // Пользователь не аутентифицирован: показываем экран входа FirebaseUI.
          return SignInScreen(
            // Список провайдеров, которые были настроены в main.dart
            providers: FirebaseUIAuth.instance.providers,
            // Экран, на который переходим после успешной аутентификации
            actions: [
              AuthStateChangeAction<SignedIn>((context, state) {
                // После успешного входа переходим на главный экран чата
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const MainChatScreen()),
                );
              }),
            ],
            // Опции экрана
            headerBuilder: (context, constraints, shrinkOffset) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: AspectRatio(
                  aspectRatio: 1,
                  // Попытка загрузить логотип из assets/logo.png, с заглушкой на случай ошибки.
                  child: Image.asset(
                    'assets/logo.png', 
                    width: 150, 
                    height: 150, 
                    errorBuilder: (c, o, s) => const Icon(Icons.android, size: 80, color: Colors.deepPurple)
                  ),
                ),
              );
            },
            subtitleBuilder: (context, action) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  action == AuthAction.signIn
                      ? 'Добро пожаловать в ailbee.web.app! Войдите для доступа.'
                      : 'Создайте новый аккаунт.',
                ),
              );
            },
          );
        }

        // Пользователь аутентифицирован: показываем главный экран.
        return const MainChatScreen();
      },
    );
  }
}
