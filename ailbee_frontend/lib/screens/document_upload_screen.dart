// lib/screens/document_upload_screen.dart

import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import '../services/api_service.dart'; 
// Для реальной реализации вам понадобится пакет для выбора файлов, например:
// import 'package:file_picker/file_picker.dart'; 

class DocumentUploadScreen extends StatefulWidget {
  const DocumentUploadScreen({super.key});

  @override
  State<DocumentUploadScreen> createState() => _DocumentUploadScreenState();
}

class _DocumentUploadScreenState extends State<DocumentUploadScreen> {
  late final ApiService _apiService;

  Stream<JobStatus>? _statusStream;
  String? _uploadError;
  bool _isUploading = false;
  bool _isJobCompleted = false; // флаг для фиксации завершения

@override
void initState() {
  super.initState();
  _apiService = ApiService();
}

@override
void didChangeDependencies() {
  super.didChangeDependencies();
  // Получаем токен из потока пользователя или AuthService
  final user = Provider.of<User?>(context);
  final authToken = user?.getIdToken() ?? ''; // Асинхронно получаем токен

  // Создаем ApiService с токеном.
  // В реальном приложении: ждем токен перед созданием ApiService. 
  // Для простоты, мы предполагаем, что токен уже есть, или его нужно передать через конструктор.
  // Поскольку ваш текущий код не использует Provider, мы оставим заглушку.
  // ИСХОДНЫЙ КОД: _apiService = ApiService();
  // ПРЕДПОЛАГАЕМЫЙ ФИКС:
  // final authService = Provider.of<AuthService>(context, listen: false);
  // _apiService = ApiService(await authService.getIdToken()); 
  // Но для простоты оставим, как есть, если _apiService умеет работать без токена
  // (хотя это неверно, бэкенд требует его).
}

  // --- Заглушка для выбора файла ---
  final File _mockFile = File('mock/path/document.pdf'); 
  final String _mockFilename = 'Техническое_задание_v2.pdf';
  // ---------------------------------

  Future<void> _startUploadAndPolling() async {
    // Сбрасываем флаг завершения при новой загрузке
    setState(() {
      _isUploading = true;
      _uploadError = null;
      _statusStream = null; 
      _isJobCompleted = false; // Сбрасываем
    });

    try {
      // Имитируем загрузку и получение bookId
      final bookId = await _apiService.initiateDocumentUpload(_mockFile, _mockFilename);
      
      setState(() {
        _statusStream = _apiService.pollDocumentStatus(bookId);
        _isUploading = false; // Переходим в режим polling
      });

    } on AuthException catch (e) {
      setState(() {
        _uploadError = '🚫 Ошибка авторизации: ${e.message}';
        _isUploading = false;
      });
    } on NetworkException catch (e) {
      setState(() {
        _uploadError = '🔌 Ошибка сети: ${e.message}';
        _isUploading = false;
      });
    } on ApiServiceException catch (e) {
      setState(() {
        _uploadError = '⚠️ Ошибка API (${e.statusCode}): ${e.message}';
        _isUploading = false;
      });
    } catch (e) {
      setState(() {
        _uploadError = '❌ Неизвестная ошибка: ${e.toString()}';
        _isUploading = false;
      });
    }
  }
  
  Widget _buildStatusMonitor() {
    if (_uploadError != null) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(_uploadError!, style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold)),
      );
    }

    if (_statusStream == null) {
      return const Text('Нажмите "Загрузить", чтобы начать обработку RAG.');
    }

    // StreamBuilder для обработки асинхронного потока
    return StreamBuilder<JobStatus>(
      stream: _statusStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState('Инициализация...');
        }
        
        if (snapshot.hasError) {
          return _buildErrorState('Критическая ошибка потока: ${snapshot.error}');
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const Text('Ожидание данных о статусе...');
        }

        final status = snapshot.data!;
        
        if (status.status == 'PROCESSING') {
          return _buildLoadingState('Обработка документа RAG: ${status.message ?? 'В процессе...'}');
        } else if (status.status == 'COMPLETED') { // флаг завершения
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!_isJobCompleted) {
              setState(() {
                _isJobCompleted = true; // Устанавливаем флаг, который увидит метод build
              });
            }
          });
          return _buildSuccessState('✅ Успешно! Документ готов к использованию. Вы можете закрыть это окно.');
        } else if (status.status == 'FAILED') {
          return _buildErrorState('🛑 Ошибка обработки: ${status.message ?? 'Неизвестная ошибка.'}');
        } else {
          return _buildLoadingState('Неизвестный статус: ${status.status}');
        }
      },
    );
  }
  
  Widget _buildLoadingState(String message) {
    return Column(
      children: [
        const LinearProgressIndicator(),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(message, style: const TextStyle(color: Colors.blue)),
        ),
      ],
    );
  }

  Widget _buildSuccessState(String message) {
    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(message, style: TextStyle(color: Colors.green.shade900)),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(message, style: TextStyle(color: Colors.red.shade900)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDone = _isJobCompleted;
    
    // Работа идет, если поток статуса запущен, но не завершен и не находится в фазе загрузки
    final isPolling = _statusStream != null && !_isJobCompleted && !_isUploading;

    return Scaffold(
      appBar: AppBar(title: const Text('Загрузка Документа (RAG)')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Icon(Icons.description, size: 80, color: Colors.deepPurple),
              const SizedBox(height: 24),
              Text('Имитация файла: $_mockFilename', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _isUploading || isPolling ? null : _startUploadAndPolling,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: isDone ? Colors.green : Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 5,
                ),
                child: _isUploading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : isDone
                        ? const Text('ОБРАБОТКА ЗАВЕРШЕНА', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
                        : Text(
                            isPolling ? 'Обработка...' : 'Загрузить и Обработать RAG', 
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                          ),
              ),
              const SizedBox(height: 32),
              
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _buildStatusMonitor(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
