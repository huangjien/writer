import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/models/chapter.dart';
import 'package:writer/state/chapter_edit_controller.dart';
import 'package:writer/shared/widgets/app_buttons.dart';
import 'package:writer/shared/widgets/app_dialog.dart';

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
          return AppDialog(
            title: l10n.discardChangesTitle,
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
              AppButtons.text(
                onPressed: saving
                    ? () {}
                    : () => Navigator.of(ctx).pop(DiscardDecision.keepEditing),
                label: l10n.keepEditing,
                enabled: !saving,
              ),
              AppButtons.text(
                onPressed: saving
                    ? () {}
                    : () => Navigator.of(ctx).pop(DiscardDecision.discard),
                label: l10n.discardChanges,
                enabled: !saving,
                color: Theme.of(ctx).colorScheme.error,
              ),
              AppButtons.primary(
                onPressed: saving
                    ? () {}
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
                label: l10n.saveAndExit,
                enabled: !saving,
              ),
            ],
          );
        },
      );
    },
  );
}
