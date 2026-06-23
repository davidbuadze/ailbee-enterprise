// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

// Модель книги в библиотеке VASC
class BookItem {
  final String id;
  final String title;
  final String subject;
  final Color color;
  final String desc;
  final String content;
  final bool isPremiumOnly;

  BookItem({
    required this.id,
    required this.title,
    required this.subject,
    required this.color,
    required this.desc,
    required this.content,
    this.isPremiumOnly = false,
  });
}

// Модель сообщений чата
class ChatMessage {
  final String sender;
  final String model;
  final String text;

  ChatMessage({required this.sender, required this.model, required this.text});
}

class AilbeePlanetaryDashboard extends StatefulWidget {
  const AilbeePlanetaryDashboard({
    Key? key,
    this.width,
    this.height,
  }) : super(key: key);

  final double? width;
  final double? height;

  @override
  _AilbeePlanetaryDashboardState createState() =>
      _AilbeePlanetaryDashboardState();
}

class _AilbeePlanetaryDashboardState extends State<AilbeePlanetaryDashboard> {
  // Боевой бэкенд на Cloud Run
  final String _backendUrl =
      'https://ailbee-enterprise-hub-991527374957.us-central1.run.app';

  // Системная навигация
  String _currentScreen = 'search'; // 'home', 'search', 'dashboard'
  String _activeTab = 'overview'; // 'overview', 'library', 'map', 'activity'

  // Пользовательский контекст
  final String _userTokens = '45 МБ / 100 МБ';

  User? _currentUser;
  bool _activeExpedition = false;

  // Локальные переменные состояния
  bool _offlineMode = false;
  String _selectedAiModel = 'gemini';

  // Локальный интерактивный глоссарий по клику
  bool _showGlossary = false;
  Map<String, String>? _activeGlossaryTerm;

  final Map<String, Map<String, String>> _glossaryDb = {
    'диффузия': {
      'title': 'Диффузия',
      'subject': 'Физика / Биология',
      'explanation':
          'Физический закон хаотичного теплового движения молекул. В биологии обеспечивает пассивный транспорт газов через липидные мембраны клеток без затрат энергии АТФ.'
    },
    'атф': {
      'title': 'АТФ (Аденозинтрифосфат)',
      'subject': 'Биохимия',
      'explanation':
          'Универсальный макроэргический источник энергии в живых системах. Является химическим аккумулятором клетки.'
    },
    'когерентность': {
      'title': 'Квантовая когерентность',
      'subject': 'Квантовая биофизика',
      'explanation':
          'Эффект наложения квантовых состояний, позволяющий молекулам хлорофилла переносить энергию поглощенного света к реакционному центру со 100% КПД.'
    }
  };

  // Контроллеры ввода
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _chatController = TextEditingController();

  // Статистика интерактивного графа
  int _lawsPercent = 85;
  int _connectionsCount = 124;
  int _todayAdded = 12;

  final List<ChatMessage> _chatMessages = [];
  bool _isAiTyping = false;
  BookItem? _selectedBook;
  String? _conversationId;

  // Шаблоны быстрых междисциплинарных запросов
  final List<Map<String, String>> _quickRequests = [
    {
      "text": "Электромагнетизм в нейронах",
      "query":
          "Как электромагнитные импульсы физики передаются по нейронам в биологии?"
    },
    {
      "text": "Математика снежинок",
      "query":
          "Какая фрактальная геометрия описывает рост кристаллов льда по законам термодинамики?"
    },
    {
      "text": "Физика климата",
      "query":
          "Как теплопроводность океана и атмосфера связаны с физической географией Земли?"
    },
    {
      "text": "Квантовый фотосинтез",
      "query":
          "Объясни квантовую когерентность при переносе энергии в хлоропластах растений."
    },
    {
      "text": "Диффузия в клетке",
      "query":
          "Как законы пассивного транспорта диффузии работают в мембранах клеток?"
    },
  ];

