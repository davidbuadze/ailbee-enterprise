import 'package:flutter/material.dart';
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'flutter_flow/flutter_flow_util.dart';
import 'dart:convert';

class FFAppState extends ChangeNotifier {
  static FFAppState _instance = FFAppState._internal();

  factory FFAppState() {
    return _instance;
  }

  FFAppState._internal();

  static void reset() {
    _instance = FFAppState._internal();
  }

  Future initializePersistedState() async {
    prefs = await SharedPreferences.getInstance();
    _safeInit(() {
      _isOfflineGemmaReady =
          prefs.getBool('ff_isOfflineGemmaReady') ?? _isOfflineGemmaReady;
    });
  }

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  late SharedPreferences prefs;

  bool _isOfflineMode = false;
  bool get isOfflineMode => _isOfflineMode;
  set isOfflineMode(bool value) {
    _isOfflineMode = value;
  }

  bool _isOfflineGemmaReady = false;
  bool get isOfflineGemmaReady => _isOfflineGemmaReady;
  set isOfflineGemmaReady(bool value) {
    _isOfflineGemmaReady = value;
    prefs.setBool('ff_isOfflineGemmaReady', value);
  }

  List<ChatMessageStruct> _schoolChatMessagesHistory = [];
  List<ChatMessageStruct> get schoolChatMessagesHistory =>
      _schoolChatMessagesHistory;
  set schoolChatMessagesHistory(List<ChatMessageStruct> value) {
    _schoolChatMessagesHistory = value;
  }

  void addToSchoolChatMessagesHistory(ChatMessageStruct value) {
    schoolChatMessagesHistory.add(value);
  }

  void removeFromSchoolChatMessagesHistory(ChatMessageStruct value) {
    schoolChatMessagesHistory.remove(value);
  }

  void removeAtIndexFromSchoolChatMessagesHistory(int index) {
    schoolChatMessagesHistory.removeAt(index);
  }

  void updateSchoolChatMessagesHistoryAtIndex(
    int index,
    ChatMessageStruct Function(ChatMessageStruct) updateFn,
  ) {
    schoolChatMessagesHistory[index] =
        updateFn(_schoolChatMessagesHistory[index]);
  }

  void insertAtIndexInSchoolChatMessagesHistory(
      int index, ChatMessageStruct value) {
    schoolChatMessagesHistory.insert(index, value);
  }

  List<ChatMessageStruct> _schoolLabMessagesHistory = [
    ChatMessageStruct.fromSerializableMap(jsonDecode(
        '{\"sender\":\"assistant\",\"text\":\"ფიზიკა + ბიოლოგია: უჯრედებში დიფუზიის ცდის ჩატარება \",\"model\":\"test1\"}')),
    ChatMessageStruct.fromSerializableMap(jsonDecode(
        '{\"sender\":\"assistant\",\"text\":\"ქიმია + გეოგრაფია: მინერალური წყლების შემადგენლობა \",\"model\":\"test2\"}'))
  ];
  List<ChatMessageStruct> get schoolLabMessagesHistory =>
      _schoolLabMessagesHistory;
  set schoolLabMessagesHistory(List<ChatMessageStruct> value) {
    _schoolLabMessagesHistory = value;
  }

  void addToSchoolLabMessagesHistory(ChatMessageStruct value) {
    schoolLabMessagesHistory.add(value);
  }

  void removeFromSchoolLabMessagesHistory(ChatMessageStruct value) {
    schoolLabMessagesHistory.remove(value);
  }

  void removeAtIndexFromSchoolLabMessagesHistory(int index) {
    schoolLabMessagesHistory.removeAt(index);
  }

  void updateSchoolLabMessagesHistoryAtIndex(
    int index,
    ChatMessageStruct Function(ChatMessageStruct) updateFn,
  ) {
    schoolLabMessagesHistory[index] =
        updateFn(_schoolLabMessagesHistory[index]);
  }

  void insertAtIndexInSchoolLabMessagesHistory(
      int index, ChatMessageStruct value) {
    schoolLabMessagesHistory.insert(index, value);
  }

  List<ChatMessageStruct> _researchMessagesHistory = [];
  List<ChatMessageStruct> get researchMessagesHistory =>
      _researchMessagesHistory;
  set researchMessagesHistory(List<ChatMessageStruct> value) {
    _researchMessagesHistory = value;
  }

  void addToResearchMessagesHistory(ChatMessageStruct value) {
    researchMessagesHistory.add(value);
  }

  void removeFromResearchMessagesHistory(ChatMessageStruct value) {
    researchMessagesHistory.remove(value);
  }

