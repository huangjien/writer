import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/features/ai_chat/state/ai_chat_providers.dart';
import '../logic/reader_shortcuts.dart';

class ReaderShortcutsWrapper extends ConsumerWidget {
  const ReaderShortcutsWrapper({
    super.key,
    required this.disabled,
    required this.onToggleSpeak,
    required this.onPrev,
    required this.onNext,
    required this.onOpenSettings,
    required this.child,
  });

  final bool disabled;
  final VoidCallback onToggleSpeak;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onOpenSettings;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatOpen = ref.watch(aiChatUiProvider);
    final Map<ShortcutActivator, Intent> shortcutsMap = disabled
        ? <ShortcutActivator, Intent>{}
        : <ShortcutActivator, Intent>{
            if (!chatOpen)
              const SingleActivator(LogicalKeyboardKey.space):
                  const ToggleSpeakIntent(),
            const SingleActivator(LogicalKeyboardKey.arrowLeft):
                const PrevIntent(),
            const SingleActivator(LogicalKeyboardKey.arrowRight):
                const NextIntent(),
            const SingleActivator(LogicalKeyboardKey.keyR, control: true):
                const OpenRateIntent(),
            const SingleActivator(LogicalKeyboardKey.keyV, control: true):
                const OpenVoiceIntent(),
          };
    return Shortcuts(
      shortcuts: shortcutsMap,
      child: Actions(
        actions: <Type, Action<Intent>>{
          ToggleSpeakIntent: CallbackAction<Intent>(
            onInvoke: (_) {
              onToggleSpeak();
              return null;
            },
          ),
          PrevIntent: CallbackAction<Intent>(
            onInvoke: (_) {
              onPrev();
              return null;
            },
          ),
          NextIntent: CallbackAction<Intent>(
            onInvoke: (_) {
              onNext();
              return null;
            },
          ),
          OpenRateIntent: CallbackAction<Intent>(
            onInvoke: (_) {
              onOpenSettings();
              return null;
            },
          ),
          OpenVoiceIntent: CallbackAction<Intent>(
            onInvoke: (_) {
              onOpenSettings();
              return null;
            },
          ),
        },
        child: child,
      ),
    );
  }
}
