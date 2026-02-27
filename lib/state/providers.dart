import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/repositories/remote_repository.dart';
import 'package:writer/repositories/local_storage_repository.dart';
import 'package:writer/services/prompts_service.dart';
import 'package:writer/services/patterns_service.dart';
import 'package:writer/services/auth_redirect_service.dart';

import 'package:writer/services/story_lines_service.dart';
import 'package:writer/services/pdf_service.dart';
import 'controllers/ai_service_settings.dart';
import 'controllers/admin_settings.dart';
import 'models/session_state.dart';
import 'storage_service_provider.dart';

// Export localStorageRepositoryProvider for use in tests
export 'providers.dart' show localStorageRepositoryProvider;

// Export sharedPreferencesProvider for use in tests
export 'storage_service_provider.dart' show sharedPreferencesProvider;

// Export session providers
export 'models/session_state.dart' show sessionProvider;

// Export summary state providers
// Note: summaryController, summaryNotifier, and snowflakeService are not exported from their files
// They are provided via the Provider instances below

/// Helper function to safely watch AI service base URL with fallback
String _watchAiBaseUrlSafely(Ref ref) {
  try {
    return ref.watch(aiServiceProvider);
  } catch (_) {
    return 'http://localhost:5600/';
  }
}

/// Helper function to create unauthorized callback for service providers
Future<void> Function() _createUnauthorizedCallback(Ref ref) {
  return () async {
    await ref.read(sessionProvider.notifier).clear();
    final authRedirectService = ref.read(authRedirectServiceProvider);
    await authRedirectService.redirectToLogin(ref);
  };
}

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

  try {
    final res = await remote.get('auth/session', retryUnauthorized: false);
    if (res is Map) {
      final id = res['id'];
      final email = res['email'];
      if (id is String && id.isNotEmpty) {
        return BackendUser(id: id, email: email is String ? email : null);
      }
    }
    return null;
  } catch (_) {
    return null;
  }
});

final promptsServiceProvider = Provider<PromptsService>((ref) {
  final baseUrl = _watchAiBaseUrlSafely(ref);
  final sessionId = ref.watch(sessionProvider);
  return PromptsService(
    baseUrl: baseUrl,
    sessionId: sessionId,
    onUnauthorized: _createUnauthorizedCallback(ref),
  );
});

final patternsServiceProvider = Provider<PatternsService>((ref) {
  final baseUrl = _watchAiBaseUrlSafely(ref);
  final sessionId = ref.watch(sessionProvider);
  return PatternsService(
    baseUrl: baseUrl,
    sessionId: sessionId,
    onUnauthorized: _createUnauthorizedCallback(ref),
  );
});

final localStorageRepositoryProvider = Provider<LocalStorageRepository>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return LocalStorageRepository(storage);
});

final storyLinesServiceProvider = Provider<StoryLinesService>((ref) {
  final baseUrl = _watchAiBaseUrlSafely(ref);
  final sessionId = ref.watch(sessionProvider);
  return StoryLinesService(
    baseUrl: baseUrl,
    sessionId: sessionId,
    onUnauthorized: _createUnauthorizedCallback(ref),
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
