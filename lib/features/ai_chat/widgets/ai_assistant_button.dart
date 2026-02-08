import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/features/ai_chat/state/ai_chat_providers.dart';
import 'package:writer/shared/widgets/app_buttons.dart';

/// AI Assistant button for app bar actions
/// Add this to the actions list of any AppBar that needs AI assistant access
class AiAssistantButton extends ConsumerWidget {
  const AiAssistantButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOpen = ref.watch(aiChatUiProvider);
    final isServiceAvailable = ref.watch(aiServiceStatusProvider);

    // Only show button when service is available and sidebar is closed
    if (!isServiceAvailable || isOpen) {
      return const SizedBox.shrink();
    }

    return AppButtons.icon(
      iconData: Icons.auto_awesome,
      onPressed: () => ref.read(aiChatUiProvider.notifier).openSidebar(),
    );
  }
}
