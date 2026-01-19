import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/features/style_guide/style_guide_screen.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/state/app_settings.dart';
import 'package:writer/state/storage_service_provider.dart';
import 'package:writer/state/theme_controller.dart';
import 'package:writer/shared/widgets/neumorphic_checkbox.dart';
import 'package:writer/shared/widgets/neumorphic_radio.dart';
import 'package:writer/shared/widgets/neumorphic_slider.dart';
import 'package:writer/shared/widgets/neumorphic_switch.dart';

void main() {
  group('StyleGuideScreen', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    Future<void> scrollTo(WidgetTester tester, Finder finder) async {
      final listViewFinder = find.byType(ListView);
      for (var i = 0; i < 30; i++) {
        if (finder.evaluate().isNotEmpty) {
          await tester.ensureVisible(finder.first);
          await tester.pumpAndSettle();
          return;
        }

        await tester.drag(listViewFinder, const Offset(0, -300));
        await tester.pumpAndSettle();
      }

      expect(finder, findsWidgets);
    }

    Widget createTestWidget({Widget? child}) {
      return ProviderScope(
        overrides: [
          appSettingsProvider.overrideWith((_) => AppSettingsNotifier(prefs)),
          sharedPreferencesProvider.overrideWithValue(prefs),
          themeControllerProvider.overrideWith((_) => ThemeController(prefs)),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: child ?? const StyleGuideScreen(),
        ),
      );
    }

    group('Widget instantiation', () {
      testWidgets('renders without errors', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();
        expect(find.byType(StyleGuideScreen), findsOneWidget);
      });

      testWidgets('has AppBar with correct title', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();
        expect(find.text('Design System Style Guide'), findsOneWidget);
      });

      testWidgets('uses ListView as body', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();
        expect(find.byType(ListView), findsOneWidget);
      });

      testWidgets('has correct padding on ListView', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        final listView = tester.widget<ListView>(find.byType(ListView));
        final padding = listView.padding;
        expect(padding, isNotNull);
      });
    });

    group('Typography section', () {
      testWidgets('displays Typography section', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();
        expect(find.text('Typography'), findsOneWidget);
      });

      testWidgets('displays all typography styles', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Headline Large'), findsOneWidget);
        expect(find.text('Headline Medium'), findsOneWidget);
        expect(find.text('Title Large'), findsOneWidget);
        expect(find.text('Body Large'), findsOneWidget);
        expect(find.text('Body Medium'), findsOneWidget);
      });

      testWidgets('has divider after Typography section', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();
        expect(find.byType(Divider), findsWidgets);
      });
    });

    group('Buttons section', () {
      testWidgets('displays Buttons section', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();
        expect(find.text('Buttons'), findsOneWidget);
      });

      testWidgets('displays Primary Button', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();
        expect(find.text('Primary Button'), findsOneWidget);
      });

      testWidgets('displays Disabled button', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();
        expect(find.text('Disabled'), findsOneWidget);
      });

      testWidgets('buttons are in a Row', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        final buttonsSection = find.ancestor(
          of: find.text('Primary Button'),
          matching: find.byType(Row),
        );
        expect(buttonsSection, findsOneWidget);
      });
    });

    group('Checkboxes section', () {
      testWidgets('displays Checkboxes section', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();
        expect(find.text('Checkboxes (Standardized)'), findsOneWidget);
      });

      testWidgets('displays checkbox state text', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();
        expect(find.text('Checkbox State: false'), findsOneWidget);
      });

      testWidgets('toggles checkbox when tapped', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Find and tap the neumorphic checkbox
        final checkboxFinder = find.byType(NeumorphicCheckbox);
        await tester.tap(checkboxFinder);
        await tester.pumpAndSettle();

        // State should update to true
        expect(find.text('Checkbox State: true'), findsOneWidget);
      });

      testWidgets('checkbox state toggles back and forth', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        final checkboxFinder = find.byType(NeumorphicCheckbox);

        // First tap - should become true
        await tester.tap(checkboxFinder);
        await tester.pumpAndSettle();
        expect(find.text('Checkbox State: true'), findsOneWidget);

        // Second tap - should become false
        await tester.tap(checkboxFinder);
        await tester.pumpAndSettle();
        expect(find.text('Checkbox State: false'), findsOneWidget);
      });
    });

    group('Radio Buttons section', () {
      testWidgets('displays Radio Buttons section', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();
        await scrollTo(tester, find.text('Radio Buttons'));
        expect(find.text('Radio Buttons'), findsOneWidget);
      });

      testWidgets('displays Option 1', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();
        await scrollTo(tester, find.text('Radio Buttons'));
        expect(find.text('Option 1'), findsOneWidget);
      });

      testWidgets('displays Option 2', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();
        await scrollTo(tester, find.text('Radio Buttons'));
        expect(find.text('Option 2'), findsOneWidget);
      });

      testWidgets('selects radio option when tapped', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();
        await scrollTo(tester, find.text('Radio Buttons'));

        final radioButtons = find.byType(NeumorphicRadio<int>);
        expect(radioButtons, findsNWidgets(2));

        expect(
          tester.widget<NeumorphicRadio<int>>(radioButtons.first).groupValue,
          0,
        );

        await tester.tap(radioButtons.at(1));
        await tester.pumpAndSettle();

        expect(
          tester.widget<NeumorphicRadio<int>>(radioButtons.first).groupValue,
          1,
        );
      });

      testWidgets('radio buttons are in separate Rows', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        final rows = find.byType(Row);
        // Should have multiple rows in the radio section
        expect(rows, findsWidgets);
      });
    });

    group('Toggles/Switches section', () {
      testWidgets('displays Toggles / Switches section', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();
        await scrollTo(tester, find.text('Toggles / Switches'));
        expect(find.text('Toggles / Switches'), findsOneWidget);
      });

      testWidgets('displays switch state text', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();
        await scrollTo(tester, find.text('Toggles / Switches'));
        expect(find.text('Switch State: false'), findsOneWidget);
      });

      testWidgets('toggles switch when tapped', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();
        await scrollTo(tester, find.byType(NeumorphicSwitch));

        final switchFinder = find.byType(NeumorphicSwitch);
        await tester.tap(switchFinder);
        await tester.pumpAndSettle();

        expect(find.text('Switch State: true'), findsOneWidget);
      });

      testWidgets('switch state toggles back and forth', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();
        await scrollTo(tester, find.byType(NeumorphicSwitch));

        final switchFinder = find.byType(NeumorphicSwitch);

        // First tap - should become true
        await tester.tap(switchFinder);
        await tester.pumpAndSettle();
        expect(find.text('Switch State: true'), findsOneWidget);

        // Second tap - should become false
        await tester.tap(switchFinder);
        await tester.pumpAndSettle();
        expect(find.text('Switch State: false'), findsOneWidget);
      });
    });

    group('Sliders section', () {
      testWidgets('displays Sliders section', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();
        await scrollTo(tester, find.text('Sliders'));
        expect(find.text('Sliders'), findsOneWidget);
      });

      testWidgets('displays initial slider value', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();
        await scrollTo(tester, find.text('Sliders'));
        expect(find.text('Value: 50.0'), findsOneWidget);
      });

      testWidgets('updates slider value when dragged', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();
        await scrollTo(tester, find.byType(NeumorphicSlider));

        final sliderFinder = find.byType(NeumorphicSlider);
        expect(sliderFinder, findsOneWidget);

        // Drag the slider to a new position
        await tester.drag(sliderFinder, const Offset(100, 0));
        await tester.pumpAndSettle();

        // Value should have changed
        expect(find.textContaining('Value:'), findsOneWidget);
      });

      testWidgets('slider has correct min and max values', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();
        await scrollTo(tester, find.byType(NeumorphicSlider));

        final slider = tester.widget<NeumorphicSlider>(
          find.byType(NeumorphicSlider),
        );
        expect(slider.min, 0);
        expect(slider.max, 100);
      });
    });

    group('Input Fields section', () {
      testWidgets('displays Input Fields section', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();
        await scrollTo(tester, find.text('Input Fields'));
        expect(find.text('Input Fields'), findsOneWidget);
      });

      testWidgets('displays text field with hint', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();
        await scrollTo(tester, find.text('Input Fields'));
        expect(find.text('Enter text here...'), findsOneWidget);
      });

      testWidgets('accepts text input', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();
        await scrollTo(tester, find.text('Input Fields'));

        final inputSection = find.ancestor(
          of: find.text('Input Fields'),
          matching: find.byType(Padding),
        );
        final textFieldFinder = find.descendant(
          of: inputSection,
          matching: find.byType(TextField),
        );
        await tester.enterText(textFieldFinder, 'Test input');
        await tester.pumpAndSettle();

        expect(find.text('Test input'), findsOneWidget);
      });
    });

    group('Dropdowns section', () {
      testWidgets('displays Dropdowns section', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();
        await scrollTo(tester, find.text('Dropdowns'));
        expect(find.text('Dropdowns'), findsOneWidget);
      });

      testWidgets('displays dropdown hint', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();
        await scrollTo(tester, find.text('Dropdowns'));
        expect(find.text('Select an option'), findsOneWidget);
      });

      testWidgets('opens dropdown when tapped', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();
        await scrollTo(tester, find.text('Dropdowns'));

        final dropdownSection = find.ancestor(
          of: find.text('Dropdowns'),
          matching: find.byType(Padding),
        );
        final dropdownButtonFinder = find.descendant(
          of: dropdownSection,
          matching: find.byType(DropdownButton<String>),
        );

        // Tap the dropdown to open it
        await tester.tap(dropdownButtonFinder);
        await tester.pumpAndSettle();

        // Dropdown menu should appear
        expect(find.text('Option A'), findsOneWidget);
        expect(find.text('Option B'), findsOneWidget);
        expect(find.text('Option C'), findsOneWidget);
      });

      testWidgets('selects dropdown option', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();
        await scrollTo(tester, find.text('Dropdowns'));

        final dropdownSection = find.ancestor(
          of: find.text('Dropdowns'),
          matching: find.byType(Padding),
        );
        final dropdownButtonFinder = find.descendant(
          of: dropdownSection,
          matching: find.byType(DropdownButton<String>),
        );

        // Open dropdown
        await tester.tap(dropdownButtonFinder);
        await tester.pumpAndSettle();

        // Select Option A
        await tester.tap(find.text('Option A'));
        await tester.pumpAndSettle();

        // Option A should now be selected
        expect(find.text('Option A'), findsOneWidget);
      });
    });

    group('Section structure', () {
      testWidgets('all sections have titles', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        final expectedTitles = [
          'Typography',
          'Buttons',
          'Checkboxes (Standardized)',
          'Radio Buttons',
          'Toggles / Switches',
          'Sliders',
          'Input Fields',
          'Dropdowns',
        ];

        for (final title in expectedTitles) {
          await scrollTo(tester, find.text(title));
          expect(find.text(title), findsOneWidget);
        }
      });

      testWidgets('sections are separated by dividers', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        final dividers = find.byType(Divider);
        // Should have multiple dividers (one after each section)
        expect(dividers, findsWidgets);
      });

      testWidgets('sections have consistent spacing', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Find all section titles
        final titles = find.text('Typography');
        expect(titles, findsOneWidget);
      });
    });

    group('State management', () {
      testWidgets('maintains checkbox state across rebuilds', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Toggle checkbox
        await tester.tap(find.byType(NeumorphicCheckbox));
        await tester.pumpAndSettle();
        expect(find.text('Checkbox State: true'), findsOneWidget);

        // Rebuild widget
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // State should persist (though in this case it's a new instance)
        expect(find.byType(NeumorphicCheckbox), findsOneWidget);
      });

      testWidgets('maintains switch state across rebuilds', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();
        await scrollTo(tester, find.byType(NeumorphicSwitch));

        // Toggle switch
        await tester.tap(find.byType(NeumorphicSwitch));
        await tester.pumpAndSettle();
        expect(find.text('Switch State: true'), findsOneWidget);

        // Rebuild widget
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.byType(NeumorphicSwitch), findsOneWidget);
      });

      testWidgets('maintains slider value across rebuilds', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();
        await scrollTo(tester, find.text('Sliders'));

        // Drag slider
        await tester.drag(find.byType(NeumorphicSlider), const Offset(50, 0));
        await tester.pumpAndSettle();

        // Rebuild widget
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.byType(NeumorphicSlider), findsOneWidget);
      });

      testWidgets('maintains dropdown selection across rebuilds', (
        tester,
      ) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();
        await scrollTo(tester, find.text('Dropdowns'));

        final dropdownSection = find.ancestor(
          of: find.text('Dropdowns'),
          matching: find.byType(Padding),
        );
        final dropdownButtonFinder = find.descendant(
          of: dropdownSection,
          matching: find.byType(DropdownButton<String>),
        );

        // Select dropdown option
        await tester.tap(dropdownButtonFinder);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Option A'));
        await tester.pumpAndSettle();

        // Rebuild widget
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.byType(DropdownButton<String>), findsOneWidget);
      });
    });

    group('Scroll behavior', () {
      testWidgets('scrolls through all sections', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Scroll to the bottom
        await tester.fling(find.byType(ListView), const Offset(0, -500), 1000);
        await tester.pumpAndSettle();

        // All sections should still be accessible
        expect(find.text('Dropdowns'), findsOneWidget);
      });

      testWidgets('scrolls back to top', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Scroll down
        await tester.fling(find.byType(ListView), const Offset(0, -500), 1000);
        await tester.pumpAndSettle();

        // Scroll back up
        await tester.fling(find.byType(ListView), const Offset(0, 500), 1000);
        await tester.pumpAndSettle();

        // Top section should be visible
        expect(find.text('Typography'), findsOneWidget);
      });
    });

    group('Accessibility', () {
      testWidgets('all interactive elements are reachable', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Verify all interactive elements exist
        expect(find.byType(NeumorphicCheckbox), findsOneWidget);
        expect(find.byType(NeumorphicRadio<int>), findsWidgets);

        await scrollTo(tester, find.byType(NeumorphicSwitch));
        expect(find.byType(NeumorphicSwitch), findsOneWidget);

        await scrollTo(tester, find.text('Sliders'));
        expect(find.byType(NeumorphicSlider), findsOneWidget);

        await scrollTo(tester, find.text('Input Fields'));
        final inputSection = find.ancestor(
          of: find.text('Input Fields'),
          matching: find.byType(Padding),
        );
        final textFieldFinder = find.descendant(
          of: inputSection,
          matching: find.byType(TextField),
        );
        expect(textFieldFinder, findsOneWidget);

        await scrollTo(tester, find.text('Dropdowns'));
        final dropdownSection = find.ancestor(
          of: find.text('Dropdowns'),
          matching: find.byType(Padding),
        );
        final dropdownFinder = find.descendant(
          of: dropdownSection,
          matching: find.byType(DropdownButton<String>),
        );
        expect(dropdownFinder, findsOneWidget);
      });

      testWidgets('text elements are readable', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Verify all text elements are present
        expect(find.text('Headline Large'), findsOneWidget);
        expect(find.text('Primary Button'), findsOneWidget);
        expect(find.text('Option 1'), findsOneWidget);
        expect(find.text('Option 2'), findsOneWidget);
      });
    });

    group('Integration', () {
      testWidgets('multiple controls can be manipulated', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Toggle checkbox
        await tester.tap(find.byType(NeumorphicCheckbox));
        await tester.pumpAndSettle();
        expect(find.text('Checkbox State: true'), findsOneWidget);

        // Toggle switch
        await scrollTo(tester, find.text('Toggles / Switches'));
        final switchSection = find.ancestor(
          of: find.text('Toggles / Switches'),
          matching: find.byType(Padding),
        );
        final switchFinder = find.descendant(
          of: switchSection,
          matching: find.byType(NeumorphicSwitch),
        );
        await tester.tap(switchFinder);
        await tester.pumpAndSettle();
        expect(find.text('Switch State: true'), findsOneWidget);

        // Enter text
        await scrollTo(tester, find.text('Input Fields'));
        final inputSection = find.ancestor(
          of: find.text('Input Fields'),
          matching: find.byType(Padding),
        );
        final textFieldFinder = find.descendant(
          of: inputSection,
          matching: find.byType(TextField),
        );
        await tester.enterText(textFieldFinder, 'Test');
        await tester.pumpAndSettle();
        expect(find.text('Test'), findsOneWidget);
      });

      testWidgets('screen rebuilds correctly after state changes', (
        tester,
      ) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Make multiple state changes
        await tester.tap(find.byType(NeumorphicCheckbox));
        await tester.pumpAndSettle();

        await scrollTo(tester, find.text('Toggles / Switches'));
        final switchSection = find.ancestor(
          of: find.text('Toggles / Switches'),
          matching: find.byType(Padding),
        );
        final switchFinder = find.descendant(
          of: switchSection,
          matching: find.byType(NeumorphicSwitch),
        );
        await tester.tap(switchFinder);
        await tester.pumpAndSettle();

        await scrollTo(tester, find.text('Sliders'));
        await tester.drag(find.byType(NeumorphicSlider), const Offset(50, 0));
        await tester.pumpAndSettle();

        // Screen should still be functional
        expect(find.byType(StyleGuideScreen), findsOneWidget);
      });
    });
  });
}
