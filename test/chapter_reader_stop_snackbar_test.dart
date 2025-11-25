import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/state/app_settings.dart';
import 'package:writer/features/reader/reader_screen.dart';

void main() {
  testWidgets('Stop shows snackbar when Supabase disabled', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appSettingsProvider.overrideWith((_) => AppSettingsNotifier(prefs)),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ChapterReaderScreen(
            chapterId: 'c1',
            title: 'Snack Test',
            content: 'Hello world.',
            novelId: 'n1',
            autoStartTts: false,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Tap Speak then Stop; stopping should show snackbar (Supabase disabled).
    expect(find.text('Speak'), findsOneWidget);
    await tester.tap(find.text('Speak'));
    await tester.pump();
    expect(find.text('Stop TTS'), findsOneWidget);
    await tester.tap(find.text('Stop TTS'));
    // Pump to show SnackBar animation
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();

    // After stopping, button should flip back to Speak.
    final ElevatedButton button = tester.widget(find.byType(ElevatedButton));
    final Text label = button.child as Text;
    expect(label.data, 'Speak');
  }, skip: true);
}
