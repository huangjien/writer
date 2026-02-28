import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/shared/widgets/language_indicator.dart';

void main() {
  group('LanguageIndicator', () {
    testWidgets('shows Chinese language for Chinese text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: LanguageIndicator(text: '中文测试')),
        ),
      );

      expect(find.text('中文'), findsOneWidget);
    });

    testWidgets('shows English language for English text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: LanguageIndicator(text: 'Hello World')),
        ),
      );

      expect(find.text('English'), findsOneWidget);
    });

    testWidgets('shows English language for empty text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: LanguageIndicator(text: '')),
        ),
      );

      expect(find.text('English'), findsOneWidget);
    });
  });

  group('LiveLanguageIndicator', () {
    testWidgets('shows initial language', (tester) async {
      final notifier = ValueNotifier<String>('en');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LiveLanguageIndicator(languageNotifier: notifier),
          ),
        ),
      );

      expect(find.text('English'), findsOneWidget);

      notifier.dispose();
    });

    testWidgets('updates when notifier changes', (tester) async {
      final notifier = ValueNotifier<String>('en');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LiveLanguageIndicator(languageNotifier: notifier),
          ),
        ),
      );

      expect(find.text('English'), findsOneWidget);

      notifier.value = 'zh';
      await tester.pumpAndSettle();

      expect(find.text('中文'), findsOneWidget);

      notifier.dispose();
    });
  });
}