  final List<BookItem> _booksList = [
    BookItem(
        id: 'feynman',
        title: "Фейнмановские лекции",
        subject: "Физика",
        color: Colors.amber,
        desc: "Том 1. Пространство, white, движение.",
        content:
            "Фундаментальный курс физики, объясняющий термодинамику и законы сохранения энергии на макроуровне."),
    BookItem(
        id: 'cellbio',
        title: "Биология клетки",
        subject: "Биология",
        color: Colors.green,
        desc: "Молекулярные механизмы клетки.",
        content:
            "Подробный разбор процессов диффузии газов через полупроницаемые мембраны и биосинтеза АТФ."),
    BookItem(
        id: 'planetgeo',
        title: "Геология планет",
        subject: "География",
        color: Colors.blue,
        desc: "Тектоника и физика литосферы.",
        content:
            "Исследование связей между теплопередачей в мантии планеты (термодинамика) и рельефом земной коры.")
  ];

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    final userName = _currentUser?.displayName ?? 'Исследователь';
    _chatMessages.add(ChatMessage(
        sender: 'ai',
        model: 'gemini',
        text:
            'Приветствую, $userName! Я проанализировал главу о диффузии из учебника физики и сопоставил её с процессами дыхания клеток растений. С чего начнем междисциплинарный синтез?'));
  }

  void _openGlossary(String key) {
    if (_glossaryDb.containsKey(key)) {
      setState(() {
        _activeGlossaryTerm = _glossaryDb[key];
        _showGlossary = true;
      });
    }
  }

  // СВОБОДНЫЙ И ПРЯМОЙ МОСТ ОБНОВЛЕНИЯ APP STATE ВО FLUTTERFLOW
  void _syncWithAppState() {
    FFAppState().update(() {
      FFAppState().isOfflineMode = _offlineMode;
      FFAppState().selectedModel = _selectedAiModel;
    });
  }

  Future<void> _handleSendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _chatMessages.add(
          ChatMessage(sender: 'user', model: _selectedAiModel, text: text));
      _isAiTyping = true;
      _activeExpedition = true;
    });
    _chatController.clear();
    _searchController.clear();

    String? idToken;
    try {
      idToken = await _currentUser?.getIdToken();
    } catch (_) {}

    // Если включен оффлайн-режим, используем локальные симуляции
    if (_offlineMode || _selectedAiModel == 'gemma' || idToken == null) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (!mounted) return;
        setState(() {
          _chatMessages.add(ChatMessage(
              sender: 'ai',
              model: 'gemma',
              text:
                  "[Локальный ИИ Gemma 4]: Оффлайн режим. Процесс диффузии не требует энергии АТФ и протекает пассивно по градиенту концентрации."));
          _isAiTyping = false;
          _connectionsCount += 1;
          _todayAdded += 1;
        });
      });
      return;
    }

    // Если онлайн - отправляем реальный запрос на ваш Cloud Run бэкенд
    try {
      final url = Uri.parse('$_backendUrl/api/v3/chat/converse');
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken'
      };
      final body = jsonEncode({
        'prompt': text,
        'agent_id': 'gemini-enterprise-research',
        'conversation_id': _conversationId ?? "-"
      });

      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _chatMessages.add(ChatMessage(
              sender: 'ai',
              model: 'gemini',
              text: data['reply'] ?? 'Синтез знаний выполнен.'));
          _conversationId = data['conversation_id'];
          _isAiTyping = false;
          _connectionsCount += 1;
          _todayAdded += 1;
        });
      } else {
        setState(() {
          _chatMessages.add(ChatMessage(
              sender: 'ai',
              model: 'gemini',
              text:
                  'Ошибка бэкенда. Симуляция: Облачный Vertex AI Search подтверждает связь физического давления и биологического сокодвижения в растениях.'));
          _isAiTyping = false;
        });
      }
    } catch (e) {
      setState(() {
        _chatMessages.add(ChatMessage(
            sender: 'ai',
            model: 'gemma',
            text:
                'Сбой связи. Локальный вывод Gemma: Диффузия молекул обеспечивает газообмен в легких человека без затрат энергии.'));
        _isAiTyping = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width ?? double.infinity,
      height: widget.height ?? double.infinity,
      decoration: const BoxDecoration(color: Color(0xFF030712)), // slate-950
      child: Column(
        children: [
          _buildNavigationHeader(),
          _buildActiveScreenArea(),
        ],
      ),
    );
  }

  // --- Хедер переключения экранов ---
  Widget _buildNavigationHeader() {
    return Container(
      color: const Color(0xFF0F172A), // slate-900
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Text('ailbee',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic)),
              const SizedBox(width: 16),
              // Реактивный статус подключения
              GestureDetector(
                onTap: () {
                  setState(() {
                    _offlineMode = !_offlineMode;
                    if (_offlineMode) _selectedAiModel = 'gemma';
                    _syncWithAppState();
                  });
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _offlineMode
                        ? Colors.amber.withOpacity(0.1)
                        : Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: _offlineMode
                            ? Colors.amber.withOpacity(0.4)
                            : Colors.green.withOpacity(0.4)),
                  ),
                  child: Row(
                    children: [
                      Icon(_offlineMode ? Icons.wifi_off : Icons.wifi,
                          size: 12,
                          color: _offlineMode ? Colors.amber : Colors.green),
                      const SizedBox(width: 4),
                      Text(_offlineMode ? 'Оффлайн' : 'Онлайн',
                          style: TextStyle(
                              color: _offlineMode ? Colors.amber : Colors.green,
                              fontSize: 10,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              )
            ],
          ),

          // Визуальный переключатель трех экранов
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
                color: const Color(0xFF030712),
                borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                _navTabBtn('home', '1. Древо'),
                _navTabBtn('search', '2. Поиск'),
                _navTabBtn('dashboard', '3. Стол'),
              ],
            ),
          ),

          // Переключатель ИИ-моделей
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
                color: const Color(0xFF030712),
                borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                _modelBtn('gemini', 'Gemini', enabled: !_offlineMode),
                _modelBtn('gemma', 'Gemma'),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _navTabBtn(String id, String label) {
    bool active = _currentScreen == id;
    return GestureDetector(
      onTap: () => setState(() => _currentScreen = id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
            color: active ? Colors.indigo.shade600 : Colors.transparent,
            borderRadius: BorderRadius.circular(8)),
        child: Text(label,
            style: TextStyle(
                color: active ? Colors.white : const Color(0xFF94A3B8),
                fontSize: 11,
                fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _modelBtn(String id, String label, {bool enabled = true}) {
    bool active = _selectedAiModel == id;
    return GestureDetector(
      onTap: enabled
          ? () {
              setState(() {
                _selectedAiModel = id;
                _syncWithAppState();
              });
            }
          : null,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.3,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
              color: active
                  ? (id == 'gemini'
                      ? Colors.indigo.shade600
                      : Colors.amber.shade700)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(6)),
          child: Text(label,
              style: TextStyle(
                  color: active ? Colors.white : const Color(0xFF64748B),
                  fontSize: 10,
                  fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  // --- Вывод активного экрана ---
  Widget _buildActiveScreenArea() {
    return Expanded(
      child: Stack(
        children: [
          _buildScreenContent(),
          if (_showGlossary) _buildGlossaryOverlay(),
          if (_activeExpedition) _buildExpeditionDrawer(),
        ],
      ),
    );
  }

  Widget _buildScreenContent() {
    switch (_currentScreen) {
      case 'home':
        return _buildHomeView();
      case 'search':
        return _buildSearchView();
      case 'dashboard':
        return _buildDashboardView();
      default:
        return const SizedBox();
    }
  }

  // ЭКРАН 1: ДРЕВО ЕДИНСТВА
  Widget _buildHomeView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.blue.withOpacity(0.3))),
                child: const Text('МЕЖДИСЦИПЛИНАРНОЕ ЕДИНСТВО',
                    style: TextStyle(
                        color: Colors.blue,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2)),
              ),
              const SizedBox(height: 24),
              const Text('Концепция Единой Природы.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      fontStyle: FontStyle.italic)),
              const SizedBox(height: 12),
              const Text(
                  'Понимая один закон, ты открываешь двери во все науки сразу.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.white54,
                      fontWeight: FontWeight.w300)),
              const SizedBox(height: 40),

              // Поисковая панель
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF1E293B)),
                ),
                padding: const EdgeInsets.all(6),
                child: Row(
                  children: [
                    const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child:
                            Icon(Icons.search, color: Colors.grey, size: 24)),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16),
                        decoration: const InputDecoration(
                            hintText: 'Введите тему для поиска связей...',
                            hintStyle: TextStyle(color: Colors.white24),
                            border: InputBorder.none),
                        onSubmitted: (val) => _handleSendMessage(val),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => _handleSendMessage(
                          _searchController.text.isNotEmpty
                              ? _searchController.text
                              : "Диффузия в природе"),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12))),
                      child: const Text('Синтез',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 48),

              // Интерактивный закон дня
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    Colors.indigo.shade900.withOpacity(0.3),
                    const Color(0xFF0F172A)
                  ], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.indigo.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.bolt,
                            color: Colors.indigo.shade400, size: 18),
                        const SizedBox(width: 6),
                        Text('ЗАКОН ДНЯ',
                            style: TextStyle(
                                color: Colors.indigo.shade400,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                                fontSize: 11)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('Закон сохранения энергии',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Colors.white)),
                    const SizedBox(height: 12),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                            fontSize: 14, color: Colors.white70, height: 1.5),
                        children: [
                          const TextSpan(
                              text:
                                  'Энергия не исчезает, она лишь меняет форму. Этот закон физики — ключ к пониманию биохимических процессов выработки энергии '),
                          WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: InkWell(
                              onTap: () => _openGlossary('атф'),
                              child: Text(' АТФ (?) ',
                                  style: TextStyle(
                                      color: Colors.indigo.shade300,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14)),
                            ),
                          ),
                          const TextSpan(
                              text: 'в митохондриях клеток живых систем.'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _currentScreen = 'dashboard';
                          _activeTab = 'map';
                        });
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20))),
                      child: const Text('Смотреть граф связей',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 12)),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // ЭКРАН 2: ПОИСК ИССЛЕДОВАТЕЛЯ
  Widget _buildSearchView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Text('С чего начнем?',
                  style: TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.w900,
                      color: Colors.white)),
              const SizedBox(height: 12),
              const Text('Найдите связи между предметами за один запрос.',
                  style: TextStyle(fontSize: 16, color: Colors.white54)),
              const SizedBox(height: 32),

              // Поисковая строка с поддержкой ИИ-синтеза
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFF334155), width: 2),
                ),
                padding: const EdgeInsets.all(6),
                child: Row(
                  children: [
                    const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child:
                            Icon(Icons.search, color: Colors.grey, size: 24)),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16),
                        decoration: const InputDecoration(
                            hintText: 'Спросите о законах природы...',
                            hintStyle: TextStyle(color: Colors.white30),
                            border: InputBorder.none),
                        onSubmitted: (val) => _handleSendMessage(val),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.auto_awesome,
                          color: Colors.indigoAccent),
                      onPressed: () =>
                          _handleSendMessage(_searchController.text),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Шаблоны
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('БЫСТРЫЕ ШАБЛОНЫ ЗАПРОСОВ:',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        letterSpacing: 1.1)),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _quickRequests
                    .map((req) => InkWell(
                          onTap: () {
                            _searchController.text = req['query']!;
                            _handleSendMessage(req['query']!);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                                color: const Color(0xFF0F172A),
                                border:
                                    Border.all(color: const Color(0xFF1E293B)),
                                borderRadius: BorderRadius.circular(12)),
                            child: Text(req['text']!,
                                style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ))
                    .toList(),
              )
            ],
          ),
        ),
      ),
    );
  }

  // ЭКРАН 3: РАБОЧИЙ СТОЛ ИССЛЕДОВАТЕЛЯ (ДАШБОРД / VASC)
  Widget _buildDashboardView() {
    return Row(
      children: [
        // Левый Сайдбар рабочего стола
        Container(
          width: 200,
          decoration: const BoxDecoration(
            color: Color(0xFF030712),
            border: Border(right: BorderSide(color: Color(0xFF1E293B))),
          ),
          child: Column(
            children: [
              const SizedBox(height: 16),
              _dashNavBtn('overview', 'Обзор', Icons.dashboard),
              _dashNavBtn('library', 'Архив VASC', Icons.book),
              _dashNavBtn('map', 'Карта связей', Icons.map),
              _dashNavBtn('activity', 'Активность', Icons.history),
              const Spacer(),
              // Мониторинг токенов/квот пользователя
              Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF1E293B))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Пакет квот',
                        style: TextStyle(
                            color: Colors.indigoAccent,
                            fontSize: 10,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(_userTokens,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const LinearProgressIndicator(
                        value: 0.45,
                        backgroundColor: Color(0xFF030712),
                        color: Colors.indigoAccent,
                        minHeight: 4),
                  ],
                ),
              )
            ],
          ),
        ),
        // Рабочая зона выбранной вкладки
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: _buildDashboardTabContent(),
          ),
        )
      ],
    );
  }

  Widget _dashNavBtn(String id, String label, IconData icon) {
    bool active = _activeTab == id;
    return InkWell(
      onTap: () => setState(() => _activeTab = id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
            color: active ? Colors.indigo.withOpacity(0.1) : Colors.transparent,
            border: Border(
                left: BorderSide(
                    color: active ? Colors.indigo : Colors.transparent,
                    width: 4))),
        child: Row(
          children: [
            Icon(icon,
                color:
                    active ? Colors.indigo.shade400 : const Color(0xFF64748B),
                size: 16),
            const SizedBox(width: 12),
            Text(label,
                style: TextStyle(
                    color: active ? Colors.white : const Color(0xFF94A3B8),
                    fontSize: 12,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardTabContent() {
    // Вкладка: Библиотека VASC
    if (_activeTab == 'library') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Архив знаний VASC',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Colors.white)),
          const SizedBox(height: 24),
          Row(
            children: _booksList
                .map((book) => Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedBook = book),
                        child: Container(
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: _selectedBook?.id == book.id
                                ? Colors.indigo.shade900.withOpacity(0.2)
                                : const Color(0xFF0F172A),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: _selectedBook?.id == book.id
                                    ? Colors.indigo
                                    : const Color(0xFF1E293B)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                  width: 32,
                                  height: 4,
                                  decoration: BoxDecoration(
                                      color: book.color,
                                      borderRadius: BorderRadius.circular(10))),
                              const SizedBox(height: 12),
                              Text(book.title,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15)),
                              const SizedBox(height: 4),
                              Text(book.subject,
                                  style: const TextStyle(
                                      color: Colors.white30,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          if (_selectedBook != null) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF1E293B))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_selectedBook!.title,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  const SizedBox(height: 12),
                  Text(_selectedBook!.content,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 13, height: 1.5)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => _handleSendMessage(
                        "Проведи исследование по учебнику '${_selectedBook!.title}'"),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo.shade600,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    child: const Text('Спросить ИИ по книге',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12)),
                  )
                ],
              ),
            )
          ]
        ],
      );
    }

    // Вкладка: Карта связей (Улучшенная с интерактивным масштабированием)
    if (_activeTab == 'map') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Интерактивный граф связей',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Colors.white)),
          const SizedBox(height: 8),
          const Text(
              'Используйте жесты щипка для масштабирования (Zoom) и перемещения',
              style: TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFF1E293B))),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: InteractiveViewer(
                  boundaryMargin: const EdgeInsets.all(100),
                  minScale: 0.5,
                  maxScale: 3.0,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          decoration: BoxDecoration(
                              color: Colors.indigo.shade600,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.indigo.withOpacity(0.3),
                                    blurRadius: 10)
                              ]),
                          child: const Text('EDINAYA PRIRODA',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15)),
                        ),
                        const SizedBox(height: 48),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () => _openGlossary('диффузия'),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                    color: Colors.amber.withOpacity(0.1),
                                    border: Border.all(
                                        color: Colors.amber.withOpacity(0.3)),
                                    borderRadius: BorderRadius.circular(12)),
                                child: const Text('Физика: Диффузия (?)',
                                    style: TextStyle(
                                        color: Colors.amber,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11)),
                              ),
                            ),
                            const SizedBox(width: 24),
                            GestureDetector(
                              onTap: () => _openGlossary('атф'),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.1),
                                    border: Border.all(
                                        color: Colors.green.withOpacity(0.3)),
                                    borderRadius: BorderRadius.circular(12)),
                                child: const Text('Биология: Синтез АТФ (?)',
                                    style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11)),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      );
    }

    // Вкладка: Активность (Лента логов)
    if (_activeTab == 'activity') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Логи активности',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Colors.white)),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: [
                _buildActivityRow("Обработка RAG-запроса через FastAPI",
                    "Только что", "200 OK"),
                _buildActivityRow("Обновление контекстной памяти Mem0",
                    "5 минут назад", "SAVED"),
                _buildActivityRow("Событие индексации книги VASC в Storage",
                    "1 час назад", "SUCCESS"),
              ],
            ),
          )
        ],
      );
    }

    // Default: Обзор
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Рабочий стол исследователя',
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Colors.white)),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
                child: _buildStatCard(
                    'Законы', '$_lawsPercent%', Icons.bolt, Colors.amber)),
            const SizedBox(width: 16),
            Expanded(
                child: _buildStatCard('Междисциплинарные связи',
                    '$_connectionsCount', Icons.map, Colors.indigo)),
            const SizedBox(width: 16),
            Expanded(
                child: _buildStatCard('Исследовано сегодня', '+$_todayAdded',
                    Icons.refresh, Colors.green)),
          ],
        )
      ],
    );
  }

  Widget _buildStatCard(String label, String val, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF111827))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 16),
          Text(val,
              style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.white)),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildActivityRow(String title, String time, String status) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF111827))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(time,
                  style: const TextStyle(color: Colors.grey, fontSize: 10)),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8)),
            child: Text(status,
                style: const TextStyle(
                    color: Colors.green,
                    fontSize: 10,
                    fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  // --- ОВЕРЛЕИ (ГЛОССАРИЙ И ЭКСПЕДИЦИЯ) ---
  Widget _buildGlossaryOverlay() {
    return Positioned(
      top: 0,
      bottom: 0,
      right: 0,
      width: 320,
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF030712),
          border: Border(left: BorderSide(color: Color(0xFF1E293B))),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_activeGlossaryTerm?['subject'] ?? 'ТЕРМИН',
                    style: TextStyle(
                        color: Colors.indigo.shade400,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2)),
                IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                    onPressed: () => setState(() => _showGlossary = false)),
              ],
            ),
            const SizedBox(height: 16),
            Text(_activeGlossaryTerm?['title'] ?? '',
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            const SizedBox(height: 16),
            Text(_activeGlossaryTerm?['explanation'] ?? '',
                style: const TextStyle(
                    fontSize: 14, color: Colors.white70, height: 1.5)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: Colors.indigo.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12)),
              child: const Text('💡 Связь сопоставлена ИИ автоматически.',
                  style: TextStyle(color: Colors.indigoAccent, fontSize: 11)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildExpeditionDrawer() {
    return Positioned(
      top: 0,
      bottom: 0,
      right: 0,
      width: 450,
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF030712),
          border: Border(left: BorderSide(color: Color(0xFF1E293B))),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: const Color(0xFF0F172A),
              child: Row(
                children: [
                  IconButton(
                      icon: const Icon(Icons.arrow_back,
                          color: Colors.grey, size: 20),
                      onPressed: () =>
                          setState(() => _activeExpedition = false)),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Интеллектуальная экспедиция',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14)),
                      Text('Модель: ${_selectedAiModel.toUpperCase()}',
                          style: TextStyle(
                              color: Colors.indigo.shade400,
                              fontSize: 9,
                              fontFamily: 'monospace')),
                    ],
                  )
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _chatMessages.length,
                itemBuilder: (context, i) {
                  final msg = _chatMessages[i];
                  final isUser = msg.sender == 'user';
                  return Align(
                    alignment:
                        isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      constraints: const BoxConstraints(maxWidth: 320),
                      decoration: BoxDecoration(
                        color: isUser
                            ? Colors.indigo.shade600
                            : const Color(0xFF0F172A),
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(16),
                          topRight: const Radius.circular(16),
                          bottomLeft: Radius.circular(isUser ? 16 : 0),
                          bottomRight: Radius.circular(isUser ? 0 : 16),
                        ),
                      ),
                      child: Text(msg.text,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 13, height: 1.4)),
                    ),
                  );
                },
              ),
            ),
            if (_isAiTyping)
              const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('ИИ сопоставляет законы...',
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 11,
                          fontStyle: FontStyle.italic))),

            // Поле ввода чата
            Container(
              padding: const EdgeInsets.all(16),
              color: const Color(0xFF0F172A),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _chatController,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: _offlineMode
                            ? 'Задайте локальный вопрос...'
                            : 'Исследуйте междисциплинарную связь...',
                        hintStyle: const TextStyle(color: Colors.white24),
                        filled: true,
                        fillColor: const Color(0xFF030712),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none),
                      ),
                      onSubmitted: (val) => _handleSendMessage(val),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.indigoAccent),
                    onPressed: () => _handleSendMessage(_chatController.text),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
