import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/features/summary/character_templates_screen.dart';
import 'package:writer/main.dart';
import 'package:writer/repositories/local_storage_repository.dart';
import 'package:writer/models/template.dart';

class CapturingLocalRepo extends LocalStorageRepository {
  TemplateItem? lastItem;
  @override
  Future<void> saveCharacterTemplateForm(
    String novelId,
    TemplateItem item,
  ) async {
    lastItem = item;
  }
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('CharacterTemplatesScreen validates and saves', (tester) async {
    final repo = CapturingLocalRepo();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [localStorageRepositoryProvider.overrideWith((_) => repo)],
        child: const MaterialApp(
          home: CharacterTemplatesScreen(novelId: 'n-1'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Required validation for Template Name.
    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(find.text('Required'), findsOneWidget);

    // Fill fields and save.
    final nameField = find.widgetWithText(TextFormField, 'Template Name');
    final descField = find.widgetWithText(TextFormField, 'Description');
    await tester.enterText(nameField, 'Hero Archetype');
    await tester.enterText(descField, 'Brave protagonist setup');
    await tester.tap(find.text('Save'));
    await tester.pump();

    expect(repo.lastItem?.name, 'Hero Archetype');
    expect(repo.lastItem?.description, 'Brave protagonist setup');
    expect(find.text('Saved'), findsOneWidget);
  });
}
