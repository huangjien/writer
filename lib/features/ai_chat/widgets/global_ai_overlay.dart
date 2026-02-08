import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/features/ai_chat/state/ai_chat_providers.dart';
import 'ai_chat_sidebar.dart';

class GlobalAiAssistantOverlay extends ConsumerWidget {
  final Widget child;
  const GlobalAiAssistantOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOpen = ref.watch(aiChatUiProvider);
    final isServiceAvailable = ref.watch(aiServiceStatusProvider);

    return Stack(
      children: [
        child,
        // FAB (Only if closed)
        if (!isOpen && isServiceAvailable)
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton(
              heroTag: 'ai_assistant_fab',
              onPressed: () =>
                  ref.read(aiChatUiProvider.notifier).openSidebar(),
              child: const Icon(Icons.smart_toy),
            ),
          ),
        // Sidebar Overlay
        if (isOpen)
          Positioned.fill(
            child: Stack(
              children: [
                // Scrim
                GestureDetector(
                  onTap: () =>
                      ref.read(aiChatUiProvider.notifier).closeSidebar(),
                  child: Container(color: Colors.black54),
                ),
                // Sidebar
                Align(
                  alignment: Alignment.centerRight,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final w = constraints.maxWidth > 400
                          ? 400.0
                          : constraints.maxWidth * 0.85;
                      return SizedBox(width: w, child: const AiChatSidebar());
                    },
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
