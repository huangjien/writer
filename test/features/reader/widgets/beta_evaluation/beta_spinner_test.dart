import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/features/reader/widgets/reader_bottom_bar.dart';
import 'package:writer/l10n/app_localizations.dart';

void main() {
  testWidgets('Beta button shows spinner while loading', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: ReaderBottomBar(
            canEdit: true,
            editMode: false,
            speaking: false,
            iconSize: 24,
            spacing: 8,
            showPercent: false,
            showTtsControls: false,
            scrollProgress: 0.0,
            onEditToggle: () {},
            onPrev: () {},
            onNext: () {},
            onPlayStop: () {},
            onOpenTtsSettings: () {},
            reduceMotion: true,
            onBetaEvaluate: () {},
            showBeta: true,
            betaLoading: true,
          ),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('beta_spinner')), findsOneWidget);
    expect(find.byKey(const ValueKey('beta_button')), findsNothing);
  });
}
