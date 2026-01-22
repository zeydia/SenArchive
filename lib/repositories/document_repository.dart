import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/document_model.dart';
import '../services/api_service.dart';

class DocumentRepository {
  Future<void> addDocument({
    required String title,
    required String description,
    required String category,
    required File file,
    required String userId,
  }) async {
    final uri = Uri.parse(ApiService.addDocumentUrl());
    final req = http.MultipartRequest('POST', uri)
      ..fields['title'] = title.trim()
      ..fields['description'] = description.trim()
      ..fields['category'] = category.trim()
      ..fields['user_id'] = userId;

    req.files.add(
      await http.MultipartFile.fromPath('document', file.path),
    );

    final res = await req.send();
    final body = await res.stream.bytesToString();

    if (res.statusCode != 200) {
      throw Exception('Erreur API ${res.statusCode}: $body');
    }
  }

  Future<List<DocumentModel>> fetchDocuments(String userId) async {
    final uri = Uri.parse(ApiService.listDocumentsUrl(userId));
    final res = await http.get(uri);

    if (res.statusCode != 200) {
      throw Exception('Erreur API ${res.statusCode}: ${res.body}');
    }

    final json = jsonDecode(res.body);

    if (json is Map && json['ok'] == true && json['data'] is List) {
      final List data = json['data'];
      return data.map<DocumentModel>((e) {
        final Map<String, dynamic> normalizedMap =
        e is String ? Map<String, dynamic>.from(jsonDecode(e)) : Map<String, dynamic>.from(e);
        return DocumentModel.fromJson(normalizedMap);
      }).toList();
    }

    throw Exception('Format de réponse invalide');
  }

  Future<void> deleteDocument(String id) async {
    final uri = Uri.parse(ApiService.deleteDocumentUrl());
    final res = await http.post(uri, body: {'id': id});

    if (res.statusCode != 200) {
      throw Exception('Erreur API ${res.statusCode}: ${res.body}');
    }

    final Map<String, dynamic> response = jsonDecode(res.body);
    if (response['ok'] != true) {
      throw Exception('Échec de la suppression: ${res.body}');
    }
  }
}

final documentRepositoryProvider = Provider<DocumentRepository>((ref) {
  return DocumentRepository();
});