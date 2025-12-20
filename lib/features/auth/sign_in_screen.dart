import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../state/ai_service_settings.dart';
import '../../state/providers.dart';
import '../../state/session_state.dart';
import '../../l10n/app_localizations.dart';

class SignInScreen extends ConsumerStatefulWidget {
  final GoTrueClient? authClient;

  const SignInScreen({super.key, this.authClient});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;

  String _urlJoin(String baseUrl, String path) {
    final b = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final p = path.startsWith('/') ? path : '/$path';
    return '$b$p';
  }

  Future<void> _syncBackendSession(GoTrueClient auth) async {
    String baseUrl;
    try {
      baseUrl = ref.read(aiServiceProvider);
    } catch (_) {
      baseUrl = 'http://localhost:5600/';
    }
    var token = auth.currentSession?.accessToken;
    if (token == null && auth.currentUser != null) {
      try {
        await auth.refreshSession();
        token = auth.currentSession?.accessToken;
      } catch (_) {}
    }
    if (token == null || token.isEmpty) return;

    final res = await http.post(
      Uri.parse(_urlJoin(baseUrl, '/auth/session')),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      return;
    }
    final decoded = jsonDecode(utf8.decode(res.bodyBytes));
    if (decoded is! Map) return;
    final sessionId = decoded['session_id'];
    if (sessionId is! String || sessionId.trim().isEmpty) return;
    await ref.read(sessionProvider.notifier).setSessionId(sessionId);
  }

  Future<void> _signIn() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final auth = widget.authClient ?? Supabase.instance.client.auth;
      await auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      try {
        await auth.refreshSession();
      } catch (_) {}
      if (!mounted) return;
      try {
        await _syncBackendSession(auth);
      } catch (_) {}
      if (!mounted) return;
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      } else {
        context.go('/settings');
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signInWithProvider(OAuthProvider provider) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final auth = widget.authClient ?? Supabase.instance.client.auth;
      await auth.signInWithOAuth(
        provider,
        redirectTo: kIsWeb ? 'https://ai.huangjien.com' : null,
      );
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final enabled = ref.watch(supabaseEnabledProvider);
    if (!enabled) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text(l10n.authDisabledInBuild),
          ),
        ),
      );
    }
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
              onPressed: _loading ? null : _signIn,
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.signIn),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _loading
                  ? null
                  : () => _signInWithProvider(OAuthProvider.google),
              child: Text(l10n.signInWithGoogle),
            ),
            TextButton(
              onPressed: _loading
                  ? null
                  : () => _signInWithProvider(OAuthProvider.apple),
              child: Text(l10n.signInWithApple),
            ),
          ],
        ),
      ),
    );
  }
}
