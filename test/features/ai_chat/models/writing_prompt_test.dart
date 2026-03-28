import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:writer/features/ai_chat/models/writing_prompt.dart';

void main() {
  group('WritingPromptCategory Tests', () {
    test('has all required categories', () {
      expect(WritingPromptCategory.values.length, 8);
    });

    test('sceneStarters category has correct properties', () {
      const category = WritingPromptCategory.sceneStarters;
      expect(category.label, 'Scene Starters');
      expect(category.description, 'Beginnings to spark your story');
      expect(category.icon, Icons.play_arrow);
    });

    test('characterDevelopment category has correct properties', () {
      const category = WritingPromptCategory.characterDevelopment;
      expect(category.label, 'Character');
      expect(category.description, 'Build rich, complex characters');
      expect(category.icon, Icons.person);
    });

    test('dialogue category has correct properties', () {
      const category = WritingPromptCategory.dialogue;
      expect(category.label, 'Dialogue');
      expect(category.description, 'Craft compelling conversations');
      expect(category.icon, Icons.chat_bubble);
    });

    test('worldBuilding category has correct properties', () {
      const category = WritingPromptCategory.worldBuilding;
      expect(category.label, 'World Building');
      expect(category.description, 'Develop your setting');
      expect(category.icon, Icons.public);
    });

    test('plot category has correct properties', () {
      const category = WritingPromptCategory.plot;
      expect(category.label, 'Plot');
      expect(category.description, 'Structure your narrative');
      expect(category.icon, Icons.auto_graph);
    });

    test('writingExercises category has correct properties', () {
      const category = WritingPromptCategory.writingExercises;
      expect(category.label, 'Exercises');
      expect(category.description, 'Practice specific techniques');
      expect(category.icon, Icons.edit);
    });

    test('templates category has correct properties', () {
      const category = WritingPromptCategory.templates;
      expect(category.label, 'Templates');
      expect(category.description, 'Structured formats and frameworks');
      expect(category.icon, Icons.description);
    });

    test('custom category has correct properties', () {
      const category = WritingPromptCategory.custom;
      expect(category.label, 'Custom');
      expect(category.description, 'Your personal prompts');
      expect(category.icon, Icons.star);
    });
  });

  group('WritingPrompt Tests', () {
    test('creates WritingPrompt with required fields', () {
      const prompt = WritingPrompt(
        id: 'test_1',
        text: 'Test prompt text',
        category: WritingPromptCategory.sceneStarters,
      );

      expect(prompt.id, 'test_1');
      expect(prompt.text, 'Test prompt text');
      expect(prompt.category, WritingPromptCategory.sceneStarters);
      expect(prompt.isCustom, false);
      expect(prompt.aiContext, null);
    });

    test('creates WritingPrompt with all fields', () {
      const prompt = WritingPrompt(
        id: 'test_2',
        text: 'Test prompt with AI context',
        category: WritingPromptCategory.characterDevelopment,
        isCustom: true,
        aiContext: 'Help me develop character depth',
      );

      expect(prompt.id, 'test_2');
      expect(prompt.text, 'Test prompt with AI context');
      expect(prompt.category, WritingPromptCategory.characterDevelopment);
      expect(prompt.isCustom, true);
      expect(prompt.aiContext, 'Help me develop character depth');
    });

    test('copyWith creates new instance with updated fields', () {
      const original = WritingPrompt(
        id: 'original',
        text: 'Original text',
        category: WritingPromptCategory.dialogue,
      );

      final updated = original.copyWith(text: 'Updated text', isCustom: true);

      expect(updated.id, 'original');
      expect(updated.text, 'Updated text');
      expect(updated.category, WritingPromptCategory.dialogue);
      expect(updated.isCustom, true);
    });

    test('copyWith with null values keeps original values', () {
      const original = WritingPrompt(
        id: 'test',
        text: 'Test',
        category: WritingPromptCategory.plot,
        aiContext: 'Context',
      );

      final copied = original.copyWith();

      expect(copied.id, original.id);
      expect(copied.text, original.text);
      expect(copied.category, original.category);
      expect(copied.isCustom, original.isCustom);
      expect(copied.aiContext, original.aiContext);
    });

    test('toJson serializes correctly', () {
      const prompt = WritingPrompt(
        id: 'serialize_1',
        text: 'Serialization test',
        category: WritingPromptCategory.worldBuilding,
        isCustom: true,
        aiContext: 'AI helper context',
      );

      final json = prompt.toJson();

      expect(json['id'], 'serialize_1');
      expect(json['text'], 'Serialization test');
      expect(json['category'], 'worldBuilding');
      expect(json['isCustom'], true);
      expect(json['aiContext'], 'AI helper context');
    });

    test('fromJson deserializes correctly', () {
      final json = {
        'id': 'deserialize_1',
        'text': 'Deserialization test',
        'category': 'writingExercises',
        'isCustom': false,
        'aiContext': 'Test context',
      };

      final prompt = WritingPrompt.fromJson(json);

      expect(prompt.id, 'deserialize_1');
      expect(prompt.text, 'Deserialization test');
      expect(prompt.category, WritingPromptCategory.writingExercises);
      expect(prompt.isCustom, false);
      expect(prompt.aiContext, 'Test context');
    });

    test('fromJson handles missing optional fields', () {
      final json = {
        'id': 'missing_1',
        'text': 'Missing fields test',
        'category': 'templates',
      };

      final prompt = WritingPrompt.fromJson(json);

      expect(prompt.id, 'missing_1');
      expect(prompt.text, 'Missing fields test');
      expect(prompt.category, WritingPromptCategory.templates);
      expect(prompt.isCustom, false);
      expect(prompt.aiContext, null);
    });

    test('fromJson handles invalid category by defaulting to custom', () {
      final json = {
        'id': 'invalid_cat',
        'text': 'Invalid category test',
        'category': 'invalidCategoryName',
      };

      final prompt = WritingPrompt.fromJson(json);

      expect(prompt.category, WritingPromptCategory.custom);
    });

    test('toJson and fromJson roundtrip', () {
      const original = WritingPrompt(
        id: 'roundtrip_1',
        text: 'Roundtrip test prompt',
        category: WritingPromptCategory.plot,
        isCustom: true,
        aiContext: 'Test roundtrip serialization',
      );

      final json = original.toJson();
      final restored = WritingPrompt.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.text, original.text);
      expect(restored.category, original.category);
      expect(restored.isCustom, original.isCustom);
      expect(restored.aiContext, original.aiContext);
    });

    test('equality operator works correctly', () {
      const prompt1 = WritingPrompt(
        id: 'same_id',
        text: 'First prompt',
        category: WritingPromptCategory.sceneStarters,
      );

      const prompt2 = WritingPrompt(
        id: 'same_id',
        text: 'Different text',
        category: WritingPromptCategory.dialogue,
      );

      const prompt3 = WritingPrompt(
        id: 'different_id',
        text: 'First prompt',
        category: WritingPromptCategory.sceneStarters,
      );

      expect(prompt1 == prompt2, true);
      expect(prompt1 == prompt3, false);
      expect(prompt1 == prompt1, true);
    });

    test('hashCode is based on id', () {
      const prompt1 = WritingPrompt(
        id: 'hash_test',
        text: 'First',
        category: WritingPromptCategory.sceneStarters,
      );

      const prompt2 = WritingPrompt(
        id: 'hash_test',
        text: 'Second',
        category: WritingPromptCategory.dialogue,
      );

      expect(prompt1.hashCode, prompt2.hashCode);
    });

    test('handles long prompt text', () {
      final longText = 'A' * 10000;
      final prompt = WritingPrompt(
        id: 'long_text',
        text: longText,
        category: WritingPromptCategory.writingExercises,
      );

      expect(prompt.text.length, 10000);
    });

    test('handles special characters in text', () {
      const specialText = 'Test with emoji 😊 and symbols @#\$% and unicode 世界';
      const prompt = WritingPrompt(
        id: 'special_chars',
        text: specialText,
        category: WritingPromptCategory.custom,
      );

      expect(prompt.text, specialText);
    });

    test('handles multiline text', () {
      const multilineText = '''Line 1
Line 2
Line 3''';
      const prompt = WritingPrompt(
        id: 'multiline',
        text: multilineText,
        category: WritingPromptCategory.sceneStarters,
      );

      expect(prompt.text.split('\n').length, 3);
    });

    test('handles empty aiContext', () {
      const prompt = WritingPrompt(
        id: 'empty_context',
        text: 'Test',
        category: WritingPromptCategory.custom,
        aiContext: '',
      );

      expect(prompt.aiContext, '');
    });

    test('all categories are unique', () {
      const categories = WritingPromptCategory.values;
      final uniqueCategories = categories.toSet();

      expect(categories.length, uniqueCategories.length);
    });

    test('copyWith can change category', () {
      const original = WritingPrompt(
        id: 'change_cat',
        text: 'Test',
        category: WritingPromptCategory.sceneStarters,
      );

      final updated = original.copyWith(
        category: WritingPromptCategory.dialogue,
      );

      expect(original.category, WritingPromptCategory.sceneStarters);
      expect(updated.category, WritingPromptCategory.dialogue);
    });

    test('copyWith can update aiContext', () {
      const original = WritingPrompt(
        id: 'update_context',
        text: 'Test',
        category: WritingPromptCategory.characterDevelopment,
        aiContext: 'Original context',
      );

      final updated = original.copyWith(aiContext: 'Updated context');

      expect(original.aiContext, 'Original context');
      expect(updated.aiContext, 'Updated context');
    });
  });
}
