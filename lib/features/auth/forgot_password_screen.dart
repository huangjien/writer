import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';
import '../../state/ai_service_settings.dart';
import '../../l10n/app_localizations.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key, this.client});
  final http.Client? client;

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _loading = false;
  String? _error;
  String? _successMessage;
  late final http.Client _client;
  late final bool _disposeClient;

  @override
  void initState() {
    super.initState();
    _client = widget.client ?? http.Client();
    _disposeClient = widget.client == null;
  }

  @override
  void dispose() {
    _emailController.dispose();
    if (_disposeClient) {
      _client.close();
    }
    super.dispose();
  }

  String _urlJoin(String baseUrl, String path) {
    final b = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final p = path.startsWith('/') ? path : '/$path';
    return '$b$p';
  }

  Future<void> _submit() async {
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

      final url = _urlJoin(baseUrl, '/auth/reset-password-request');
      final res = await _client.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': _emailController.text.trim()}),
      );

      if (res.statusCode != 200) {
        String msg = l10n.requestFailed;
        try {
          final decoded = jsonDecode(res.body);
          if (decoded['detail'] != null) {
            msg = decoded['detail'].toString();
          }
        } catch (_) {}
        throw Exception(msg);
      }

      // Success
      setState(() {
        _successMessage = l10n.ifAccountExistsResetLinkSent;
      });
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.forgotPassword)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _successMessage != null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.email, color: Colors.blue, size: 64),
                    const SizedBox(height: 16),
                    Text(
                      _successMessage!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => context.go('/signin'),
                      child: Text(l10n.backToSignIn),
                    ),
                  ],
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.enterEmailForResetLink),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(labelText: l10n.email),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),
                  if (_error != null) ...[
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 8),
                  ],
                  ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    child: _loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.sendResetLink),
                  ),
                ],
              ),
      ),
    );
  }
}
