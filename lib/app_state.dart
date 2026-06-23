import 'package:flutter/material.dart';

class FFAppState extends ChangeNotifier {
  static FFAppState _instance = FFAppState._internal();

  factory FFAppState() {
    return _instance;
  }

  FFAppState._internal();

  static void reset() {
    _instance = FFAppState._internal();
  }

  Future initializePersistedState() async {}

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  bool _isOfflineMode = false;
  bool get isOfflineMode => _isOfflineMode;
  set isOfflineMode(bool value) {
    _isOfflineMode = value;
  }

  String _selectedModel = 'gemini';
  String get selectedModel => _selectedModel;
  set selectedModel(String value) {
    _selectedModel = value;
  }

  String _currentSubject = 'physics';
  String get currentSubject => _currentSubject;
  set currentSubject(String value) {
    _currentSubject = value;
  }

  String _currentSelectedSubject = '';
  String get currentSelectedSubject => _currentSelectedSubject;
  set currentSelectedSubject(String value) {
    _currentSelectedSubject = value;
  }
}
