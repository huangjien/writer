import 'package:flutter_riverpod/flutter_riverpod.dart';

class TemplateFormState {
  final bool isLoading;
  final bool isRetrieving;
  final bool isDirty;
  final String? error;
  final String languageCode;

  const TemplateFormState({
    this.isLoading = false,
    this.isRetrieving = false,
    this.isDirty = false,
    this.error,
    this.languageCode = 'en',
  });

  TemplateFormState copyWith({
    bool? isLoading,
    bool? isRetrieving,
    bool? isDirty,
    String? error,
    bool clearError = false,
    String? languageCode,
  }) {
    return TemplateFormState(
      isLoading: isLoading ?? this.isLoading,
      isRetrieving: isRetrieving ?? this.isRetrieving,
      isDirty: isDirty ?? this.isDirty,
      error: clearError ? null : (error ?? this.error),
      languageCode: languageCode ?? this.languageCode,
    );
  }
}

class TemplateFormNotifier extends Notifier<TemplateFormState> {
  String _baseName = '';
  String _baseDesc = '';
  String _baseLanguageCode = 'en';

  @override
  TemplateFormState build() => const TemplateFormState();

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void setRetrieving(bool retrieving) {
    state = state.copyWith(isRetrieving: retrieving);
  }

  void setError(String? error) {
    state = state.copyWith(error: error);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void setLanguageCode(String code) {
    state = state.copyWith(languageCode: code);
    _updateDirty();
  }

  void setBaseValues(String name, String desc, String languageCode) {
    _baseName = name;
    _baseDesc = desc;
    _baseLanguageCode = languageCode;
  }

  void updateDirty(String name, String desc, String languageCode) {
    final dirty =
        name.trim() != _baseName.trim() ||
        desc.trim() != _baseDesc.trim() ||
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

final templateFormProvider =
    NotifierProvider<TemplateFormNotifier, TemplateFormState>(
      TemplateFormNotifier.new,
    );
