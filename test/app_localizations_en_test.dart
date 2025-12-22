import 'package:flutter_test/flutter_test.dart';
import 'package:writer/l10n/app_localizations_en.dart';

void main() {
  test('Removed from Library string', () {
    final l10n = AppLocalizationsEn();
    expect(l10n.removedFromLibrary, 'Removed from Library');
  });

  test('Undo string', () {
    final l10n = AppLocalizationsEn();
    expect(l10n.undo, 'Undo');
  });

  test('Confirm delete description formatting', () {
    final l10n = AppLocalizationsEn();
    expect(
      l10n.confirmDeleteDescription('Sample'),
      "This will delete 'Sample' from your cloud library. Are you sure?",
    );
  });

  test('Continue at chapter formatting', () {
    final l10n = AppLocalizationsEn();
    expect(l10n.continueAtChapter('One'), 'Continue at chapter • One');
  });

  test('Cloud sync not enabled description', () {
    final l10n = AppLocalizationsEn();
    expect(
      l10n.supabaseNotEnabledDescription,
      'Cloud sync is not configured for this build.',
    );
  });
}
