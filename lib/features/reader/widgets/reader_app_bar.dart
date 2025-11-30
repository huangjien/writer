import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/features/ai_chat/state/ai_chat_providers.dart';

class ReaderAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const ReaderAppBar({super.key, required this.title, required this.onBack});

  final String title;
  final VoidCallback onBack;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAiServiceAvailable = ref.watch(aiServiceStatusProvider);

    return AppBar(
      title: Text(title),
      leading: Tooltip(
        message: MaterialLocalizations.of(context).backButtonTooltip,
        child: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack,
        ),
      ),
      actions: [
        // AI Chat button
        IconButton(
          icon: const Icon(Icons.smart_toy),
          onPressed: isAiServiceAvailable
              ? () {
                  ref.read(aiChatUiProvider.notifier).toggleSidebar();
                }
              : null,
          tooltip: isAiServiceAvailable
              ? 'AI Assistant'
              : 'AI Service Unavailable',
        ),
        Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_open),
            onPressed: () => Scaffold.of(context).openEndDrawer(),
            tooltip: 'Menu',
          ),
        ),
      ],
    );
  }
}
