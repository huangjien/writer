import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/remote_repository.dart';
import '../repositories/local_storage_repository.dart';
import '../services/prompts_service.dart';
import '../services/patterns_service.dart';
import '../services/auth_redirect_service.dart';

import '../services/story_lines_service.dart';
import '../services/pdf_service.dart';
import 'ai_service_settings.dart';
import 'admin_settings.dart';
import 'session_state.dart';
import 'storage_service_provider.dart';

// Export localStorageRepositoryProvider for use in tests
export 'providers.dart' show localStorageRepositoryProvider;

// Export sharedPreferencesProvider for use in tests
export 'storage_service_provider.dart' show sharedPreferencesProvider;

final isSignedInProvider = Provider<bool>((ref) {
  final sessionId = ref.watch(sessionProvider);
  return sessionId != null && sessionId.trim().isNotEmpty;
});

final authStateProvider = Provider<String?>((ref) {
  return ref.watch(sessionProvider);
});

class BackendUser {
  final String id;
  final String? email;
  const BackendUser({required this.id, this.email});
}

final currentUserProvider = FutureProvider<BackendUser?>((ref) async {
  final sessionId = ref.watch(sessionProvider);
  if (sessionId == null || sessionId.trim().isEmpty) return null;
  final remote = ref.watch(remoteRepositoryProvider);
  final res = await remote.get('auth/session');
  if (res is Map) {
    final id = res['id'];
    final email = res['email'];
    if (id is String && id.isNotEmpty) {
      return BackendUser(id: id, email: email is String ? email : null);
    }
  }
  return null;
});

final promptsServiceProvider = Provider<PromptsService>((ref) {
  String baseUrl;
  try {
    baseUrl = ref.watch(aiServiceProvider);
  } catch (_) {
    baseUrl = 'http://localhost:5600/';
  }
  final sessionId = ref.watch(sessionProvider);
  return PromptsService(
    baseUrl: baseUrl,
    sessionId: sessionId,
    onUnauthorized: () async {
      await ref.read(sessionProvider.notifier).clear();
      final authRedirectService = ref.read(authRedirectServiceProvider);
      await authRedirectService.redirectToLogin(ref);
    },
  );
});

final patternsServiceProvider = Provider<PatternsService>((ref) {
  String baseUrl;
  try {
    baseUrl = ref.watch(aiServiceProvider);
  } catch (_) {
    baseUrl = 'http://localhost:5600/';
  }
  final sessionId = ref.watch(sessionProvider);
  return PatternsService(
    baseUrl: baseUrl,
    sessionId: sessionId,
    onUnauthorized: () async {
      await ref.read(sessionProvider.notifier).clear();
      final authRedirectService = ref.read(authRedirectServiceProvider);
      await authRedirectService.redirectToLogin(ref);
    },
  );
});

final localStorageRepositoryProvider = Provider<LocalStorageRepository>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return LocalStorageRepository(storage);
});

final storyLinesServiceProvider = Provider<StoryLinesService>((ref) {
  String baseUrl;
  try {
    baseUrl = ref.watch(aiServiceProvider);
  } catch (_) {
    baseUrl = 'http://localhost:5600/';
  }
  final sessionId = ref.watch(sessionProvider);
  return StoryLinesService(
    baseUrl: baseUrl,
    sessionId: sessionId,
    onUnauthorized: () async {
      await ref.read(sessionProvider.notifier).clear();
      final authRedirectService = ref.read(authRedirectServiceProvider);
      await authRedirectService.redirectToLogin(ref);
    },
  );
});

final pdfServiceProvider = Provider<PdfService>((ref) {
  return PdfService();
});

final isAdminProvider = Provider<bool>((ref) {
  // Simplification for now: check adminModeProvider.
  // Backend roles logic was client-side check which is insecure anyway.
  return ref.watch(adminModeProvider);
});
