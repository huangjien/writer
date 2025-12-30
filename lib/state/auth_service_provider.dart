import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import 'ai_service_settings.dart';

/// Provider for AuthService
///
/// This provider can be overridden in tests with a mock implementation.
final authServiceProvider = Provider<AuthService>((ref) {
  String baseUrl;
  try {
    baseUrl = ref.watch(aiServiceProvider);
  } catch (_) {
    baseUrl = 'http://localhost:5600/';
  }
  return RemoteAuthService(baseUrl: baseUrl);
});
