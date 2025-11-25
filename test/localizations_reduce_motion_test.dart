import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/l10n/app_localizations.dart';

void main() {
  group('AppLocalizations reduceMotion keys', () {
    test('English locale has reduceMotion keys', () {
      final l10n = lookupAppLocalizations(const Locale('en'));
      expect(l10n.reduceMotion, isNotEmpty);
      expect(l10n.reduceMotionDescription, isNotEmpty);
    });

    test('Chinese locale has reduceMotion keys', () {
      final l10n = lookupAppLocalizations(const Locale('zh'));
      expect(l10n.reduceMotion, isNotEmpty);
      expect(l10n.reduceMotionDescription, isNotEmpty);
    });
  });
}
