import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/document_model.dart';
import '../repositories/auth_repository.dart';
import '../repositories/document_repository.dart';
import 'auth_provider.dart';

final documentsStreamProvider = StreamProvider.autoDispose<List<DocumentModel>>((ref) {
  final repo = ref.read(documentRepositoryProvider);

  final authState = ref.watch(authStateChangesProvider);
  final userId = authState.value?.uid;

  final controller = StreamController<List<DocumentModel>>();

  Future<void> load() async {
    if (userId == null) return;

    try {
      final data = await repo.fetchDocuments(userId);
      if (!controller.isClosed) {
        controller.add(data);
      }
    } catch (e, st) {
      if (!controller.isClosed) {
        controller.addError(e, st);
      }
    }
  }

  if (userId != null) {
    load();
  }

  final timer = Timer.periodic(
    const Duration(seconds: 3),
        (_) => load(),
  );

  ref.onDispose(() {
    timer.cancel();
    controller.close();
  });

  return controller.stream;
});