import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/design_tokens.dart';

class SessionSection extends StatefulWidget {
  const SessionSection({
    super.key,
    required this.isSupabaseEnabled,
    required this.isSignedIn,
  });
  final bool isSupabaseEnabled;
  final bool isSignedIn;

  @override
  State<SessionSection> createState() => _SessionSectionState();
}

class _SessionSectionState extends State<SessionSection> {
  bool _bannerShown = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (!widget.isSupabaseEnabled) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.supabaseNotEnabledDescription),
          const Divider(height: Spacing.m),
        ],
      );
    }
    if (!widget.isSignedIn) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.signInToSync),
          const SizedBox(height: Spacing.s),
          ElevatedButton.icon(
            icon: const Icon(Icons.login),
            label: Text(l10n.signIn),
            onPressed: () => context.push('/auth'),
          ),
          const Divider(height: Spacing.m),
          if (!_bannerShown)
            Builder(
              builder: (ctx) {
                _bannerShown = true;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  final messenger = ScaffoldMessenger.of(ctx);
                  messenger.removeCurrentMaterialBanner();
                  messenger.showMaterialBanner(
                    MaterialBanner(
                      content: Text(l10n.signInToSync),
                      actions: [
                        TextButton(
                          onPressed: () => context.push('/auth'),
                          child: Text(l10n.signIn),
                        ),
                        TextButton(
                          onPressed: () {
                            messenger.hideCurrentMaterialBanner();
                          },
                          child: Text(l10n.cancel),
                        ),
                      ],
                    ),
                  );
                });
                return const SizedBox.shrink();
              },
            ),
        ],
      );
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.hideCurrentMaterialBanner();
    });
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [SizedBox(height: Spacing.m)],
    );
  }
}
