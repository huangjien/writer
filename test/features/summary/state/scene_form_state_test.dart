import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/models/scene_template_row.dart';
import 'package:writer/features/summary/state/scene_form_state.dart';

void main() {
  group('SceneFormState', () {
    test('should create with default values', () {
      const state = SceneFormState();
      expect(state.isLoading, false);
      expect(state.isDirty, false);
      expect(state.error, null);
      expect(state.isConverting, false);
      expect(state.showPreview, false);
      expect(state.templateSearchLoading, false);
      expect(state.templateQuery, '');
      expect(state.templateSearchResults, isEmpty);
      expect(state.selectedTemplate, null);
      expect(state.languageCode, 'en');
    });

    test('should create with custom values', () {
      final now = DateTime.now();
      final template = SceneTemplateRow(
        id: '1',
        idx: 0,
        title: 'Template',
        sceneSummaries: 'Content',
        languageCode: 'en',
        createdAt: now,
        updatedAt: now,
      );
      final state = SceneFormState(
        isLoading: true,
        isDirty: true,
        error: 'Test error',
        isConverting: true,
        showPreview: true,
        templateSearchLoading: true,
        templateQuery: 'query',
        templateSearchResults: const [],
        selectedTemplate: template,
        languageCode: 'zh',
      );
      expect(state.isLoading, true);
      expect(state.isDirty, true);
      expect(state.error, 'Test error');
      expect(state.isConverting, true);
      expect(state.showPreview, true);
      expect(state.templateSearchLoading, true);
      expect(state.templateQuery, 'query');
      expect(state.selectedTemplate, template);
      expect(state.languageCode, 'zh');
    });

    test('copyWith should update provided values', () {
      const state = SceneFormState();
      final updated = state.copyWith(
        isLoading: true,
        error: 'New error',
        languageCode: 'zh',
      );
      expect(updated.isLoading, true);
      expect(updated.error, 'New error');
      expect(updated.languageCode, 'zh');
      expect(updated.isDirty, false);
    });

    test('copyWith should clear error when clearError is true', () {
      const state = SceneFormState(error: 'Error');
      final updated = state.copyWith(clearError: true);
      expect(updated.error, null);
    });

    test('copyWith should keep error when clearError is false', () {
      const state = SceneFormState(error: 'Error');
      final updated = state.copyWith(clearError: false);
      expect(updated.error, 'Error');
    });

    test(
      'copyWith should clear selectedTemplate when clearSelectedTemplate is true',
      () {
        final now = DateTime.now();
        final template = SceneTemplateRow(
          id: '1',
          idx: 0,
          title: 'Template',
          sceneSummaries: 'Content',
          languageCode: 'en',
          createdAt: now,
          updatedAt: now,
        );
        final state = SceneFormState(selectedTemplate: template);
        final updated = state.copyWith(clearSelectedTemplate: true);
        expect(updated.selectedTemplate, null);
      },
    );

    test('copyWith should update templateSearchResults', () {
      const state = SceneFormState();
      final now = DateTime.now();
      final results = [
        SceneTemplateRow(
          id: '1',
          idx: 0,
          title: 'T1',
          sceneSummaries: 'C1',
          languageCode: 'en',
          createdAt: now,
          updatedAt: now,
        ),
      ];
      final updated = state.copyWith(templateSearchResults: results);
      expect(updated.templateSearchResults, results);
    });
  });

  group('SceneFormNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('should initialize with default state', () {
      final state = container.read(sceneFormProvider);
      expect(state.isLoading, false);
      expect(state.isDirty, false);
      expect(state.showPreview, false);
    });

    test('setLoading should update isLoading', () {
      final notifier = container.read(sceneFormProvider.notifier);
      notifier.setLoading(true);
      expect(container.read(sceneFormProvider).isLoading, true);
      notifier.setLoading(false);
      expect(container.read(sceneFormProvider).isLoading, false);
    });

    test('setError should update error', () {
      final notifier = container.read(sceneFormProvider.notifier);
      notifier.setError('Test error');
      expect(container.read(sceneFormProvider).error, 'Test error');
    });

    test('clearError should clear error', () {
      final notifier = container.read(sceneFormProvider.notifier);
      notifier.setError('Error');
      notifier.clearError();
      expect(container.read(sceneFormProvider).error, null);
    });

    test('setDirty should update isDirty', () {
      final notifier = container.read(sceneFormProvider.notifier);
      notifier.setDirty(true);
      expect(container.read(sceneFormProvider).isDirty, true);
      notifier.setDirty(false);
      expect(container.read(sceneFormProvider).isDirty, false);
    });

    test('setConverting should update isConverting', () {
      final notifier = container.read(sceneFormProvider.notifier);
      notifier.setConverting(true);
      expect(container.read(sceneFormProvider).isConverting, true);
    });

    test('togglePreview should toggle showPreview', () {
      final notifier = container.read(sceneFormProvider.notifier);
      expect(container.read(sceneFormProvider).showPreview, false);
      notifier.togglePreview();
      expect(container.read(sceneFormProvider).showPreview, true);
      notifier.togglePreview();
      expect(container.read(sceneFormProvider).showPreview, false);
    });

    test(
      'setLanguageCode should update languageCode and reset template fields',
      () async {
        final notifier = container.read(sceneFormProvider.notifier);
        final now = DateTime.now();
        final template = SceneTemplateRow(
          id: '1',
          idx: 0,
          title: 'Template',
          sceneSummaries: 'Content',
          languageCode: 'en',
          createdAt: now,
          updatedAt: now,
        );
        notifier.setSelectedTemplate(template);
        notifier.scheduleTemplateSearch('query', (_) => Future.value([]));

        await Future.delayed(const Duration(milliseconds: 300));

        notifier.setLanguageCode('zh');
        final state = container.read(sceneFormProvider);
        expect(state.languageCode, 'zh');
        expect(state.selectedTemplate, null);
        expect(state.templateQuery, '');
        expect(state.templateSearchResults, isEmpty);
        expect(state.templateSearchLoading, false);
      },
    );

    test('setSelectedTemplate should update selectedTemplate', () {
      final notifier = container.read(sceneFormProvider.notifier);
      final now = DateTime.now();
      final template = SceneTemplateRow(
        id: '1',
        idx: 0,
        title: 'Template',
        sceneSummaries: 'Content',
        languageCode: 'en',
        createdAt: now,
        updatedAt: now,
      );
      notifier.setSelectedTemplate(template);
      expect(container.read(sceneFormProvider).selectedTemplate, template);
    });

    test(
      'scheduleTemplateSearch with empty query should clear results',
      () async {
        final notifier = container.read(sceneFormProvider.notifier);
        notifier.scheduleTemplateSearch('  ', (_) => Future.value([]));
        final state = container.read(sceneFormProvider);
        expect(state.templateQuery, '');
        expect(state.templateSearchResults, isEmpty);
        expect(state.templateSearchLoading, false);
      },
    );

    test('scheduleTemplateSearch should debounce and update results', () async {
      final notifier = container.read(sceneFormProvider.notifier);
      final now = DateTime.now();
      final results = [
        SceneTemplateRow(
          id: '1',
          idx: 0,
          title: 'T1',
          sceneSummaries: 'C1',
          languageCode: 'en',
          createdAt: now,
          updatedAt: now,
        ),
      ];
      notifier.scheduleTemplateSearch('test', (_) => Future.value(results));

      expect(container.read(sceneFormProvider).templateSearchLoading, true);

      await Future.delayed(const Duration(milliseconds: 300));

      final state = container.read(sceneFormProvider);
      expect(state.templateSearchLoading, false);
      expect(state.templateSearchResults, results);
    });

    test('scheduleTemplateSearch should handle errors gracefully', () async {
      final notifier = container.read(sceneFormProvider.notifier);
      notifier.scheduleTemplateSearch(
        'test',
        (_) => Future.error(Exception('Search failed')),
      );

      await Future.delayed(const Duration(milliseconds: 300));

      final state = container.read(sceneFormProvider);
      expect(state.templateSearchLoading, false);
      expect(state.templateSearchResults, isEmpty);
    });

    test('setBaseValues should store base values', () {
      final notifier = container.read(sceneFormProvider.notifier);
      notifier.setBaseValues('Title', 'Location', 'Summary', 'en');
      notifier.updateDirty('Title', 'Location', 'Summary', 'en');
      expect(container.read(sceneFormProvider).isDirty, false);
    });

    test('updateDirty should detect changes in title', () {
      final notifier = container.read(sceneFormProvider.notifier);
      notifier.setBaseValues('Title', 'Location', 'Summary', 'en');
      notifier.updateDirty('Changed', 'Location', 'Summary', 'en');
      expect(container.read(sceneFormProvider).isDirty, true);
    });

    test('updateDirty should detect changes in location', () {
      final notifier = container.read(sceneFormProvider.notifier);
      notifier.setBaseValues('Title', 'Location', 'Summary', 'en');
      notifier.updateDirty('Title', 'Changed', 'Summary', 'en');
      expect(container.read(sceneFormProvider).isDirty, true);
    });

    test('updateDirty should detect changes in summary', () {
      final notifier = container.read(sceneFormProvider.notifier);
      notifier.setBaseValues('Title', 'Location', 'Summary', 'en');
      notifier.updateDirty('Title', 'Location', 'Changed', 'en');
      expect(container.read(sceneFormProvider).isDirty, true);
    });

    test('updateDirty should detect changes in languageCode', () {
      final notifier = container.read(sceneFormProvider.notifier);
      notifier.setBaseValues('Title', 'Location', 'Summary', 'en');
      notifier.updateDirty('Title', 'Location', 'Summary', 'zh');
      expect(container.read(sceneFormProvider).isDirty, true);
    });

    test('updateDirty should ignore whitespace changes', () {
      final notifier = container.read(sceneFormProvider.notifier);
      notifier.setBaseValues('Title', 'Location', 'Summary', 'en');
      notifier.updateDirty('  Title  ', '  Location  ', '  Summary  ', 'en');
      expect(container.read(sceneFormProvider).isDirty, false);
    });

    test(
      'setLanguageCode should update dirty when language differs from base',
      () {
        final notifier = container.read(sceneFormProvider.notifier);
        notifier.setBaseValues('Title', 'Location', 'Summary', 'en');
        notifier.setLanguageCode('zh');
        expect(container.read(sceneFormProvider).isDirty, true);
      },
    );

    test(
      'setLanguageCode should not update dirty when language matches base',
      () {
        final notifier = container.read(sceneFormProvider.notifier);
        notifier.setBaseValues('Title', 'Location', 'Summary', 'en');
        notifier.setLanguageCode('en');
        expect(container.read(sceneFormProvider).isDirty, false);
      },
    );

    test('scheduleTemplateSearch should cancel previous timer', () async {
      final notifier = container.read(sceneFormProvider.notifier);
      var callCount = 0;

      notifier.scheduleTemplateSearch('first', (_) {
        callCount++;
        return Future.value([]);
      });

      notifier.scheduleTemplateSearch('second', (_) {
        callCount++;
        return Future.value([]);
      });

      await Future.delayed(const Duration(milliseconds: 300));

      expect(callCount, lessThanOrEqualTo(1));
    });
  });
}
