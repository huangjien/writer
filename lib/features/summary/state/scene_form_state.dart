import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/models/scene_template_row.dart';

@immutable
class SceneFormState {
  final bool isLoading;
  final bool isDirty;
  final String? error;
  final bool isConverting;
  final bool showPreview;
  final bool templateSearchLoading;
  final String templateQuery;
  final List<SceneTemplateRow> templateSearchResults;
  final SceneTemplateRow? selectedTemplate;
  final String languageCode;

  const SceneFormState({
    this.isLoading = false,
    this.isDirty = false,
    this.error,
    this.isConverting = false,
    this.showPreview = false,
    this.templateSearchLoading = false,
    this.templateQuery = '',
    this.templateSearchResults = const [],
    this.selectedTemplate,
    this.languageCode = 'en',
  });

  SceneFormState copyWith({
    bool? isLoading,
    bool? isDirty,
    String? error,
    bool clearError = false,
    bool? isConverting,
    bool? showPreview,
    bool? templateSearchLoading,
    String? templateQuery,
    List<SceneTemplateRow>? templateSearchResults,
    SceneTemplateRow? selectedTemplate,
    bool clearSelectedTemplate = false,
    String? languageCode,
  }) {
    return SceneFormState(
      isLoading: isLoading ?? this.isLoading,
      isDirty: isDirty ?? this.isDirty,
      error: clearError ? null : (error ?? this.error),
      isConverting: isConverting ?? this.isConverting,
      showPreview: showPreview ?? this.showPreview,
      templateSearchLoading:
          templateSearchLoading ?? this.templateSearchLoading,
      templateQuery: templateQuery ?? this.templateQuery,
      templateSearchResults:
          templateSearchResults ?? this.templateSearchResults,
      selectedTemplate: clearSelectedTemplate
          ? null
          : (selectedTemplate ?? this.selectedTemplate),
      languageCode: languageCode ?? this.languageCode,
    );
  }
}

class SceneFormNotifier extends Notifier<SceneFormState> {
  Timer? _templateSearchTimer;
  String _baseTitle = '';
  String _baseLocation = '';
  String _baseSummary = '';
  String _baseLanguageCode = 'en';

  @override
  SceneFormState build() {
    ref.onDispose(() {
      _templateSearchTimer?.cancel();
      _templateSearchTimer = null;
    });
    return const SceneFormState();
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void setError(String? error) {
    state = state.copyWith(error: error);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void setDirty(bool dirty) {
    state = state.copyWith(isDirty: dirty);
  }

  void setConverting(bool converting) {
    state = state.copyWith(isConverting: converting);
  }

  void togglePreview() {
    state = state.copyWith(showPreview: !state.showPreview);
  }

  void setLanguageCode(String code) {
    _templateSearchTimer?.cancel();
    state = state.copyWith(
      languageCode: code,
      clearSelectedTemplate: true,
      templateQuery: '',
      templateSearchResults: [],
      templateSearchLoading: false,
    );
    _updateDirty();
  }

  void setSelectedTemplate(SceneTemplateRow? template) {
    state = state.copyWith(selectedTemplate: template);
  }

  void scheduleTemplateSearch(
    String query,
    Future<List<SceneTemplateRow>> Function(String) searchFn,
  ) {
    final q = query.trim();
    _templateSearchTimer?.cancel();
    state = state.copyWith(templateQuery: q);

    if (q.isEmpty) {
      state = state.copyWith(
        templateSearchLoading: false,
        templateSearchResults: [],
      );
      return;
    }

    state = state.copyWith(templateSearchLoading: true);

    _templateSearchTimer = Timer(const Duration(milliseconds: 250), () async {
      try {
        final results = await searchFn(q);
        state = state.copyWith(
          templateSearchLoading: false,
          templateSearchResults: results,
        );
      } catch (_) {
        state = state.copyWith(templateSearchLoading: false);
      }
    });
  }

  void setBaseValues(
    String title,
    String location,
    String summary,
    String languageCode,
  ) {
    _baseTitle = title;
    _baseLocation = location;
    _baseSummary = summary;
    _baseLanguageCode = languageCode;
  }

  void updateDirty(
    String title,
    String location,
    String summary,
    String languageCode,
  ) {
    final dirty =
        title.trim() != _baseTitle.trim() ||
        location.trim() != _baseLocation.trim() ||
        summary.trim() != _baseSummary.trim() ||
        languageCode != _baseLanguageCode;
    if (state.isDirty != dirty) {
      state = state.copyWith(isDirty: dirty);
    }
  }

  void _updateDirty() {
    final dirty = state.languageCode != _baseLanguageCode;
    if (state.isDirty != dirty) {
      state = state.copyWith(isDirty: dirty);
    }
  }
}

final sceneFormProvider = NotifierProvider<SceneFormNotifier, SceneFormState>(
  SceneFormNotifier.new,
);
