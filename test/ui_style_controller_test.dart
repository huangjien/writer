import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/state/ui_style_controller.dart';
import 'package:writer/theme/ui_styles.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('UiStyleController initializes with default style', (
    tester,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final controller = UiStyleController(prefs);

    expect(controller.state.family, UiStyleFamily.minimalism);
  });

  testWidgets('UiStyleController loads persisted style', (tester) async {
    SharedPreferences.setMockInitialValues({'ui_style_family': 'neumorphism'});

    final prefs = await SharedPreferences.getInstance();
    final controller = UiStyleController(prefs);

    expect(controller.state.family, UiStyleFamily.neumorphism);
  });

  testWidgets('UiStyleController setStyle updates state and persists', (
    tester,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final controller = UiStyleController(prefs);

    await controller.setStyle(UiStyleFamily.flatDesign);

    expect(controller.state.family, UiStyleFamily.flatDesign);
    expect(prefs.getString('ui_style_family'), 'flatDesign');
  });

  testWidgets('UiStyleController setStyle notifies listeners', (tester) async {
    final prefs = await SharedPreferences.getInstance();
    final controller = UiStyleController(prefs);

    final listenerCalled = <UiStyleFamily>[];
    controller.addListener((state) {
      listenerCalled.add(state.family);
    });

    await controller.setStyle(UiStyleFamily.minimalism);

    expect(listenerCalled, contains(UiStyleFamily.minimalism));
  });

  testWidgets('UiStyleController handles all style families', (tester) async {
    final prefs = await SharedPreferences.getInstance();
    final controller = UiStyleController(prefs);

    final styles = [
      UiStyleFamily.minimalism,
      UiStyleFamily.glassmorphism,
      UiStyleFamily.neumorphism,
      UiStyleFamily.flatDesign,
    ];

    for (final style in styles) {
      await controller.setStyle(style);
      expect(controller.state.family, style);
    }
  });

  testWidgets('UiStyleController uses minimalism as fallback', (tester) async {
    SharedPreferences.setMockInitialValues({
      'ui_style_family': 'invalid_style',
    });

    final prefs = await SharedPreferences.getInstance();
    final controller = UiStyleController(prefs);

    expect(controller.state.family, UiStyleFamily.minimalism);
  });
}
