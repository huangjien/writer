import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';
import '../../../state/ai_service_settings.dart';
import '../../../state/session_state.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/app_buttons.dart';
import '../../../shared/widgets/neumorphic_textfield.dart';
import '../state/auth_form_state.dart';

class ResetPasswordScreen extends ConsumerWidget {
  const ResetPasswordScreen({super.key, this.client});
  final http.Client? client;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _ResetPasswordContent(client: client);
  }
}

class _ResetPasswordContent extends ConsumerStatefulWidget {
  const _ResetPasswordContent({this.client});
  final http.Client? client;

  @override
  ConsumerState<_ResetPasswordContent> createState() =>
      _ResetPasswordContentState();
}

class _ResetPasswordContentState extends ConsumerState<_ResetPasswordContent> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
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
    _passwordController.dispose();
    _confirmController.dispose();
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

  Future<void> _updatePassword() async {
    final l10n = AppLocalizations.of(context)!;
    if (_passwordController.text != _confirmController.text) {
      ref.read(authFormProvider.notifier).setError(l10n.passwordsDoNotMatch);
      return;
    }

    ref.read(authFormProvider.notifier).setLoading(true);
    ref.read(authFormProvider.notifier).clearError();

    try {
      final sessionId = ref.read(sessionProvider);

      String baseUrl;
      try {
        baseUrl = ref.read(aiServiceProvider);
      } catch (_) {
        baseUrl = 'http://localhost:5600/';
      }

      final url = _urlJoin(baseUrl, '/auth/password');
      final Map<String, String> headers = {'Content-Type': 'application/json'};

      if (sessionId != null) {
        headers['X-Session-Id'] = sessionId;
      } else {
        throw Exception(l10n.sessionInvalidLoginAgain);
      }

      final res = await _client.patch(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode({'password': _passwordController.text}),
      );

      if (res.statusCode != 200) {
        String msg = l10n.updateFailed;
        try {
          final decoded = jsonDecode(res.body);
          if (decoded['detail'] != null) {
            msg = decoded['detail'].toString();
          }
        } catch (_) {}
        throw Exception(msg);
      }

      final successMsg = l10n.passwordUpdatedSuccessfully;
      ref.read(authFormProvider.notifier).setSuccess(successMsg);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(successMsg)));
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        } else {
          context.go('/settings');
        }
      }
    } catch (e) {
      if (mounted) ref.read(authFormProvider.notifier).setError(e.toString());
    } finally {
      if (mounted) ref.read(authFormProvider.notifier).setLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authFormProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.resetPassword)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            NeumorphicTextField(
              controller: _passwordController,
              hintText: l10n.newPassword,
              obscureText: true,
            ),
            const SizedBox(height: 12),
            NeumorphicTextField(
              controller: _confirmController,
              hintText: l10n.confirmPassword,
              obscureText: true,
            ),
            const SizedBox(height: 20),
            if (authState.error != null) ...[
              Text(authState.error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 8),
            ],
            AppButtons.primary(
              onPressed: authState.isLoading ? () {} : _updatePassword,
              label: l10n.updatePassword,
              isLoading: authState.isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
