import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/chapter.dart';
import '../../../state/chapter_edit_controller.dart';

enum DiscardDecision { keepEditing, discard, saveAndExit }

Future<DiscardDecision?> showDiscardDialog({
  required BuildContext context,
  required WidgetRef ref,
  required Chapter current,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final controller = ref.read(chapterEditControllerProvider(current).notifier);
  return showDialog<DiscardDecision?>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      bool saving = false;
      return StatefulBuilder(
        builder: (context, setStateSB) {
          return AlertDialog(
            title: Text(l10n.discardChangesTitle),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.discardChangesMessage),
                if (saving) ...[
                  const SizedBox(height: 12),
                  const LinearProgressIndicator(),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: saving
                    ? null
                    : () => Navigator.of(ctx).pop(DiscardDecision.keepEditing),
                child: Text(l10n.keepEditing),
              ),
              TextButton(
                onPressed: saving
                    ? null
                    : () => Navigator.of(ctx).pop(DiscardDecision.discard),
                child: Text(l10n.discardChanges),
              ),
              TextButton(
                onPressed: saving
                    ? null
                    : () async {
                        setStateSB(() => saving = true);
                        final ok = await controller.save();
                        setStateSB(() => saving = false);
                        if (ok) {
                          if (ctx.mounted) {
                            Navigator.of(ctx).pop(DiscardDecision.saveAndExit);
                          }
                        } else {
                          try {
                            final st = ref.read(
                              chapterEditControllerProvider(current),
                            );
                            final msg = st.errorMessage ?? l10n.error;
                            if (context.mounted) {
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(SnackBar(content: Text(msg)));
                            }
                          } catch (_) {}
                        }
                      },
                child: Text(l10n.saveAndExit),
              ),
            ],
          );
        },
      );
    },
  );
}
