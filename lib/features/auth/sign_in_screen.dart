import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../state/session_state.dart';
import '../../state/biometric_session_state.dart';
import '../../state/redirect_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../services/auth_service.dart';
import '../../state/auth_service_provider.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  bool _biometricLoading = false;
  String? _error;
  late final AuthService _authService;

  @override
  void initState() {
    super.initState();
    _authService = ref.read(authServiceProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(biometricSessionProvider.notifier).checkBiometricAvailability();
    });
  }

  Future<void> _signIn(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await _authService.signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!result.success) {
        throw Exception(result.errorMessage ?? l10n.loginFailed);
      }

      await ref.read(sessionProvider.notifier).setSessionId(result.sessionId!);

      final biometricState = ref.read(biometricSessionProvider);
      if (biometricState != BiometricAuthState.unavailable &&
          biometricState != BiometricAuthState.enabled) {
        if (!mounted) return;
        _showBiometricSetupDialog(this.context, result.sessionId!);
      } else {
        _navigateToSuccess();
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _navigateToSuccess() {
    if (mounted) {
      // Navigate back to the original route if it was saved
      final redirectRoute = ref
          .read(authRedirectProvider.notifier)
          .getRedirectRoute();
      if (redirectRoute != '/') {
        // There was a saved route, navigate back to it
        ref.read(authRedirectProvider.notifier).clearRedirect();
        context.go(redirectRoute);
      } else if (Navigator.of(context).canPop()) {
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
            onPressed: () {
              Navigator.of(context).pop();
              _navigateToSuccess();
            },
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
              textInputAction: TextInputAction.next,
              onSubmitted: (_) {
                FocusScope.of(context).nextFocus();
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: l10n.password),
              onSubmitted: (_) => _signIn(context),
            ),
            const SizedBox(height: 20),
            if (_error != null) ...[
              Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 8),
            ],
            if (_loading)
              const Center(
                child: SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
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
