import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/auth_repository.dart';

final authStateProvider = StateProvider<User?>((ref) {
  final asyncAuth = ref.watch(authStateChangesProvider);
  return asyncAuth.value;
});