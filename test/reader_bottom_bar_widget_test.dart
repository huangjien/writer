import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/features/reader/widgets/reader_bottom_bar.dart';
import 'package:writer/l10n/app_localizations.dart';

void main() {
  testWidgets('ReaderBottomBar shows progress percent', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: ReaderBottomBar(
            canEdit: false,
            editMode: false,
            speaking: false,
            iconSize: 20,
            spacing: 8,
            showPercent: true,
            showTtsControls: true,
            scrollProgress: 0.42,
            boldEnabled: false,
            onEditToggle: voidFn,
            onPrev: voidFn,
            onNext: voidFn,
            onToggleBold: voidFn,
            onPlayStop: voidFn,
            onOpenTtsSettings: voidFn,
            reduceMotion: true,
          ),
        ),
      ),
    );
    expect(find.text('42%'), findsOneWidget);
  });
}

void voidFn() {}
