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

    return Stack(
      children: [
        child,
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
                      return SizedBox(
                        width: w,
                        child: Navigator(
                          onGenerateRoute: (settings) {
                            return MaterialPageRoute(
                              builder: (context) =>
                                  const Material(child: AiChatSidebar()),
                            );
                          },
                        ),
                      );
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
