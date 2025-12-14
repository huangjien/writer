import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/features/summary/scene_templates_screen.dart';
import 'package:writer/main.dart';
import 'package:writer/repositories/local_storage_repository.dart';
import 'package:writer/models/template.dart';
import 'package:writer/l10n/app_localizations.dart';

class CapturingLocalRepo extends LocalStorageRepository {
  TemplateItem? lastItem;
  @override
  Future<void> saveSceneTemplateForm(String novelId, TemplateItem item) async {
    lastItem = item;
  }
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('SceneTemplatesScreen validates and saves', (tester) async {
    final repo = CapturingLocalRepo();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [localStorageRepositoryProvider.overrideWith((_) => repo)],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: SceneTemplatesScreen(novelId: 'n-1'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Switch to Edit tab
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    final descFieldPre = find.widgetWithText(
      TextFormField,
      'Enter description in Markdown...',
    );
    await tester.enterText(descFieldPre, 'X');
    await tester.pump();
    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(find.text('Required'), findsOneWidget);

    // Fill fields and save.
    final nameField = find.widgetWithText(TextFormField, 'Template Name');
    final descField = find.widgetWithText(
      TextFormField,
      'Enter description in Markdown...',
    );
    await tester.enterText(nameField, 'Battle Scene');
    await tester.enterText(descField, 'High tension encounter');
    await tester.tap(find.text('Save'));
    await tester.pump();

    expect(repo.lastItem?.name, 'Battle Scene');
    expect(repo.lastItem?.description, 'High tension encounter');
    expect(find.text('Saved'), findsOneWidget);
  });
}
