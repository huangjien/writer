import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:writer/services/logger_service.dart';

Future<void> testExecutable(FutureOr<void> Function() main) async {
  // Simple override of debugPrint for basic filtering
  debugPrint = (String? message, {int? wrapWidth}) {
    if (message == null) return;

    // Filter noisy patterns that cause log bloat
    if (message.contains('RenderFlex children have non-zero flex')) {
      return;
    }
    if (message.contains('When a row is in a parent that does not provide')) {
      return;
    }
    if (message.contains('These two directives are mutually exclusive')) return;
    if (message.contains('Consider setting mainAxisSize')) return;
    if (message.contains('The affected RenderFlex is:')) return;
    if (message.contains('creator: Row ← ReaderEditActions')) return;
    if (message.startsWith('[Settings]')) return;

    // Process through logger for additional filtering
    LoggerService().processLogLine(message, (String msg) {
      // Use stdout.write instead of print to avoid lint warning
      // Catch errors when stdout is already closed/bound
      try {
        stdout.write(msg);
        stdout.write('\n');
        // Force immediate flushing for real-time monitoring with tail
        stdout.flush();
      } catch (e) {
        // Ignore errors when stdout is already closed (can happen in parallel tests)
      }
    });
  };

  await main();
}
