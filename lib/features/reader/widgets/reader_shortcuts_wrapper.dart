import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/features/ai_chat/state/ai_chat_providers.dart';
import 'package:writer/shared/widgets/mobile_bottom_sheet.dart';
import 'package:writer/theme/design_tokens.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/features/reader/logic/reader_shortcuts.dart';

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

  void _showShortcutsHelp(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    MobileBottomSheet.show<void>(
      context: context,
      title: l10n.keyboardShortcuts,
      builder: (context) {
        final theme = Theme.of(context);
        final style = theme.textTheme.bodyMedium;
        return Padding(
          padding: const EdgeInsets.all(Spacing.l),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.shortcutSpace, style: style),
              const SizedBox(height: Spacing.s),
              Text(l10n.shortcutArrows, style: style),
              const SizedBox(height: Spacing.s),
              Text(l10n.shortcutRate, style: style),
              const SizedBox(height: Spacing.s),
              Text(l10n.shortcutVoice, style: style),
              const SizedBox(height: Spacing.s),
              Text(l10n.shortcutHelp, style: style),
              const SizedBox(height: Spacing.s),
              Text(l10n.shortcutEsc, style: style),
            ],
          ),
        );
      },
    );
  }

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
            const SingleActivator(LogicalKeyboardKey.slash, control: true):
                const OpenShortcutsHelpIntent(),
            const SingleActivator(LogicalKeyboardKey.slash, meta: true):
                const OpenShortcutsHelpIntent(),
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
          OpenShortcutsHelpIntent: CallbackAction<OpenShortcutsHelpIntent>(
            onInvoke: (_) {
              _showShortcutsHelp(context);
              return null;
            },
          ),
        },
        child: child,
      ),
    );
  }
}
