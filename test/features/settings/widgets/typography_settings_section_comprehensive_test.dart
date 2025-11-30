import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/features/settings/widgets/typography_settings_section.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/state/theme_controller.dart';
import 'package:writer/theme/reader_typography.dart';
import 'package:writer/theme/font_packs.dart';
import 'package:writer/theme/reader_background.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('TypographySettingsSection comprehensive tests', () {
    late SharedPreferences prefs;
    late ThemeController themeController;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      themeController = ThemeController(prefs);
    });

    Future<void> pumpTypographySection(WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            themeControllerProvider.overrideWith((_) => themeController),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: SingleChildScrollView(child: TypographySettingsSection()),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('Typography preset dropdown changes preset', (tester) async {
      await pumpTypographySection(tester);

      // Find and tap the typography preset dropdown
      final presetDropdown = find
          .byType(DropdownButton<ReaderTypographyPreset>)
          .first;
      await tester.tap(presetDropdown);
      await tester.pumpAndSettle();

      // Select 'Serif-like' preset
      await tester.tap(find.text('Serif-like'));
      await tester.pumpAndSettle();

      // Verify the change was applied
      expect(themeController.state.preset, ReaderTypographyPreset.serifLike);
    });

    testWidgets('Font pack dropdown changes font pack', (tester) async {
      await pumpTypographySection(tester);

      // Find and tap the font pack dropdown
      final fontPackDropdown = find
          .byType(DropdownButton<ReaderFontPack>)
          .first;
      await tester.tap(fontPackDropdown);
      await tester.pumpAndSettle();

      // Select 'Inter' font pack
      await tester.tap(find.text('Inter'));
      await tester.pumpAndSettle();

      // Verify the change was applied
      expect(themeController.state.fontPack, ReaderFontPack.inter);
    });

    testWidgets('Font scale slider changes font scale', (tester) async {
      await pumpTypographySection(tester);

      // Find the font scale slider
      final slider = find.byType(Slider);
      expect(slider, findsOneWidget);

      // Drag the slider to a new value
      await tester.drag(slider, const Offset(100, 0));
      await tester.pumpAndSettle();

      // Verify the font scale changed
      expect(themeController.state.fontScale, isNot(equals(1.0)));
    });

    testWidgets('Reader background depth dropdown changes depth', (
      tester,
    ) async {
      await pumpTypographySection(tester);

      // Find and tap the background depth dropdown
      final bgDepthDropdown = find
          .byType(DropdownButton<ReaderBackgroundDepth>)
          .first;
      await tester.tap(bgDepthDropdown);
      await tester.pumpAndSettle();

      // Select 'High' depth
      await tester.tap(find.text('High'));
      await tester.pumpAndSettle();

      // Verify the change was applied
      expect(themeController.state.readerBgDepth, ReaderBackgroundDepth.high);
    });

    testWidgets('Separate typography switch toggles separate typography', (
      tester,
    ) async {
      await pumpTypographySection(tester);

      // Find the separate typography switch
      final switchTile = find.byType(SwitchListTile);
      expect(switchTile, findsOneWidget);

      // Verify initial state
      expect(themeController.state.hasSeparateTypography, isFalse);

      // Tap the switch to enable separate typography
      await tester.tap(switchTile);
      await tester.pumpAndSettle();

      // Verify the change was applied
      expect(themeController.state.hasSeparateTypography, isTrue);
    });

    testWidgets('Separate light typography preset dropdown changes preset', (
      tester,
    ) async {
      // Enable separate typography first
      await themeController.setSeparateTypography(true);

      await pumpTypographySection(tester);

      // Wait for the UI to update with separate typography widgets
      await tester.pumpAndSettle();

      // Verify separate typography widgets are shown
      expect(find.text('Light Typography'), findsOneWidget);
      expect(find.text('Dark Typography'), findsOneWidget);

      // Find and tap the light typography preset dropdown - count all dropdowns
      final allDropdowns = find.byType(DropdownButton<ReaderTypographyPreset>);
      expect(allDropdowns, findsNWidgets(3)); // Main, Light, Dark

      await tester.tap(allDropdowns.at(1)); // Second dropdown is light
      await tester.pumpAndSettle();

      // Select 'Serif-like' preset for light theme
      await tester.tap(find.text('Serif-like').last);
      await tester.pumpAndSettle();

      // Verify the change was applied
      expect(
        themeController.state.presetLight,
        ReaderTypographyPreset.serifLike,
      );
    });

    testWidgets('Separate dark typography preset dropdown changes preset', (
      tester,
    ) async {
      // Enable separate typography first
      await themeController.setSeparateTypography(true);

      await pumpTypographySection(tester);

      // Wait for the UI to update with separate typography widgets
      await tester.pumpAndSettle();

      // Find and tap the dark typography preset dropdown
      final allDropdowns = find.byType(DropdownButton<ReaderTypographyPreset>);
      expect(allDropdowns, findsNWidgets(3)); // Main, Light, Dark

      await tester.tap(allDropdowns.at(2)); // Third dropdown is dark
      await tester.pumpAndSettle();

      // Select 'Compact' preset for dark theme
      await tester.tap(find.text('Compact').last);
      await tester.pumpAndSettle();

      // Verify the change was applied
      expect(themeController.state.presetDark, ReaderTypographyPreset.compact);
    });

    testWidgets('Custom font family popup menu shows font families', (
      tester,
    ) async {
      await pumpTypographySection(tester);

      // Find the custom font family popup button
      final popupButton = find.byType(PopupMenuButton<String>);
      expect(popupButton, findsOneWidget);

      // Tap the popup button
      await tester.tap(popupButton);
      await tester.pumpAndSettle();

      // Verify some font families are shown
      expect(find.text('Arial'), findsOneWidget);
      expect(find.text('Helvetica'), findsOneWidget);
      expect(find.text('Times New Roman'), findsOneWidget);
      expect(find.text('Roboto'), findsOneWidget);
    });
  });
}
