import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:writer/state/session_state.dart';
import 'package:writer/state/biometric_session_state.dart';
import 'package:writer/state/redirect_provider.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/services/auth_service.dart';
import 'package:writer/state/auth_service_provider.dart';
import 'package:writer/shared/widgets/app_buttons.dart';
import 'package:writer/shared/widgets/app_dialog.dart';
import 'package:writer/shared/widgets/neumorphic_textfield.dart';
import 'package:writer/theme/design_tokens.dart';
import 'package:writer/features/auth/state/sign_in_state.dart';

class SignInScreen extends ConsumerWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const _SignInContent();
  }
}

class _SignInContent extends ConsumerStatefulWidget {
  const _SignInContent();

  @override
  ConsumerState<_SignInContent> createState() => _SignInContentState();
}

class _SignInContentState extends ConsumerState<_SignInContent> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
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
    ref.read(signInProvider.notifier).setLoading(true);
    ref.read(signInProvider.notifier).clearError();
    try {
      final result = await _authService.signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!result.success) {
        throw Exception(result.errorMessage ?? l10n.loginFailed);
      }

      await ref.read(sessionProvider.notifier).setSessionId(result.sessionId!);
      if (result.refreshToken != null) {
        await ref
            .read(sessionProvider.notifier)
            .setRefreshToken(result.refreshToken);
      }
      _passwordController.clear();

      final biometricState = ref.read(biometricSessionProvider);
      if (biometricState != BiometricAuthState.unavailable &&
          biometricState != BiometricAuthState.enabled) {
        if (!mounted) return;
        _showBiometricSetupDialog(
          // ignore: use_build_context_synchronously
          context,
          result.sessionId!,
          result.refreshToken,
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      } else {
        _navigateToSuccess();
      }
    } catch (e) {
      if (mounted) ref.read(signInProvider.notifier).setError(e.toString());
    } finally {
      if (mounted) ref.read(signInProvider.notifier).setLoading(false);
    }
  }

  void _navigateToSuccess() {
    if (mounted) {
      final savedRedirect = ref.read(authRedirectProvider);
      final queryRedirect = GoRouterState.of(
        context,
      ).uri.queryParameters['redirect'];

      final redirectRoute = _sanitizeRedirect(savedRedirect ?? queryRedirect);

      if (kDebugMode) {
        debugPrint(
          'Auth redirect after login: destination=$redirectRoute saved=$savedRedirect query=$queryRedirect',
        );
      }

      ref.read(authRedirectProvider.notifier).clearRedirect();
      context.go(redirectRoute);
    }
  }

  String _sanitizeRedirect(String? candidate) {
    if (candidate == null || candidate.trim().isEmpty) {
      return '/';
    }

    final parsed = Uri.tryParse(candidate);
    if (parsed == null) {
      return '/';
    }

    if (parsed.hasScheme) {
      return '/';
    }

    final path = parsed.path;
    if (!path.startsWith('/')) {
      return '/';
    }

    if (path == '/auth' ||
        path == '/signup' ||
        path == '/forgot-password' ||
        path == '/reset-password') {
      return '/';
    }

    return parsed.toString();
  }

  void _showBiometricSetupDialog(
    BuildContext context,
    String sessionId,
    String? refreshToken, {
    String? email,
    String? password,
  }) {
    final l10n = AppLocalizations.of(context)!;
    bool storeCredentials = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AppDialog(
            title: l10n.enableBiometricLogin,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.enableBiometricLoginDescription),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: Text(l10n.saveCredentialsForBiometric),
                  subtitle: Text(l10n.saveCredentialsForBiometricDescription),
                  value: storeCredentials,
                  onChanged: (value) =>
                      setState(() => storeCredentials = value ?? false),
                ),
              ],
            ),
            actions: [
              AppButtons.text(
                onPressed: () {
                  Navigator.of(context).pop();
                  _navigateToSuccess();
                },
                label: l10n.cancel,
              ),
              AppButtons.primary(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await _enableBiometricAuth(
                    context,
                    sessionId,
                    refreshToken,
                    email: email,
                    password: password,
                    storeCredentials: storeCredentials,
                  );
                },
                label: l10n.save,
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _enableBiometricAuth(
    BuildContext context,
    String sessionId,
    String? refreshToken, {
    String? email,
    String? password,
    bool? storeCredentials,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    ref.read(signInProvider.notifier).setBiometricLoading(true);
    ref.read(signInProvider.notifier).clearError();

    try {
      final success = await ref
          .read(biometricSessionProvider.notifier)
          .enableBiometricAuth(sessionId, refreshToken: refreshToken);

      if (success &&
          storeCredentials == true &&
          email != null &&
          password != null) {
        await ref
            .read(biometricServiceProvider)
            .storeCredentials(email, password);
      }

      if (success) {
        _navigateToSuccess();
      } else {
        ref.read(signInProvider.notifier).setError(l10n.biometricAuthFailed);
      }
    } catch (e) {
      ref.read(signInProvider.notifier).setError(e.toString());
    } finally {
      if (mounted) ref.read(signInProvider.notifier).setBiometricLoading(false);
    }
  }

  Future<void> _signInWithBiometrics(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    ref.read(signInProvider.notifier).setBiometricLoading(true);
    ref.read(signInProvider.notifier).clearError();

    try {
      final success = await ref
          .read(biometricSessionProvider.notifier)
          .signInWithBiometrics();

      if (success) {
        _navigateToSuccess();
      } else {
        final biometricNotifier = ref.read(biometricSessionProvider.notifier);
        final errorType = biometricNotifier.lastErrorType;

        String errorMessage;
        switch (errorType) {
          case BiometricErrorType.tokensExpired:
            errorMessage = l10n.biometricTokensExpired;
            break;
          case BiometricErrorType.noTokens:
            errorMessage = l10n.biometricNoTokens;
            break;
          case BiometricErrorType.tokenError:
            errorMessage = l10n.biometricTokenError;
            break;
          case BiometricErrorType.technicalError:
            errorMessage = l10n.biometricTechnicalError;
            break;
          case BiometricErrorType.credentialsInvalid:
            errorMessage = l10n.biometricTokenError;
            break;
          case BiometricErrorType.authenticationFailed:
          default:
            errorMessage = l10n.biometricAuthFailed;
            break;
        }

        ref.read(signInProvider.notifier).setError(errorMessage);
      }
    } catch (e) {
      ref.read(signInProvider.notifier).setError(e.toString());
    } finally {
      if (mounted) ref.read(signInProvider.notifier).setBiometricLoading(false);
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
    final signInState = ref.watch(signInProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.signIn)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NeumorphicTextField(
              key: const Key('email_field'),
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              hintText: l10n.email,
              textInputAction: TextInputAction.next,
              onSubmitted: (_) {
                FocusScope.of(context).nextFocus();
              },
            ),
            const SizedBox(height: 12),
            NeumorphicTextField(
              key: const Key('password_field'),
              controller: _passwordController,
              obscureText: signInState.obscurePassword,
              hintText: l10n.password,
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      signInState.obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      ref
                          .read(signInProvider.notifier)
                          .togglePasswordVisibility();
                    },
                  ),
                  IconButton(
                    key: const Key('sign_in_button'),
                    icon: const Icon(Icons.login),
                    onPressed: signInState.isLoading
                        ? null
                        : () => _signIn(context),
                  ),
                ],
              ),
              onSubmitted: (_) => _signIn(context),
            ),
            const SizedBox(height: 20),
            if (signInState.error != null) ...[
              Text(
                signInState.error!,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 8),
            ],
            if (signInState.isLoading)
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
                  return AppButtons.primary(
                    onPressed: signInState.isBiometricLoading
                        ? () {}
                        : () => _signInWithBiometrics(context),
                    icon: signInState.isBiometricLoading
                        ? null
                        : Icons.fingerprint,
                    label: l10n.signInWithBiometrics,
                    isLoading: signInState.isBiometricLoading,
                    fullWidth: true,
                  );
                }

                return const SizedBox.shrink();
              },
            ),
            const SizedBox(height: 20),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              runSpacing: Spacing.s,
              spacing: Spacing.m,
              children: [
                AppButtons.text(
                  onPressed: () => context.push('/signup'),
                  label: l10n.signUp,
                ),
                AppButtons.text(
                  onPressed: () => context.push('/forgot-password'),
                  label: l10n.forgotPassword,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
