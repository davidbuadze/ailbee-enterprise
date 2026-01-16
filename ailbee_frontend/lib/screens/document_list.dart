// lib/screens/document_list.dart

import 'package:flutter/material.dart';
import '../services/api_service.dart';

class DocumentList extends StatelessWidget {
  final List<UserDocument> documents;

  const DocumentList({super.key, required this.documents});

  @override
  Widget build(BuildContext context) {
    if (documents.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'Нет загруженных документов для RAG. Загрузите первый!',
          style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
        ),
      );
    }
    
    return Container(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      height: 100, // Фиксированная высота для горизонтального скролла
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: documents.length,
        itemBuilder: (context, index) {
          final doc = documents[index];
          // Если статус - COMPLETED/PROCESSED, используем зеленый, иначе синий (пока PROCESSING)
          final color = (doc.status == 'PROCESSED' || doc.status == 'COMPLETED') 
                        ? Colors.green.shade400 
                        : Colors.blue.shade200;
          final icon = doc.fileType.contains('pdf') ? Icons.picture_as_pdf : Icons.insert_drive_file;
          
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Chip(
              avatar: Icon(icon, color: Colors.white, size: 18),
              label: Text(
                '${doc.title} (${doc.status})',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              backgroundColor: color,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            ),
          );
        },
      ),
    );
  }
}
