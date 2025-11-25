import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/features/reader/widgets/reader_bottom_bar.dart';
import 'package:writer/l10n/app_localizations.dart';

void main() {
  testWidgets('ReaderBottomBar shows progress percent', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(
          body: ReaderBottomBar(
            canEdit: false,
            editMode: false,
            speaking: false,
            iconSize: 20,
            spacing: 8,
            showPercent: true,
            scrollProgress: 0.42,
            onEditToggle: voidFn,
            onPrev: voidFn,
            onNext: voidFn,
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
