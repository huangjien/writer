import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/features/ai_chat/state/ai_chat_providers.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/shared/widgets/app_buttons.dart';

class ReaderAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const ReaderAppBar({super.key, required this.title, required this.onBack});

  final String title;
  final VoidCallback onBack;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAiServiceAvailable = ref.watch(aiServiceStatusProvider);

    final l10n = AppLocalizations.of(context)!;
    return AppBar(
      title: Text(title),
      leading: AppButtons.icon(
        iconData: Icons.arrow_back,
        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        onPressed: onBack,
      ),
      actions: [
        AppButtons.icon(
          iconData: Icons.smart_toy,
          onPressed: () => ref.read(aiChatUiProvider.notifier).toggleSidebar(),
          enabled: isAiServiceAvailable,
          tooltip: isAiServiceAvailable
              ? l10n.aiAssistant
              : l10n.aiServiceUnavailable,
        ),
        Builder(
          builder: (context) => AppButtons.icon(
            iconData: Icons.menu_open,
            onPressed: () => Scaffold.of(context).openDrawer(),
            tooltip: l10n.menu,
          ),
        ),
      ],
    );
  }
}
