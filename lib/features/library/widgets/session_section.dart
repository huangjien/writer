import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/theme/design_tokens.dart';
import 'package:writer/shared/widgets/app_buttons.dart';

class SessionSection extends StatelessWidget {
  const SessionSection({super.key, required this.isSignedIn});
  final bool isSignedIn;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (!isSignedIn) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.signInToSync),
          const SizedBox(height: Spacing.s),
          AppButtons.primary(
            label: l10n.signIn,
            icon: Icons.login,
            onPressed: () => context.push('/auth'),
          ),
          const Divider(height: Spacing.m),
        ],
      );
    }
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [SizedBox(height: Spacing.m)],
    );
  }
}
