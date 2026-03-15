import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/l10n/app_localizations_en.dart';
import 'package:writer/models/novel.dart';
import 'package:writer/models/scene_template_row.dart';
import 'package:writer/features/summary/screens/scenes/widgets/scenes_support_widgets.dart';

void main() {
  group('SceneTemplateInfoButton', () {
    testWidgets('shows info icon when template has summary', (tester) async {
      final now = DateTime.now();
      final template = SceneTemplateRow(
        id: '1',
        idx: 0,
        title: 'Template',
        sceneSummaries: 'Test summary',
        languageCode: 'en',
        createdAt: now,
        updatedAt: now,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SceneTemplateInfoButton(template: null)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.info_outline), findsNothing);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: SceneTemplateInfoButton(template: template)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets('shows empty box when template is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SceneTemplateInfoButton(template: null)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SizedBox), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsNothing);
    });

    testWidgets('shows empty box when summary is empty', (tester) async {
      final now = DateTime.now();
      final template = SceneTemplateRow(
        id: '1',
        idx: 0,
        title: 'Template',
        sceneSummaries: '',
        languageCode: 'en',
        createdAt: now,
        updatedAt: now,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: SceneTemplateInfoButton(template: template)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SizedBox), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsNothing);
    });
  });

  group('SceneConvertButton', () {
    testWidgets('shows convert button when not converting', (tester) async {
      final l10n = AppLocalizationsEn();
      var pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SceneConvertButton(
              l10n: l10n,
              isConverting: false,
              onPressed: () async {
                pressed = true;
              },
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
      expect(find.text(l10n.aiConvert), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);

      await tester.tap(find.text(l10n.aiConvert));
      await tester.pump();
      expect(pressed, true);
    });

    testWidgets('shows loading indicator when converting', (tester) async {
      final l10n = AppLocalizationsEn();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SceneConvertButton(
              l10n: l10n,
              isConverting: true,
              onPressed: () async {},
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text(l10n.aiConvert), findsNothing);
    });

    testWidgets('disables button when onPressed is null', (tester) async {
      final l10n = AppLocalizationsEn();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SceneConvertButton(
              l10n: l10n,
              isConverting: false,
              onPressed: null,
            ),
          ),
        ),
      );
      await tester.pump();

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, null);
    });
  });

  group('SceneSaveButton', () {
    testWidgets('shows enabled button when dirty and not saving', (
      tester,
    ) async {
      final l10n = AppLocalizationsEn();
      var saved = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SceneSaveButton(
              l10n: l10n,
              saving: false,
              isDirty: true,
              onSave: () {
                saved = true;
              },
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.save), findsOneWidget);
      expect(find.text(l10n.save), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);

      await tester.tap(find.text(l10n.save));
      await tester.pump();
      expect(saved, true);
    });

    testWidgets('shows disabled button when not dirty', (tester) async {
      final l10n = AppLocalizationsEn();
      var saved = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SceneSaveButton(
              l10n: l10n,
              saving: false,
              isDirty: false,
              onSave: () {
                saved = true;
              },
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsNothing);

      final buttonFinder = find.byWidgetPredicate(
        (widget) => widget is SceneSaveButton,
      );
      await tester.tap(buttonFinder);
      await tester.pump();
      expect(
        saved,
        false,
        reason: ' onSave should not be called when disabled',
      );
    });

    testWidgets('shows loading indicator when saving', (tester) async {
      final l10n = AppLocalizationsEn();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SceneSaveButton(
              l10n: l10n,
              saving: true,
              isDirty: true,
              onSave: () {},
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('SceneNovelHeader', () {
    testWidgets('shows novel title and author', (tester) async {
      const novel = Novel(
        id: '1',
        title: 'Test Novel',
        author: 'Test Author',
        languageCode: 'en',
        isPublic: true,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SceneNovelHeader(novel: novel)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Test Novel'), findsOneWidget);
      expect(find.text('Test Author'), findsOneWidget);
    });

    testWidgets('shows unknown novel when novel is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SceneNovelHeader(novel: null))),
      );
      await tester.pumpAndSettle();

      expect(find.text('Unknown Novel'), findsOneWidget);
    });

    testWidgets('hides author when author is empty', (tester) async {
      const novel = Novel(
        id: '1',
        title: 'Test Novel',
        author: '',
        languageCode: 'en',
        isPublic: true,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SceneNovelHeader(novel: novel)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Test Novel'), findsOneWidget);
      expect(find.byType(Text), findsOneWidget);
    });
  });

  group('SceneLoadingTile', () {
    testWidgets('shows loading indicator and label', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SceneLoadingTile(label: 'Loading...')),
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading...'), findsOneWidget);
    });
  });

  group('SceneErrorTile', () {
    testWidgets('shows error message and refresh button', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, _) {
                  return SceneErrorTile(
                    label: 'Error loading',
                    novelId: '1',
                    ref: ref,
                  );
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
      expect(find.text('Error loading'), findsOneWidget);
    });
  });
}
