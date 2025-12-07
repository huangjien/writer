import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/features/reader/chapter_reader_screen.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/models/chapter.dart';
import 'package:writer/state/app_settings.dart';
import 'package:writer/state/tts_settings.dart';
import 'package:writer/features/ai_chat/services/ai_chat_service.dart';

void main() {
  const novelId = 'n1';

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('smoke: ChapterReaderScreen builds', (tester) async {
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appSettingsProvider.overrideWith((ref) => AppSettingsNotifier(prefs)),
          ttsSettingsProvider.overrideWith((ref) => TtsSettingsNotifier(prefs)),
          aiChatServiceProvider.overrideWith(
            (ref) => AiChatService('http://localhost:5600/'),
          ),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ChapterReaderScreen(
            chapterId: 'c1',
            title: 'T1',
            content: 'C1',
            novelId: novelId,
            allChapters: [
              Chapter(
                id: 'c1',
                novelId: novelId,
                idx: 1,
                title: 'T1',
                content: 'C1',
              ),
              Chapter(
                id: 'c2',
                novelId: novelId,
                idx: 2,
                title: 'T2',
                content: 'C2',
              ),
            ],
            currentIdx: 0,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(ChapterReaderScreen), findsOneWidget);
  });
}
