import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/features/settings/widgets/style_settings_section.dart';
import 'package:writer/state/ui_style_controller.dart';
import 'package:writer/theme/ui_styles.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('StyleSettingsSection shows style dropdown and preview grid', (
    tester,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final controller = UiStyleController(prefs);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [uiStyleControllerProvider.overrideWith((_) => controller)],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(
            body: SingleChildScrollView(child: StyleSettingsSection()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Styles'), findsOneWidget);
    expect(find.byType(DropdownButton<UiStyleFamily>), findsOneWidget);
    expect(find.byType(StylePreviewGrid), findsOneWidget);
  });

  testWidgets('StyleSettingsSection allows style selection', (tester) async {
    final prefs = await SharedPreferences.getInstance();
    final controller = UiStyleController(prefs);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [uiStyleControllerProvider.overrideWith((_) => controller)],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(
            body: SingleChildScrollView(child: StyleSettingsSection()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final dropdownFinder = find.byType(DropdownButton<UiStyleFamily>);
    expect(dropdownFinder, findsOneWidget);

    await tester.tap(dropdownFinder);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Neumorphism').last);
    await tester.pumpAndSettle();

    expect(controller.state.family, UiStyleFamily.neumorphism);
  });

  testWidgets('StylePreviewGrid shows all style options', (tester) async {
    final prefs = await SharedPreferences.getInstance();
    final controller = UiStyleController(prefs);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [uiStyleControllerProvider.overrideWith((_) => controller)],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: StylePreviewGrid(
              selected: UiStyleFamily.glassmorphism,
              onSelected: (style) {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Glassmorphism'), findsOneWidget);
    expect(find.text('Neumorphism'), findsOneWidget);
    expect(find.text('Minimalism'), findsOneWidget);
    expect(find.text('Flat Design'), findsOneWidget);
  });

  testWidgets('StylePreviewCard calls onSelected when tapped', (tester) async {
    UiStyleFamily? selectedStyle;

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: StylePreviewGrid(
            selected: UiStyleFamily.glassmorphism,
            onSelected: (style) {
              selectedStyle = style;
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Neumorphism').last);
    expect(selectedStyle, UiStyleFamily.neumorphism);
  });

  testWidgets('StylePreviewCard shows visual selection state', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: StylePreviewGrid(
            selected: UiStyleFamily.glassmorphism,
            onSelected: (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final glassmorphismCard = find.ancestor(
      of: find.text('Glassmorphism'),
      matching: find.byType(GestureDetector),
    );

    expect(glassmorphismCard, findsOneWidget);
  });
}
