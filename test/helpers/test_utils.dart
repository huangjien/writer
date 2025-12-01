import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/state/app_settings.dart';
import 'package:writer/state/theme_controller.dart';
import 'package:writer/state/tts_settings.dart';
import 'package:writer/theme/themes.dart';

/// Builds a ProviderScope with common overrides for app/theme.
Future<ProviderScope> buildAppScope({
  SharedPreferences? prefs,
  AppSettingsNotifier? appSettings,
  ThemeController? themeController,
  TtsSettingsNotifier? ttsSettings,
  List? extraOverrides,
  required Widget child,
}) async {
  final p = prefs ?? await SharedPreferences.getInstance();
  final app = appSettings ?? AppSettingsNotifier(p);
  final theme = themeController ?? ThemeController(p);
  final tts = ttsSettings ?? TtsSettingsNotifier(p);
  return ProviderScope(
    overrides: [
      appSettingsProvider.overrideWith((_) => app),
      themeControllerProvider.overrideWith((_) => theme),
      ttsSettingsProvider.overrideWith((_) => tts),
      ...?extraOverrides,
    ],
    child: child,
  );
}

/// MaterialApp configured with localization and optional theme from controller.
Widget materialAppFor({
  required Widget home,
  Locale locale = const Locale('en'),
  ThemeController? themeController,
}) {
  final state = themeController?.state;
  final ThemeData? light = state != null ? themeForLight(state.family) : null;
  final ThemeData? dark = state != null ? themeForDark(state.familyDark) : null;
  final ThemeMode mode = state?.mode ?? ThemeMode.light;

  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: light,
    darkTheme: dark,
    themeMode: mode,
    home: home,
  );
}

/// Calculates WCAG contrast ratio between two colors.
double contrastRatio(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final l1 = la > lb ? la : lb;
  final l2 = la > lb ? lb : la;
  return (l1 + 0.05) / (l2 + 0.05);
}

class TolerantGoldenComparator extends LocalFileComparator {
  TolerantGoldenComparator(super.testFile, {this.pixelDiffTolerance = 0.01})
    : _base = testFile;
  final double pixelDiffTolerance;
  final Uri _base;

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    bool ok = false;
    try {
      ok = await super.compare(imageBytes, golden);
    } catch (_) {
      ok = false;
    }
    if (ok) return true;

    final actualImage = await _decode(imageBytes);
    final expectedBytes = await File(_resolveGoldenPath(golden)).readAsBytes();
    final expectedImage = await _decode(expectedBytes);

    if (actualImage.width != expectedImage.width ||
        actualImage.height != expectedImage.height) {
      return false;
    }

    final actualData = await actualImage.toByteData(
      format: ui.ImageByteFormat.rawRgba,
    );
    final expectedData = await expectedImage.toByteData(
      format: ui.ImageByteFormat.rawRgba,
    );
    if (actualData == null || expectedData == null) return false;

    final a = actualData.buffer.asUint8List();
    final b = expectedData.buffer.asUint8List();
    final len = a.length;
    if (len != b.length) return false;

    int diffPixels = 0;
    for (int i = 0; i < len; i += 4) {
      if (a[i] != b[i] ||
          a[i + 1] != b[i + 1] ||
          a[i + 2] != b[i + 2] ||
          a[i + 3] != b[i + 3]) {
        diffPixels++;
      }
    }
    final totalPixels = len ~/ 4;
    final diffRatio = diffPixels / totalPixels;
    return diffRatio <= pixelDiffTolerance;
  }

  Future<ui.Image> _decode(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  String _resolveGoldenPath(Uri golden) {
    final resolved = _base.resolveUri(golden).toFilePath();
    if (File(resolved).existsSync()) return resolved;
    final cwd = Directory.current.path;
    final candidateTest = '$cwd/test/${golden.path}';
    if (File(candidateTest).existsSync()) return candidateTest;
    final candidateRoot = '$cwd/${golden.path}';
    return candidateRoot;
  }
}
