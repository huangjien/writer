import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/features/reader/chapter_reader_screen.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/models/chapter.dart';
import 'package:writer/state/edit_permissions.dart';
import 'package:writer/state/motion_settings.dart';
import 'package:writer/features/ai_chat/services/ai_chat_service.dart';
import 'package:writer/state/ai_service_settings.dart';
import 'package:writer/state/app_settings.dart';
import 'package:writer/state/tts_settings.dart';
import 'package:writer/repositories/chapter_port.dart';
import 'package:writer/repositories/chapter_repository.dart';

class FakeAiChatService extends AiChatService {
  FakeAiChatService() : super('http://localhost:5600/');
  @override
  Future<bool> checkHealth() async => true;
  @override
  Future<String> sendMessage(String message) async => 'ok';
}

class FakeChapterRepo implements ChapterPort {
  final Map<String, List<Chapter>> _byNovel = {};

  FakeChapterRepo(List<Chapter> seed) {
    for (final c in seed) {
      _byNovel.putIfAbsent(c.novelId, () => []);
      _byNovel[c.novelId]!.add(c);
    }
  }

  @override
  Future<List<Chapter>> getChapters(String novelId) async {
    return List<Chapter>.from(_byNovel[novelId] ?? const []);
  }

  @override
  Future<Chapter> getChapter(Chapter chapter) async {
    return chapter;
  }

  @override
  Future<void> updateChapter(Chapter chapter) async {
    final list = _byNovel.putIfAbsent(chapter.novelId, () => []);
    final idx = list.indexWhere((c) => c.id == chapter.id);
    if (idx >= 0) {
      list[idx] = chapter;
    } else {
      list.add(chapter);
    }
  }

  @override
  Future<void> updateChapterIdx(String chapterId, int newIdx) async {
    for (final entry in _byNovel.entries) {
      final list = entry.value;
      final idx = list.indexWhere((c) => c.id == chapterId);
      if (idx >= 0) {
        final c = list[idx];
        list[idx] = c.copyWith(idx: newIdx);
        break;
      }
    }
  }

  @override
  Future<void> bulkShiftIdx(String novelId, int fromIdx, int delta) async {
    final list = _byNovel[novelId] ?? const [];
    for (var i = 0; i < list.length; i++) {
      final c = list[i];
      if (c.idx >= fromIdx) {
        list[i] = c.copyWith(idx: c.idx + delta);
      }
    }
  }

  @override
  Future<int> getNextIdx(String novelId) async {
    final list = _byNovel[novelId] ?? const [];
    if (list.isEmpty) return 1;
    final maxIdx = list.map((c) => c.idx).reduce((a, b) => a > b ? a : b);
    return maxIdx + 1;
  }

  @override
  Future<Chapter> createChapter({
    required String novelId,
    required int idx,
    String? title,
    String? content,
  }) async {
    final created = Chapter(
      id: 'c_${novelId}_$idx',
      novelId: novelId,
      idx: idx,
      title: title,
      content: content,
    );
    final list = _byNovel.putIfAbsent(novelId, () => []);
    list.add(created);
    return created;
  }

  @override
  Future<void> deleteChapter(String chapterId) async {
    for (final entry in _byNovel.entries) {
      entry.value.removeWhere((c) => c.id == chapterId);
    }
  }
}

void main() {
  const novelId = 'n1';
  final chapters = [
    const Chapter(
      id: 'c1',
      novelId: novelId,
      idx: 1,
      title: 'T1',
      content: 'C1',
    ),
    const Chapter(
      id: 'c2',
      novelId: novelId,
      idx: 2,
      title: 'T2',
      content: 'C2',
    ),
  ];

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('edit toggle switches between view and edit', (tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          motionSettingsProvider.overrideWith(
            (ref) => MotionSettingsNotifier(prefs),
          ),
          editPermissionsProvider(
            novelId,
          ).overrideWith((ref) => Future.value(true)),
          aiServiceProvider.overrideWith((ref) => AiServiceNotifier(prefs)),
          appSettingsProvider.overrideWith((ref) => AppSettingsNotifier(prefs)),
          ttsSettingsProvider.overrideWith((ref) => TtsSettingsNotifier(prefs)),
          aiChatServiceProvider.overrideWith((ref) => FakeAiChatService()),
          chapterRepositoryProvider.overrideWith(
            (ref) => FakeChapterRepo(chapters),
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
    expect(find.byTooltip('Enter Edit Mode'), findsOneWidget);
    await tester.tap(find.byTooltip('Enter Edit Mode'));
    await tester.pumpAndSettle();
    expect(find.byType(TextFormField), findsWidgets);
    await tester.tap(find.byTooltip('Exit Edit Mode'));
    await tester.pumpAndSettle();
    expect(find.byType(TextFormField), findsNothing);
  });

  // Additional interaction tests can be added here as needed.
}
