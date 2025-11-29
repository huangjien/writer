import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/features/library/library_screen.dart';
import 'package:writer/state/mock_providers.dart';
import 'package:writer/state/motion_settings.dart';
import 'package:writer/state/providers.dart';
import 'package:writer/models/novel.dart';
import 'package:writer/l10n/app_localizations.dart';

void main() {
  testWidgets('Progress ring uses zero-duration animation when reduce motion', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    final novels = <Novel>[
      const Novel(
        id: 'n-1',
        title: 'Quiet City Nights',
        author: 'L. Dreamer',
        description: 'Slice-of-life stories set in a peaceful city.',
        coverUrl: null,
        languageCode: 'en',
        isPublic: true,
      ),
    ];

    // Prepare motion settings and set reduce motion to true
    final motion = MotionSettingsNotifier.lazy();
    motion.setReduceMotion(true);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          supabaseEnabledProvider.overrideWith((_) => false),
          mockNovelsProvider.overrideWith((ref) async => novels),
          motionSettingsProvider.overrideWith((ref) => motion),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const LibraryScreen(),
        ),
      ),
    );

    // Resolve async providers
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();

    // Find the 0% progress ring semantics and obtain its AnimatedSwitcher
    final ringSemantics = find.byKey(const ValueKey('ring-0'));
    expect(ringSemantics, findsOneWidget);

    final switcherFinder = find.ancestor(
      of: ringSemantics,
      matching: find.byType(AnimatedSwitcher),
    );
    expect(switcherFinder, findsOneWidget);

    final switcher = tester.widget<AnimatedSwitcher>(switcherFinder);
    expect(switcher.duration, equals(Duration.zero));
  });
}
