import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:writer/features/editor/rich_text_editor.dart';

class MobileEditorShortcuts extends StatelessWidget {
  const MobileEditorShortcuts({
    super.key,
    required this.child,
    required this.contentController,
    required this.preview,
    required this.onSave,
    required this.onTogglePreview,
    required this.onShowHelp,
    required this.onDismiss,
  });

  final Widget child;
  final TextEditingController contentController;
  final bool preview;
  final VoidCallback onSave;
  final VoidCallback onTogglePreview;
  final VoidCallback onShowHelp;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.keyS, control: true): _SaveIntent(),
        SingleActivator(LogicalKeyboardKey.keyS, meta: true): _SaveIntent(),
        SingleActivator(LogicalKeyboardKey.keyP, control: true):
            _TogglePreviewIntent(),
        SingleActivator(LogicalKeyboardKey.keyP, meta: true):
            _TogglePreviewIntent(),
        SingleActivator(LogicalKeyboardKey.slash, control: true): _HelpIntent(),
        SingleActivator(LogicalKeyboardKey.slash, meta: true): _HelpIntent(),
        SingleActivator(LogicalKeyboardKey.keyB, control: true): _BoldIntent(),
        SingleActivator(LogicalKeyboardKey.keyB, meta: true): _BoldIntent(),
        SingleActivator(LogicalKeyboardKey.keyI, control: true):
            _ItalicIntent(),
        SingleActivator(LogicalKeyboardKey.keyI, meta: true): _ItalicIntent(),
        SingleActivator(LogicalKeyboardKey.keyU, control: true):
            _UnderlineIntent(),
        SingleActivator(LogicalKeyboardKey.keyU, meta: true):
            _UnderlineIntent(),
        SingleActivator(LogicalKeyboardKey.digit1, control: true):
            _HeadingIntent(),
        SingleActivator(LogicalKeyboardKey.digit1, meta: true):
            _HeadingIntent(),
        SingleActivator(LogicalKeyboardKey.keyK, control: true): _LinkIntent(),
        SingleActivator(LogicalKeyboardKey.keyK, meta: true): _LinkIntent(),
        SingleActivator(LogicalKeyboardKey.escape): _DismissIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          _SaveIntent: CallbackAction<_SaveIntent>(
            onInvoke: (_) {
              onSave();
              return null;
            },
          ),
          _TogglePreviewIntent: CallbackAction<_TogglePreviewIntent>(
            onInvoke: (_) {
              onTogglePreview();
              return null;
            },
          ),
          _HelpIntent: CallbackAction<_HelpIntent>(
            onInvoke: (_) {
              onShowHelp();
              return null;
            },
          ),
          _BoldIntent: CallbackAction<_BoldIntent>(
            onInvoke: (_) {
              MarkdownEditActions.toggleBold(contentController);
              return null;
            },
          ),
          _ItalicIntent: CallbackAction<_ItalicIntent>(
            onInvoke: (_) {
              MarkdownEditActions.toggleItalic(contentController);
              return null;
            },
          ),
          _UnderlineIntent: CallbackAction<_UnderlineIntent>(
            onInvoke: (_) {
              MarkdownEditActions.toggleUnderline(contentController);
              return null;
            },
          ),
          _HeadingIntent: CallbackAction<_HeadingIntent>(
            onInvoke: (_) {
              MarkdownEditActions.insertHeading(contentController);
              return null;
            },
          ),
          _LinkIntent: CallbackAction<_LinkIntent>(
            onInvoke: (_) {
              MarkdownEditActions.insertLink(contentController);
              return null;
            },
          ),
          _DismissIntent: CallbackAction<_DismissIntent>(
            onInvoke: (_) {
              if (preview) {
                onTogglePreview();
                return null;
              }
              onDismiss();
              return null;
            },
          ),
        },
        child: child,
      ),
    );
  }
}

class _SaveIntent extends Intent {
  const _SaveIntent();
}

class _TogglePreviewIntent extends Intent {
  const _TogglePreviewIntent();
}

class _HelpIntent extends Intent {
  const _HelpIntent();
}

class _BoldIntent extends Intent {
  const _BoldIntent();
}

class _ItalicIntent extends Intent {
  const _ItalicIntent();
}

class _UnderlineIntent extends Intent {
  const _UnderlineIntent();
}

class _HeadingIntent extends Intent {
  const _HeadingIntent();
}

class _LinkIntent extends Intent {
  const _LinkIntent();
}

class _DismissIntent extends Intent {
  const _DismissIntent();
}
