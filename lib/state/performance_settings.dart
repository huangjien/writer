import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _prefPrefetchNext = 'prefetch_next_chapter_enabled';

class PerformanceSettings {
  final bool prefetchNextChapter;
  const PerformanceSettings({required this.prefetchNextChapter});

  PerformanceSettings copyWith({bool? prefetchNextChapter}) =>
      PerformanceSettings(
        prefetchNextChapter: prefetchNextChapter ?? this.prefetchNextChapter,
      );
}

class PerformanceSettingsNotifier extends StateNotifier<PerformanceSettings> {
  PerformanceSettingsNotifier(this._prefs)
    : super(
        PerformanceSettings(
          prefetchNextChapter: _prefs?.getBool(_prefPrefetchNext) ?? true,
        ),
      );

  PerformanceSettingsNotifier.lazy()
    : _prefs = null,
      super(const PerformanceSettings(prefetchNextChapter: true)) {
    _init();
  }

  SharedPreferences? _prefs;

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    final enabled = _prefs!.getBool(_prefPrefetchNext) ?? true;
    state = state.copyWith(prefetchNextChapter: enabled);
  }

  Future<void> setPrefetchNextChapter(bool value) async {
    state = state.copyWith(prefetchNextChapter: value);
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    _prefs = prefs;
    await prefs.setBool(_prefPrefetchNext, value);
  }
}

final performanceSettingsProvider =
    StateNotifierProvider<PerformanceSettingsNotifier, PerformanceSettings>((
      ref,
    ) {
      return PerformanceSettingsNotifier.lazy();
    });
