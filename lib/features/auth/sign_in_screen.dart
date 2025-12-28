import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';
import '../../state/ai_service_settings.dart';
import '../../state/session_state.dart';
import '../../state/biometric_session_state.dart';
import '../../l10n/app_localizations.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key, this.client});

  final http.Client? client;

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  bool _biometricLoading = false;
  String? _error;
  late final http.Client _client;
  late final bool _disposeClient;

  @override
  void initState() {
    super.initState();
    _client = widget.client ?? http.Client();
    _disposeClient = widget.client == null;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(biometricSessionProvider.notifier).checkBiometricAvailability();
    });
  }

  String _urlJoin(String baseUrl, String path) {
    final b = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final p = path.startsWith('/') ? path : '/$path';
    return '$b$p';
  }

  Future<void> _signIn(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      String baseUrl;
      try {
        baseUrl = ref.read(aiServiceProvider);
      } catch (_) {
        baseUrl = 'http://localhost:5600/';
      }

      final url = _urlJoin(baseUrl, '/auth/login');
      final res = await _client.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
        }),
      );

      if (res.statusCode != 200) {
        String msg = l10n.loginFailed;
        try {
          final decoded = jsonDecode(res.body);
          if (decoded['detail'] != null) {
            msg = decoded['detail'].toString();
          }
        } catch (_) {}
        throw Exception(msg);
      }

      final data = jsonDecode(utf8.decode(res.bodyBytes));
      final sessionId = data['session_id'];
      if (sessionId is String && sessionId.isNotEmpty) {
        await ref.read(sessionProvider.notifier).setSessionId(sessionId);

        final biometricState = ref.read(biometricSessionProvider);
        if (biometricState != BiometricAuthState.unavailable &&
            biometricState != BiometricAuthState.enabled) {
          if (!mounted) return;
          _showBiometricSetupDialog(this.context, sessionId);
        } else {
          _navigateToSuccess();
        }
      } else {
        throw Exception(l10n.invalidResponseFromServer);
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _navigateToSuccess() {
    if (mounted) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      } else {
        context.go('/settings');
      }
    }
  }

  void _showBiometricSetupDialog(BuildContext context, String sessionId) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.enableBiometricLogin),
        content: Text(l10n.enableBiometricLoginDescription),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _enableBiometricAuth(context, sessionId);
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  Future<void> _enableBiometricAuth(
    BuildContext context,
    String sessionId,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _biometricLoading = true;
      _error = null;
    });

    try {
      final success = await ref
          .read(biometricSessionProvider.notifier)
          .enableBiometricAuth(sessionId);

      if (success) {
        _navigateToSuccess();
      } else {
        setState(() => _error = l10n.biometricAuthFailed);
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _biometricLoading = false);
    }
  }

  Future<void> _signInWithBiometrics(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _biometricLoading = true;
      _error = null;
    });

    try {
      final success = await ref
          .read(biometricSessionProvider.notifier)
          .signInWithBiometrics();

      if (success) {
        _navigateToSuccess();
      } else {
        setState(() => _error = l10n.biometricAuthFailed);
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _biometricLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    if (_disposeClient) {
      _client.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.signIn)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(labelText: l10n.email),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: l10n.password),
            ),
            const SizedBox(height: 20),
            if (_error != null) ...[
              Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 8),
            ],
            ElevatedButton(
              onPressed: _loading ? null : () => _signIn(context),
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.signIn),
            ),
            const SizedBox(height: 12),
            Consumer(
              builder: (context, ref, child) {
                final biometricState = ref.watch(biometricSessionProvider);

                if (biometricState == BiometricAuthState.unavailable) {
                  return const SizedBox.shrink();
                }

                if (biometricState == BiometricAuthState.enabled) {
                  return ElevatedButton.icon(
                    onPressed: _biometricLoading
                        ? null
                        : () => _signInWithBiometrics(context),
                    icon: _biometricLoading
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.fingerprint),
                    label: Text(l10n.signInWithBiometrics),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      foregroundColor: Colors.black87,
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => context.push('/signup'),
                  child: Text(l10n.signUp),
                ),
                TextButton(
                  onPressed: () => context.push('/forgot-password'),
                  child: Text(l10n.forgotPassword),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
