import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/models/character_template_row.dart';

@immutable
class CharacterFormState {
  final bool isLoading;
  final bool isDirty;
  final String? error;
  final bool isConverting;
  final bool showPreview;
  final CharacterTemplateRow? selectedTemplate;
  final String languageCode;

  const CharacterFormState({
    this.isLoading = false,
    this.isDirty = false,
    this.error,
    this.isConverting = false,
    this.showPreview = false,
    this.selectedTemplate,
    this.languageCode = 'en',
  });

  CharacterFormState copyWith({
    bool? isLoading,
    bool? isDirty,
    String? error,
    bool clearError = false,
    bool? isConverting,
    bool? showPreview,
    CharacterTemplateRow? selectedTemplate,
    bool clearSelectedTemplate = false,
    String? languageCode,
  }) {
    return CharacterFormState(
      isLoading: isLoading ?? this.isLoading,
      isDirty: isDirty ?? this.isDirty,
      error: clearError ? null : (error ?? this.error),
      isConverting: isConverting ?? this.isConverting,
      showPreview: showPreview ?? this.showPreview,
      selectedTemplate: clearSelectedTemplate
          ? null
          : (selectedTemplate ?? this.selectedTemplate),
      languageCode: languageCode ?? this.languageCode,
    );
  }
}

class CharacterFormNotifier extends Notifier<CharacterFormState> {
  String _baseTitle = '';
  String _baseSummaries = '';
  String _baseSynopses = '';
  String _baseLanguageCode = 'en';

  @override
  CharacterFormState build() => const CharacterFormState();

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
    state = state.copyWith(languageCode: code, clearSelectedTemplate: true);
    _updateDirty();
  }

  void setSelectedTemplate(CharacterTemplateRow? template) {
    state = state.copyWith(selectedTemplate: template);
  }

  void setBaseValues(
    String title,
    String summaries,
    String synopses,
    String languageCode,
  ) {
    _baseTitle = title;
    _baseSummaries = summaries;
    _baseSynopses = synopses;
    _baseLanguageCode = languageCode;
  }

  void updateDirty(
    String title,
    String summaries,
    String synopses,
    String languageCode,
  ) {
    final dirty =
        title.trim() != _baseTitle.trim() ||
        summaries.trim() != _baseSummaries.trim() ||
        synopses.trim() != _baseSynopses.trim() ||
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

final characterFormProvider =
    NotifierProvider<CharacterFormNotifier, CharacterFormState>(
      CharacterFormNotifier.new,
    );
