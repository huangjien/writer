import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:novel_reader/state/performance_settings.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  test('PerformanceSettingsNotifier initializes from prefs', () async {
    final prefs = await SharedPreferences.getInstance();
    final notifier = PerformanceSettingsNotifier(prefs);
    expect(notifier.state.prefetchNextChapter, true);
  });

  test('setPrefetchNextChapter updates state and persists', () async {
    final prefs = await SharedPreferences.getInstance();
    final notifier = PerformanceSettingsNotifier(prefs);
    await notifier.setPrefetchNextChapter(false);
    expect(notifier.state.prefetchNextChapter, false);
    expect(prefs.getBool('prefetch_next_chapter_enabled'), false);
  });
}
