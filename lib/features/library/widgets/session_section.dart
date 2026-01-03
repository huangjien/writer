import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/design_tokens.dart';

class SessionSection extends StatefulWidget {
  const SessionSection({super.key, required this.isSignedIn});
  final bool isSignedIn;

  @override
  State<SessionSection> createState() => _SessionSectionState();
}

class _SessionSectionState extends State<SessionSection> {
  bool _bannerShown = false;

  @override
  void initState() {
    super.initState();
    if (!widget.isSignedIn) {
      _showBanner();
    }
  }

  @override
  void didUpdateWidget(SessionSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSignedIn != oldWidget.isSignedIn) {
      if (!widget.isSignedIn) {
        _showBanner();
      } else {
        _hideBanner();
      }
    }
  }

  void _showBanner() {
    if (_bannerShown) return;
    _bannerShown = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      final messenger = ScaffoldMessenger.of(context);
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
  }

  void _hideBanner() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
    });
    _bannerShown = false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [SizedBox(height: Spacing.m)],
    );
  }
}
