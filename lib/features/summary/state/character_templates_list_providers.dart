import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/models/character_template_row.dart';
import 'package:writer/repositories/template_repository.dart';
import 'package:writer/state/providers.dart';

@immutable
class CharacterTemplatesListState {
  final List<CharacterTemplateRow> items;
  final List<CharacterTemplateRow> displayItems;
  final bool isLoading;
  final bool isSearchLoading;
  final String? error;
  final TextEditingController searchCtrl;
  final DateTime? lastRowTapAt;
  final String? lastRowTapId;
  final String? selectedId;

  const CharacterTemplatesListState({
    required this.items,
    required this.displayItems,
    this.isLoading = false,
    this.isSearchLoading = false,
    this.error,
    required this.searchCtrl,
    this.lastRowTapAt,
    this.lastRowTapId,
    this.selectedId,
  });

  CharacterTemplatesListState copyWith({
    List<CharacterTemplateRow>? items,
    List<CharacterTemplateRow>? displayItems,
    bool? isLoading,
    bool? isSearchLoading,
    String? error,
    TextEditingController? searchCtrl,
    DateTime? lastRowTapAt,
    String? lastRowTapId,
    String? selectedId,
    bool clearError = false,
    bool clearSelectedId = false,
  }) {
    return CharacterTemplatesListState(
      items: items ?? this.items,
      displayItems: displayItems ?? this.displayItems,
      isLoading: isLoading ?? this.isLoading,
      isSearchLoading: isSearchLoading ?? this.isSearchLoading,
      error: clearError ? null : (error ?? this.error),
      searchCtrl: searchCtrl ?? this.searchCtrl,
      lastRowTapAt: lastRowTapAt ?? this.lastRowTapAt,
      lastRowTapId: lastRowTapId ?? this.lastRowTapId,
      selectedId: clearSelectedId ? null : (selectedId ?? this.selectedId),
    );
  }
}

class CharacterTemplatesListNotifier
    extends Notifier<CharacterTemplatesListState> {
  @override
  CharacterTemplatesListState build() => CharacterTemplatesListState(
    items: [],
    displayItems: [],
    isLoading: true,
    isSearchLoading: false,
    searchCtrl: TextEditingController(),
  );

  void setItems(
    List<CharacterTemplateRow> items,
    List<CharacterTemplateRow> displayItems,
  ) {
    state = state.copyWith(items: items, displayItems: displayItems);
  }

  void setLoading(bool value) {
    state = state.copyWith(isLoading: value);
  }

  void setSearchLoading(bool value) {
    state = state.copyWith(isSearchLoading: value);
  }

  void setError(String? error) {
    state = state.copyWith(error: error, clearError: error == null);
  }

  void setSelectedId(String? id) {
    state = state.copyWith(selectedId: id, clearSelectedId: id == null);
  }

  void setLastRowTap(DateTime? time, String? id) {
    state = state.copyWith(lastRowTapAt: time, lastRowTapId: id);
  }

  Future<void> setLocalSearch() async {
    final q = state.searchCtrl.text.trim().toLowerCase();
    if (q.isEmpty) {
      setItems(state.items, state.items);
      return;
    }
    setSearchLoading(true);
    try {
      final isSignedIn = ref.read(isSignedInProvider);
      if (isSignedIn) {
        final repo = ref.read(templateRepositoryProvider);
        final res = await repo.searchCharacterTemplates(q, limit: 5);
        if (!ref.mounted) return;
        setItems(res, res);
      } else {
        final filtered = state.items.where((t) {
          final title = (t.title ?? '').toLowerCase();
          return title.contains(q);
        }).toList();
        setItems(state.items, filtered);
      }
    } catch (e) {
      setError(e.toString());
    } finally {
      setSearchLoading(false);
    }
  }

  Future<void> smartSearch() async {
    final q = state.searchCtrl.text.trim().toLowerCase();
    if (q.isEmpty) return;
    setSearchLoading(true);

    try {
      final isSignedIn = ref.read(isSignedInProvider);
      if (!isSignedIn) {
        setError('Please sign in to search');
        setSearchLoading(false);
        return;
      }
      final repo = ref.read(templateRepositoryProvider);
      final res = await repo.searchCharacterTemplates(q, limit: 5);
      if (!ref.mounted) return;
      setItems(res, res);
    } catch (e) {
      setError(e.toString());
    } finally {
      setSearchLoading(false);
    }
  }
}

final characterTemplatesListProvider =
    NotifierProvider<
      CharacterTemplatesListNotifier,
      CharacterTemplatesListState
    >(CharacterTemplatesListNotifier.new);
