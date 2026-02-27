import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/models/chapter.dart';
import 'package:writer/state/chapter_edit_controller.dart';
import 'edit_discard_dialog.dart';

bool isEditDirty(WidgetRef ref, Chapter current) {
  try {
    final state = ref.read(chapterEditControllerProvider(current));
    return state.isDirty;
  } catch (_) {
    return false;
  }
}

Future<DiscardDecision?> showDiscardDialogBridge({
  required BuildContext context,
  required WidgetRef ref,
  required Chapter current,
}) async {
  return showDiscardDialog(context: context, ref: ref, current: current);
}
