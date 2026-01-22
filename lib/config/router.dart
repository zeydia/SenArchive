import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sen_archive/screens/document/document_add_screen.dart';

import '../repositories/auth_repository.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/document/document_detail_screen.dart';
import '../screens/document/document_list_screen.dart';
import '../screens/splash_screen.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _sub = stream.asBroadcastStream().listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<dynamic> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final authAsync = ref.watch(authStateChangesProvider);
  final authRepo = ref.read(authRepositoryProvider);
  final refreshListenable = GoRouterRefreshStream(authRepo.authStateChanges);

  ref.onDispose(refreshListenable.dispose);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/document_list',
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      if (authAsync.isLoading) return null;

      final user = authAsync.value;
      final bool isAuthenticated = user != null;

      final bool isLoggingIn = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      if (!isAuthenticated && !isLoggingIn) {
        return '/login';
      }

      if (isAuthenticated && isLoggingIn) {
        return '/document_list';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => RegisterScreen(),
      ),
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => SplashScreen(),
      ),
      GoRoute(
        path: 'document_list',
        name: 'home',
        builder: (context, state) => DocumentListScreen(),
        routes: [
          GoRoute(
            path: 'document_add',
            name: 'add_document',
            builder: (context, state) => AddDocumentScreen(),
          ),
          GoRoute(
            path: 'document_details/:docId',
            name: 'document_details',
            builder: (context, state) {
              final docId = state.pathParameters['docId']!;
              return DocumentDetailScreen(documentId: docId);
            },
          ),
        ],
      ),
    ],
  );
});
