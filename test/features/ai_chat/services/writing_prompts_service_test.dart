import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/features/ai_chat/models/writing_prompt.dart';
import 'package:writer/features/ai_chat/services/writing_prompts_service.dart';

void main() {
  late SharedPreferences prefs;
  late WritingPromptsService service;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    service = WritingPromptsService(prefs);
  });

  group('WritingPromptsService Tests', () {
    group('defaultPrompts', () {
      test('contains expected number of default prompts', () {
        expect(WritingPromptsService.defaultPrompts.length, greaterThan(30));
      });

      test('all default prompts have unique IDs', () {
        final ids = WritingPromptsService.defaultPrompts
            .map((p) => p.id)
            .toSet();
        expect(ids.length, WritingPromptsService.defaultPrompts.length);
      });

      test('all default prompts are not custom', () {
        final customPrompts = WritingPromptsService.defaultPrompts
            .where((p) => p.isCustom)
            .toList();
        expect(customPrompts, isEmpty);
      });

      test('default prompts cover all categories', () {
        final categories = WritingPromptsService.defaultPrompts
            .map((p) => p.category)
            .toSet();
        expect(categories.length, greaterThan(5));
      });
    });

    group('getAllPrompts', () {
      test('returns default prompts when no custom prompts exist', () async {
        await prefs.remove('writing_prompts_custom');
        final prompts = service.getAllPrompts();

        expect(prompts.length, WritingPromptsService.defaultPrompts.length);
        expect(
          prompts.contains(WritingPromptsService.defaultPrompts.first),
          true,
        );
      });

      test(
        'returns default prompts when custom storage is empty JSON',
        () async {
          await prefs.setString('writing_prompts_custom', '[]');
          final prompts = service.getAllPrompts();

          expect(prompts.length, WritingPromptsService.defaultPrompts.length);
        },
      );

      test('includes custom prompts when they exist', () async {
        const customJson = '''[
          {"id":"custom1","text":"Custom prompt","category":"custom","isCustom":true}
        ]''';
        await prefs.setString('writing_prompts_custom', customJson);
        final prompts = service.getAllPrompts();

        expect(
          prompts.length,
          greaterThan(WritingPromptsService.defaultPrompts.length),
        );
        expect(prompts.any((p) => p.id == 'custom1'), true);
      });

      test('handles corrupted JSON gracefully', () async {
        await prefs.setString('writing_prompts_custom', 'invalid json');
        final prompts = service.getAllPrompts();

        expect(prompts.length, WritingPromptsService.defaultPrompts.length);
      });
    });

    group('getPromptsByCategory', () {
      test('returns only scene starter prompts', () async {
        await prefs.remove('writing_prompts_custom');
        final sceneStarters = service.getPromptsByCategory(
          WritingPromptCategory.sceneStarters,
        );

        for (final prompt in sceneStarters) {
          expect(prompt.category, WritingPromptCategory.sceneStarters);
        }
        expect(sceneStarters.length, greaterThan(5));
      });

      test('returns only character development prompts', () async {
        await prefs.remove('writing_prompts_custom');
        final charPrompts = service.getPromptsByCategory(
          WritingPromptCategory.characterDevelopment,
        );

        for (final prompt in charPrompts) {
          expect(prompt.category, WritingPromptCategory.characterDevelopment);
        }
        expect(charPrompts.length, greaterThan(3));
      });

      test('returns only dialogue prompts', () async {
        await prefs.remove('writing_prompts_custom');
        final dialoguePrompts = service.getPromptsByCategory(
          WritingPromptCategory.dialogue,
        );

        for (final prompt in dialoguePrompts) {
          expect(prompt.category, WritingPromptCategory.dialogue);
        }
        expect(dialoguePrompts.length, greaterThan(2));
      });

      test('returns only world building prompts', () async {
        await prefs.remove('writing_prompts_custom');
        final worldPrompts = service.getPromptsByCategory(
          WritingPromptCategory.worldBuilding,
        );

        for (final prompt in worldPrompts) {
          expect(prompt.category, WritingPromptCategory.worldBuilding);
        }
      });

      test('returns empty list for category with no prompts', () async {
        await prefs.remove('writing_prompts_custom');
        final results = service.getPromptsByCategory(
          WritingPromptCategory.custom,
        );

        expect(results, isEmpty);
      });

      test('includes custom prompts in category results', () async {
        const customJson = '''[
          {"id":"custom1","text":"Custom prompt","category":"sceneStarters","isCustom":true}
        ]''';
        await prefs.setString('writing_prompts_custom', customJson);
        final sceneStarters = service.getPromptsByCategory(
          WritingPromptCategory.sceneStarters,
        );

        expect(sceneStarters.any((p) => p.id == 'custom1'), true);
      });
    });

    group('searchPrompts', () {
      test('finds prompts by text content', () async {
        await prefs.remove('writing_prompts_custom');
        final results = service.searchPrompts('character');

        expect(results, isNotEmpty);
        for (final prompt in results) {
          expect(prompt.text.toLowerCase().contains('character'), true);
        }
      });

      test('finds prompts by aiContext', () async {
        await prefs.remove('writing_prompts_custom');
        final results = service.searchPrompts('help me');

        expect(results, isNotEmpty);
      });

      test('is case-insensitive', () async {
        await prefs.remove('writing_prompts_custom');
        final results1 = service.searchPrompts('scene');
        final results2 = service.searchPrompts('SCENE');
        final results3 = service.searchPrompts('ScEnE');

        expect(results1.length, results2.length);
        expect(results2.length, results3.length);
      });

      test('returns empty list for non-existent query', () async {
        await prefs.remove('writing_prompts_custom');
        final results = service.searchPrompts('xyz123nonexistent');

        expect(results, isEmpty);
      });

      test('returns all prompts for empty query', () async {
        await prefs.remove('writing_prompts_custom');
        final results = service.searchPrompts('');

        expect(results, isNotEmpty);
        expect(results.length, WritingPromptsService.defaultPrompts.length);
      });

      test('searches both text and aiContext', () async {
        await prefs.remove('writing_prompts_custom');
        final results = service.searchPrompts('template');

        expect(results, isNotEmpty);
      });

      test('handles special characters in query', () async {
        await prefs.remove('writing_prompts_custom');
        final results = service.searchPrompts("didn't");

        expect(results, isNotEmpty);
      });
    });

    group('getPromptById', () {
      test('finds existing default prompt by ID', () async {
        await prefs.remove('writing_prompts_custom');
        final prompt = service.getPromptById('scene_1');

        expect(prompt, isNotNull);
        expect(prompt!.id, 'scene_1');
        expect(prompt.category, WritingPromptCategory.sceneStarters);
      });

      test('finds custom prompt by ID', () async {
        const customJson = '''[
          {"id":"custom_search_1","text":"Custom","category":"custom","isCustom":true}
        ]''';
        await prefs.setString('writing_prompts_custom', customJson);
        final prompt = service.getPromptById('custom_search_1');

        expect(prompt, isNotNull);
        expect(prompt!.id, 'custom_search_1');
      });

      test('returns null for non-existent ID', () async {
        await prefs.remove('writing_prompts_custom');
        final prompt = service.getPromptById('nonexistent_id');

        expect(prompt, isNull);
      });

      test('handles empty string ID', () async {
        await prefs.remove('writing_prompts_custom');
        final prompt = service.getPromptById('');

        expect(prompt, isNull);
      });
    });

    group('addCustomPrompt', () {
      test('adds custom prompt with generated ID', () async {
        await prefs.remove('writing_prompts_custom');
        const newPrompt = WritingPrompt(
          id: 'will_be_replaced',
          text: 'New custom prompt',
          category: WritingPromptCategory.custom,
        );

        await service.addCustomPrompt(newPrompt);

        final storedJson = prefs.getString('writing_prompts_custom');
        expect(storedJson, isNotNull);
        expect(storedJson!.contains('custom_'), true);
        expect(storedJson.contains('New custom prompt'), true);
      });

      test('sets isCustom to true', () async {
        await prefs.remove('writing_prompts_custom');
        const newPrompt = WritingPrompt(
          id: 'test',
          text: 'Test',
          category: WritingPromptCategory.custom,
          isCustom: false,
        );

        await service.addCustomPrompt(newPrompt);

        final storedJson = prefs.getString('writing_prompts_custom');
        expect(storedJson!.contains('"isCustom":true'), true);
      });

      test('appends to existing custom prompts', () async {
        const existingJson = '''[
          {"id":"existing1","text":"Existing","category":"custom","isCustom":true}
        ]''';
        await prefs.setString('writing_prompts_custom', existingJson);
        const newPrompt = WritingPrompt(
          id: 'new',
          text: 'New prompt',
          category: WritingPromptCategory.custom,
        );

        await service.addCustomPrompt(newPrompt);

        final storedJson = prefs.getString('writing_prompts_custom');
        expect(storedJson!.contains('existing1'), true);
        expect(storedJson.contains('New prompt'), true);
      });
    });

    group('updateCustomPrompt', () {
      test('updates existing custom prompt', () async {
        const customJson = '''[
          {"id":"update_1","text":"Original","category":"custom","isCustom":true}
        ]''';
        await prefs.setString('writing_prompts_custom', customJson);
        const updatedPrompt = WritingPrompt(
          id: 'update_1',
          text: 'Updated text',
          category: WritingPromptCategory.custom,
          isCustom: true,
        );

        await service.updateCustomPrompt(updatedPrompt);

        final storedJson = prefs.getString('writing_prompts_custom');
        expect(storedJson!.contains('Updated text'), true);
        expect(storedJson.contains('Original'), false);
      });

      test('does not update default prompts', () async {
        await prefs.setString('writing_prompts_custom', '[]');
        const defaultPrompt = WritingPrompt(
          id: 'scene_1',
          text: 'Default prompt',
          category: WritingPromptCategory.sceneStarters,
          isCustom: false,
        );

        await service.updateCustomPrompt(defaultPrompt);

        final storedJson = prefs.getString('writing_prompts_custom');
        expect(storedJson, '[]');
      });

      test('handles non-existent custom prompt gracefully', () async {
        await prefs.setString('writing_prompts_custom', '[]');
        const nonExistent = WritingPrompt(
          id: 'does_not_exist',
          text: 'Test',
          category: WritingPromptCategory.custom,
          isCustom: true,
        );

        await service.updateCustomPrompt(nonExistent);

        final storedJson = prefs.getString('writing_prompts_custom');
        expect(storedJson, '[]');
      });
    });

    group('deleteCustomPrompt', () {
      test('deletes existing custom prompt', () async {
        const customJson = '''[
          {"id":"delete_1","text":"To delete","category":"custom","isCustom":true},
          {"id":"keep_1","text":"Keep this","category":"custom","isCustom":true}
        ]''';
        await prefs.setString('writing_prompts_custom', customJson);

        await service.deleteCustomPrompt('delete_1');

        final storedJson = prefs.getString('writing_prompts_custom');
        expect(storedJson!.contains('delete_1'), false);
        expect(storedJson.contains('keep_1'), true);
      });

      test('handles deleting non-existent prompt gracefully', () async {
        const customJson = '''[
          {"id":"keep_1","text":"Keep","category":"custom","isCustom":true}
        ]''';
        await prefs.setString('writing_prompts_custom', customJson);

        await service.deleteCustomPrompt('does_not_exist');

        final storedJson = prefs.getString('writing_prompts_custom');
        expect(storedJson!.contains('keep_1'), true);
      });

      test('saves empty array when deleting last prompt', () async {
        const customJson = '''[
          {"id":"only_1","text":"Only one","category":"custom","isCustom":true}
        ]''';
        await prefs.setString('writing_prompts_custom', customJson);

        await service.deleteCustomPrompt('only_1');

        final storedJson = prefs.getString('writing_prompts_custom');
        expect(storedJson, '[]');
      });
    });

    group('getCustomPrompts', () {
      test('returns empty list when no custom prompts', () async {
        await prefs.remove('writing_prompts_custom');
        final custom = service.getCustomPrompts();

        expect(custom, isEmpty);
      });

      test('returns only custom prompts', () async {
        const customJson = '''[
          {"id":"custom_1","text":"Custom 1","category":"custom","isCustom":true},
          {"id":"custom_2","text":"Custom 2","category":"sceneStarters","isCustom":true}
        ]''';
        await prefs.setString('writing_prompts_custom', customJson);
        final custom = service.getCustomPrompts();

        expect(custom.length, 2);
        expect(custom.every((p) => p.isCustom), true);
      });

      test('handles corrupted JSON', () async {
        await prefs.setString('writing_prompts_custom', 'invalid');
        final custom = service.getCustomPrompts();

        expect(custom, isEmpty);
      });
    });

    group('getRandomPrompt', () {
      test('returns prompt from all categories when none specified', () async {
        await prefs.remove('writing_prompts_custom');
        final prompt = service.getRandomPrompt();

        expect(prompt, isNotNull);
        expect(prompt.id, isNotEmpty);
      });

      test('returns prompt from specific category', () async {
        await prefs.remove('writing_prompts_custom');
        final prompt = service.getRandomPrompt(
          category: WritingPromptCategory.dialogue,
        );

        expect(prompt.category, WritingPromptCategory.dialogue);
      });

      test('returns fallback prompt when category is empty', () async {
        await prefs.remove('writing_prompts_custom');
        final prompt = service.getRandomPrompt(
          category: WritingPromptCategory.custom,
        );

        expect(prompt.id, 'fallback');
        expect(prompt.category, WritingPromptCategory.custom);
      });

      test('random prompts can be different', () async {
        await prefs.remove('writing_prompts_custom');
        final prompts = List.generate(10, (_) => service.getRandomPrompt().id);
        final uniquePrompts = prompts.toSet();

        expect(uniquePrompts.length, greaterThan(1));
      });
    });

    group('Provider Tests', () {
      test('sharedPreferencesProvider throws error when not overridden', () {
        final container = ProviderContainer();

        expect(
          () => container.read(sharedPreferencesProvider),
          throwsException,
        );

        container.dispose();
      });

      test(
        'writingPromptsServiceProvider depends on sharedPreferencesProvider',
        () {
          final container = ProviderContainer(
            overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          );

          final service = container.read(writingPromptsServiceProvider);

          expect(service, isNotNull);
          expect(service, isA<WritingPromptsService>());

          container.dispose();
        },
      );

      test('writingPromptsProvider returns list of prompts', () async {
        await prefs.remove('writing_prompts_custom');
        final container = ProviderContainer(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        );

        final prompts = container.read(writingPromptsProvider);

        expect(prompts, isNotEmpty);
        expect(prompts, isA<List<WritingPrompt>>());

        container.dispose();
      });

      test('writingPromptsByCategoryProvider filters by category', () async {
        await prefs.remove('writing_prompts_custom');
        final container = ProviderContainer(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        );

        final prompts = container.read(
          writingPromptsByCategoryProvider(WritingPromptCategory.sceneStarters),
        );

        expect(prompts, isNotEmpty);
        expect(
          prompts.every(
            (p) => p.category == WritingPromptCategory.sceneStarters,
          ),
          true,
        );

        container.dispose();
      });

      test(
        'writingPromptSearchProvider returns empty for empty query',
        () async {
          await prefs.remove('writing_prompts_custom');
          final container = ProviderContainer(
            overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          );

          final prompts = container.read(writingPromptSearchProvider(''));

          expect(prompts, isEmpty);

          container.dispose();
        },
      );

      test('writingPromptSearchProvider returns results for query', () async {
        await prefs.remove('writing_prompts_custom');
        final container = ProviderContainer(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        );

        final prompts = container.read(
          writingPromptSearchProvider('character'),
        );

        expect(prompts, isNotEmpty);

        container.dispose();
      });

      test(
        'customWritingPromptsProvider returns only custom prompts',
        () async {
          const customJson = '''[
          {"id":"custom_1","text":"Custom","category":"custom","isCustom":true}
        ]''';
          await prefs.setString('writing_prompts_custom', customJson);
          final container = ProviderContainer(
            overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          );

          final custom = container.read(customWritingPromptsProvider);

          expect(custom.length, 1);
          expect(custom.first.id, 'custom_1');

          container.dispose();
        },
      );
    });
  });
}
