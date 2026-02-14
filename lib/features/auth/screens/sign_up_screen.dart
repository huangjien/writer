import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';
import '../../../state/ai_service_settings.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/app_buttons.dart';
import '../../../shared/widgets/neumorphic_textfield.dart';
import '../state/auth_form_state.dart';

class SignUpScreen extends ConsumerWidget {
  const SignUpScreen({super.key, this.client});
  final http.Client? client;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _SignUpContent(client: client);
  }
}

class _SignUpContent extends ConsumerStatefulWidget {
  const _SignUpContent({this.client});
  final http.Client? client;

  @override
  ConsumerState<_SignUpContent> createState() => _SignUpContentState();
}

class _SignUpContentState extends ConsumerState<_SignUpContent> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
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
    _passwordController.dispose();
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

  Future<void> _signUp() async {
    final l10n = AppLocalizations.of(context)!;
    ref.read(authFormProvider.notifier).setLoading(true);
    ref.read(authFormProvider.notifier).clearError();

    try {
      String baseUrl;
      try {
        baseUrl = ref.read(aiServiceProvider);
      } catch (_) {
        baseUrl = 'http://localhost:5600/';
      }

      final url = _urlJoin(baseUrl, '/auth/signup');
      final res = await _client.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
        }),
      );

      if (res.statusCode != 200 && res.statusCode != 201) {
        String msg = l10n.signupFailed;
        try {
          final decoded = jsonDecode(res.body);
          if (decoded['detail'] != null) {
            msg = decoded['detail'].toString();
          }
        } catch (_) {}
        throw Exception(msg);
      }

      ref
          .read(authFormProvider.notifier)
          .setSuccess(l10n.accountCreatedCheckEmail);
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
      appBar: AppBar(title: Text(l10n.signUp)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: authState.successMessage != null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      authState.successMessage!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 24),
                    AppButtons.primary(
                      onPressed: () => context.go('/auth'),
                      label: l10n.backToSignIn,
                    ),
                  ],
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  NeumorphicTextField(
                    controller: _emailController,
                    hintText: l10n.email,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  NeumorphicTextField(
                    controller: _passwordController,
                    hintText: l10n.password,
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),
                  if (authState.error != null) ...[
                    Text(
                      authState.error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 8),
                  ],
                  AppButtons.primary(
                    onPressed: authState.isLoading ? () {} : _signUp,
                    label: l10n.createAccount,
                    isLoading: authState.isLoading,
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: AppButtons.text(
                      onPressed: () => context.go('/auth'),
                      label: l10n.alreadyHaveAccountSignIn,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
