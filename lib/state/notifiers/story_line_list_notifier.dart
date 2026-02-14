import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/story_line.dart';
import '../story_line_providers.dart';
import '../../../shared/constants.dart';

@immutable
class StoryLineListState {
  final List<StoryLine> items;
  final bool searchLoading;
  final String? error;
  final String? filterLanguage;
  final bool? filterLocked;
  final String searchQuery;

  static const Object _unset = Object();

  const StoryLineListState({
    this.items = const [],
    this.searchLoading = false,
    this.error,
    this.filterLanguage,
    this.filterLocked,
    this.searchQuery = '',
  });

  StoryLineListState copyWith({
    List<StoryLine>? items,
    bool? searchLoading,
    String? error,
    Object? filterLanguage = _unset,
    Object? filterLocked = _unset,
    String? searchQuery,
    bool clearError = false,
  }) {
    return StoryLineListState(
      items: items ?? this.items,
      searchLoading: searchLoading ?? this.searchLoading,
      error: clearError ? null : (error ?? this.error),
      filterLanguage: filterLanguage == _unset
          ? this.filterLanguage
          : filterLanguage as String?,
      filterLocked: filterLocked == _unset
          ? this.filterLocked
          : filterLocked as bool?,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class StoryLineListNotifier extends Notifier<StoryLineListState> {
  Timer? _searchTimer;

  @override
  StoryLineListState build() {
    ref.onDispose(() {
      _searchTimer?.cancel();
      _searchTimer = null;
    });
    return const StoryLineListState();
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    _debouncedSearch();
  }

  void _debouncedSearch() {
    _searchTimer?.cancel();
    final q = state.searchQuery.trim();
    if (q.isEmpty) {
      clearSearch();
      return;
    }
    _searchTimer = Timer(
      const Duration(milliseconds: kSearchDebounceMs),
      () => performSearch(),
    );
  }

  Future<void> performSearch({bool force = false}) async {
    final q = state.searchQuery.trim();
    if (q.isEmpty) {
      clearSearch();
      return;
    }
    if (!force && q.length < kSearchMinLen) {
      return;
    }
    state = state.copyWith(searchLoading: true);
    try {
      final svc = ref.read(storyLinesServiceRefProvider);
      final data = await svc.searchStoryLines(q);
      state = state.copyWith(items: data, searchLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), searchLoading: false);
    }
  }

  void clearSearch() {
    state = const StoryLineListState();
  }

  void setFilterLanguage(String? language) {
    state = state.copyWith(filterLanguage: language);
  }

  void toggleFilterLocked() {
    if (state.filterLocked == null) {
      state = state.copyWith(filterLocked: true);
    } else if (state.filterLocked == true) {
      state = state.copyWith(filterLocked: false);
    } else {
      state = state.copyWith(filterLocked: null);
    }
  }

  void setSearchLoading(bool loading) {
    state = state.copyWith(searchLoading: loading);
  }

  void setSearchItems(List<StoryLine> items) {
    state = state.copyWith(items: items, clearError: true);
  }

  void setError(String error) {
    state = state.copyWith(error: error);
  }

  void removeItem(String id) {
    final updatedItems = state.items.where((item) => item.id != id).toList();
    state = state.copyWith(items: updatedItems);
  }
}

final storyLineListProvider =
    NotifierProvider<StoryLineListNotifier, StoryLineListState>(
      StoryLineListNotifier.new,
    );
