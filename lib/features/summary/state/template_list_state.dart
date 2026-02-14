import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/models/scene_template_row.dart';
import 'package:writer/models/character_template_row.dart';

class TemplateListState<T> {
  final bool isLoading;
  final bool searchLoading;
  final String? error;
  final List<T> items;
  final List<T> displayItems;
  final String? selectedId;

  const TemplateListState({
    this.isLoading = false,
    this.searchLoading = false,
    this.error,
    this.items = const [],
    this.displayItems = const [],
    this.selectedId,
  });

  TemplateListState<T> copyWith({
    bool? isLoading,
    bool? searchLoading,
    String? error,
    bool clearError = false,
    List<T>? items,
    List<T>? displayItems,
    String? selectedId,
    bool clearSelected = false,
  }) {
    return TemplateListState<T>(
      isLoading: isLoading ?? this.isLoading,
      searchLoading: searchLoading ?? this.searchLoading,
      error: clearError ? null : (error ?? this.error),
      items: items ?? this.items,
      displayItems: displayItems ?? this.displayItems,
      selectedId: clearSelected ? null : (selectedId ?? this.selectedId),
    );
  }
}

class TemplateListNotifier<T> extends Notifier<TemplateListState<T>> {
  @override
  TemplateListState<T> build() => TemplateListState<T>();

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void setSearchLoading(bool loading) {
    state = state.copyWith(searchLoading: loading);
  }

  void setError(String? error) {
    state = state.copyWith(error: error);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void setItems(List<T> items) {
    state = state.copyWith(items: items, displayItems: items);
  }

  void setDisplayItems(List<T> displayItems) {
    state = state.copyWith(displayItems: displayItems);
  }

  void setSelectedId(String? id) {
    state = state.copyWith(selectedId: id);
  }

  void clearSelected() {
    state = state.copyWith(clearSelected: true);
  }

  void reset() {
    state = TemplateListState<T>();
  }
}

final sceneTemplateListProvider =
    NotifierProvider<
      TemplateListNotifier<SceneTemplateRow>,
      TemplateListState<SceneTemplateRow>
    >(TemplateListNotifier<SceneTemplateRow>.new);

final characterTemplateListProvider =
    NotifierProvider<
      TemplateListNotifier<CharacterTemplateRow>,
      TemplateListState<CharacterTemplateRow>
    >(TemplateListNotifier<CharacterTemplateRow>.new);
