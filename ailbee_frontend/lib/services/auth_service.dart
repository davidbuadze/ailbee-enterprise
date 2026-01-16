import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart'; 
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  
  // Убраны опечатки и конфликты имен (используем префикс '_')
  final FacebookAuthProvider _facebookAuthProvider = FacebookAuthProvider();
  final AppleAuthProvider _appleAuthProvider = AppleAuthProvider();

  Stream<User?> get user => _auth.authStateChanges();

  // пользователь вошел в систему
  bool get isAuthenticated => _auth.currentUser != null;

  // Текущий пользователь
  User? get currentUser => _auth.currentUser;

  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      // Уведомляем слушателей об изменении состояния
      notifyListeners(); 
      return result.user;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) print('Ошибка входа по Email/Password: ${e.code} / ${e.message}');
      return null;
    }
  }

  Future<User?> registerWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = result.user;
      if (user != null) {
        await _syncUserProfile(user);
      }
      notifyListeners();
      return user;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) print('Ошибка регистрации по Email/Password: ${e.code} / ${e.message}');
      return null;
    }
  }

  Future<User?> signInWithGoogle() async {
    try {
      // Вызов signIn() должен быть корректным
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // Пользователь отменил вход
        return null;
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // accessToken в GoogleSignInAuthentication теперь может быть null
      final String? accessToken = googleAuth.accessToken; 
      final String? idToken = googleAuth.idToken;

      if (accessToken == null || idToken == null) {
        if (kDebugMode) print('Ошибка: токен Google не получен.');
        return null;
      }

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: accessToken,
        idToken: idToken,
      );
      
      UserCredential result = await _auth.signInWithCredential(credential);
      User? user = result.user;
      if (user != null && result.additionalUserInfo!.isNewUser) {
        await _syncUserProfile(user);
      }
      notifyListeners();
      return user;
    } catch (e) {
      if (kDebugMode) print('Ошибка входа через Google: ${e.toString()}');
      return null;
    }
  }

  Future<User?> signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      if (result.status == LoginStatus.success) {
        final AccessToken accessToken = result.accessToken!;
        final AuthCredential credential = FacebookAuthProvider.credential(accessToken.tokenString);
        UserCredential userCredential = await _auth.signInWithCredential(credential);
        User? user = userCredential.user;
        if (user != null && userCredential.additionalUserInfo!.isNewUser) {
          await _syncUserProfile(user);
        }
        notifyListeners();
        return user;
      }
      return null;
    } catch (e) {
      if (kDebugMode) print('Ошибка входа через Facebook: ${e.toString()}');
      return null;
    }
  }
  
  // Реализация для Apple Sign-In
  Future<User?> signInWithApple() async {
    try {
      // 1. Запрашиваем учетные данные у Apple
      // Используем стандартные классы для запроса
      final credential = await SignInWithApple.getCredential( 
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        // nonce теперь передается в виде сырой строки
        nonce: _auth.currentUser?.uid ?? 'default-nonce', 
      );

      // Проверяем, что необходимые токены не null
      if (credential.identityToken == null || credential.authorizationCode == null) {
        if (kDebugMode) print('Ошибка: Токены Apple не получены.');
        return null;
      }

      // 2. Создаем учетные данные Firebase из ответа Apple
      // Используем конструктор AuthCredential
      final AuthCredential appleAuthCredential = AppleAuthProvider.credential(
        idToken: credential.identityToken,
        rawNonce: _auth.currentUser?.uid ?? 'default-nonce', // Повторно используем nonce
      );
      
      // 3. Выполняем вход в Firebase
      final userCredential = await _auth.signInWithCredential(appleAuthCredential);
      
      User? user = userCredential.user;
      if (user != null && userCredential.additionalUserInfo!.isNewUser) {
        await _syncUserProfile(user);
      }
      notifyListeners();
      return user;
    } on PlatformException catch (e) { // Теперь PlatformException опознан
      if (kDebugMode) print('Ошибка входа через Apple (Platform): ${e.message}');
      return null;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) print('Ошибка входа через Apple (Firebase): ${e.code} / ${e.message}');
      return null;
    } catch (e) {
      if (kDebugMode) print('Ошибка входа через Apple: ${e.toString()}');
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await FacebookAuth.instance.logOut();
    await _auth.signOut();
    notifyListeners();
    if (kDebugMode) print('Пользователь вышел из системы.');
  }

  Future<void> _syncUserProfile(User user) async {
    // Android используйте 'http://10.0.2.2:8080',
    // для iOS/Web/Mac используйте 'http://localhost:8080' или IP адрес.
    // Для продакшена используйте доменное имя.
    final url = Uri.parse('http://localhost:8080/users/sync'); 
    try {
      final token = await user.getIdToken();
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'email': user.email,
          'displayName': user.displayName,
          'age_category': 'student',
          'qualification_level': 'none',
        }),
      );

      if (response.statusCode == 201) {
        if (kDebugMode) print('User profile synced successfully.');
      } else {
        if (kDebugMode) print('Failed to sync user profile: ${response.statusCode}');
        if (kDebugMode) print('Response body: ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) print('An error occurred during user profile sync: $e');
    }
  }
}