  void removeAtIndexFromResearchMessagesHistory(int index) {
    researchMessagesHistory.removeAt(index);
  }

  void updateResearchMessagesHistoryAtIndex(
    int index,
    ChatMessageStruct Function(ChatMessageStruct) updateFn,
  ) {
    researchMessagesHistory[index] = updateFn(_researchMessagesHistory[index]);
  }

  void insertAtIndexInResearchMessagesHistory(
      int index, ChatMessageStruct value) {
    researchMessagesHistory.insert(index, value);
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

  bool _isAiTyping = false;
  bool get isAiTyping => _isAiTyping;
  set isAiTyping(bool value) {
    _isAiTyping = value;
  }

  String _activeBookTitle = '';
  String get activeBookTitle => _activeBookTitle;
  set activeBookTitle(String value) {
    _activeBookTitle = value;
  }

  String _activeBookContext = '';
  String get activeBookContext => _activeBookContext;
  set activeBookContext(String value) {
    _activeBookContext = value;
  }

  String _currentConversationId = 'new';
  String get currentConversationId => _currentConversationId;
  set currentConversationId(String value) {
    _currentConversationId = value;
  }

  String _lastActivityType = '';
  String get lastActivityType => _lastActivityType;
  set lastActivityType(String value) {
    _lastActivityType = value;
  }

  dynamic _lastApiResponse;
  dynamic get lastApiResponse => _lastApiResponse;
  set lastApiResponse(dynamic value) {
    _lastApiResponse = value;
  }

  List<String> _learnedTopics = [];
  List<String> get learnedTopics => _learnedTopics;
  set learnedTopics(List<String> value) {
    _learnedTopics = value;
  }

  void addToLearnedTopics(String value) {
    learnedTopics.add(value);
  }

  void removeFromLearnedTopics(String value) {
    learnedTopics.remove(value);
  }

  void removeAtIndexFromLearnedTopics(int index) {
    learnedTopics.removeAt(index);
  }

  void updateLearnedTopicsAtIndex(
    int index,
    String Function(String) updateFn,
  ) {
    learnedTopics[index] = updateFn(_learnedTopics[index]);
  }

  void insertAtIndexInLearnedTopics(int index, String value) {
    learnedTopics.insert(index, value);
  }

  List<String> _learnedConcepts = [];
  List<String> get learnedConcepts => _learnedConcepts;
  set learnedConcepts(List<String> value) {
    _learnedConcepts = value;
  }

  void addToLearnedConcepts(String value) {
    learnedConcepts.add(value);
  }

  void removeFromLearnedConcepts(String value) {
    learnedConcepts.remove(value);
  }

  void removeAtIndexFromLearnedConcepts(int index) {
    learnedConcepts.removeAt(index);
  }

  void updateLearnedConceptsAtIndex(
    int index,
    String Function(String) updateFn,
  ) {
    learnedConcepts[index] = updateFn(_learnedConcepts[index]);
  }

  void insertAtIndexInLearnedConcepts(int index, String value) {
    learnedConcepts.insert(index, value);
  }

  List<String> _studentInterests = [];
  List<String> get studentInterests => _studentInterests;
  set studentInterests(List<String> value) {
    _studentInterests = value;
  }

  void addToStudentInterests(String value) {
    studentInterests.add(value);
  }

  void removeFromStudentInterests(String value) {
    studentInterests.remove(value);
  }

  void removeAtIndexFromStudentInterests(int index) {
    studentInterests.removeAt(index);
  }

  void updateStudentInterestsAtIndex(
    int index,
    String Function(String) updateFn,
  ) {
    studentInterests[index] = updateFn(_studentInterests[index]);
  }

  void insertAtIndexInStudentInterests(int index, String value) {
    studentInterests.insert(index, value);
  }

  bool _isPremium = true;
  bool get isPremium => _isPremium;
  set isPremium(bool value) {
    _isPremium = value;
  }

  DateTime? _subscriptionExpirationDate =
      DateTime.fromMillisecondsSinceEpoch(1786965540000);
  DateTime? get subscriptionExpirationDate => _subscriptionExpirationDate;
  set subscriptionExpirationDate(DateTime? value) {
    _subscriptionExpirationDate = value;
  }

  int _activeSchoolTab = 0;
  int get activeSchoolTab => _activeSchoolTab;
  set activeSchoolTab(int value) {
    _activeSchoolTab = value;
  }
}

void _safeInit(Function() initializeField) {
  try {
    initializeField();
  } catch (_) {}
}

Future _safeInitAsync(Function() initializeField) async {
  try {
    await initializeField();
  } catch (_) {}
}
