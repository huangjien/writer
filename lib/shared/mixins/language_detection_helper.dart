import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:writer/utils/language_detector.dart';
import 'package:writer/shared/constants.dart' show kDebounceMedium;

class LanguageDetectionHelper {
  LanguageDetectionHelper({String initialLanguage = 'en'})
    : _notifier = ValueNotifier<String>(initialLanguage);

  final ValueNotifier<String> _notifier;
  Timer? _debounceTimer;

  ValueNotifier<String> get notifier => _notifier;

  void updateDetection(String text) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(kDebounceMedium, () {
      final detectedCode = text.isNotEmpty
          ? LanguageDetector.detectLanguage(text)
          : 'en';
      _notifier.value = detectedCode;
    });
  }

  void dispose() {
    _debounceTimer?.cancel();
    _notifier.dispose();
  }
}
