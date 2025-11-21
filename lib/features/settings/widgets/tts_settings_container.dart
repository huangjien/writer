import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'tts_settings_section.dart';
import '../../../state/app_settings.dart';
import '../../../state/tts_settings.dart';

class TtsSettingsContainer extends ConsumerStatefulWidget {
  const TtsSettingsContainer({super.key});

  @override
  ConsumerState<TtsSettingsContainer> createState() =>
      _TtsSettingsContainerState();
}

class _TtsSettingsContainerState extends ConsumerState<TtsSettingsContainer> {
  final FlutterTts _tts = FlutterTts();
  List<Map<String, dynamic>> _voices = const [];
  bool _loadingVoices = true;
  List<String> _locales = const [];
  bool _loadingLocales = true;
  int _retryCount = 0;
  static const int _maxRetries = 3;

  @override
  void initState() {
    super.initState();
    _initTts();
    _loadVoices();
  }

  Future<void> _initTts() async {
    try {
      await _tts.awaitSpeakCompletion(true);
    } catch (_) {}
  }

  Future<void> _loadVoices({bool allowRetry = true}) async {
    try {
      final raw = await _tts.getVoices;
      final list = <Map<String, dynamic>>[];
      if (raw is List) {
        for (final e in raw) {
          if (e is Map) {
            final m = Map<String, dynamic>.from(e);
            final n = (m['name'] ?? '').toString();
            if (n.isNotEmpty) list.add(m);
          }
        }
      }
      setState(() {
        _voices = list;
        _loadingVoices = false;
      });
    } catch (_) {
      setState(() {
        _loadingVoices = false;
      });
    }
    try {
      final langs = await _tts.getLanguages;
      if (langs is List) {
        setState(() {
          _locales = langs.map((l) => l.toString()).toList();
          _loadingLocales = false;
        });
      }
    } catch (_) {
      setState(() => _loadingLocales = false);
    }
    if (allowRetry &&
        kIsWeb &&
        mounted &&
        (_voices.isEmpty || _locales.isEmpty) &&
        _retryCount < _maxRetries) {
      _retryCount += 1;
      Future.delayed(const Duration(milliseconds: 800), () {
        if (!mounted) return;
        _loadVoices(allowRetry: true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLocale = ref.watch(appSettingsProvider);
    final settings = ref.watch(ttsSettingsProvider);
    final appLangCode = appLocale.languageCode;
    final filteredVoices = _voices
        .where((v) => ((v['locale'] as String?) ?? '').startsWith(appLangCode))
        .toList();
    final filteredLocales = _locales
        .where((l) => l.startsWith(appLangCode))
        .toList();
    String voiceKey(Map<String, dynamic> v) =>
        (v['identifier'] as String?) ?? (v['name'] as String? ?? '');
    final Map<String, Map<String, dynamic>> uniqueVoices = {};
    for (final v in filteredVoices) {
      final key = voiceKey(v);
      if (key.isEmpty) continue;
      uniqueVoices.putIfAbsent(key, () => v);
    }
    String? effectiveSelectedKey;
    if (settings.voiceName != null) {
      for (final v in filteredVoices) {
        if ((v['name'] as String?) == settings.voiceName) {
          final k = voiceKey(v);
          if (uniqueVoices.containsKey(k)) {
            effectiveSelectedKey = k;
          }
          break;
        }
      }
    }
    final effectiveSelectedLocale =
        (settings.voiceLocale != null &&
            filteredLocales.contains(settings.voiceLocale))
        ? settings.voiceLocale
        : null;
    return TtsSettingsSection(
      voiceItems: uniqueVoices.values.toList(),
      uniqueVoices: uniqueVoices,
      voiceKey: voiceKey,
      loadingVoices: _loadingVoices,
      loadingLocales: _loadingLocales,
      effectiveSelectedKey: effectiveSelectedKey,
      filteredLocales: filteredLocales,
      effectiveSelectedLocale: effectiveSelectedLocale,
    );
  }
}
