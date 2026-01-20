import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pattern.dart';
import '../shared/constants.dart';
import 'providers.dart';
import 'pattern_providers.dart';

@immutable
class PatternListState {
  final List<Pattern> items;
  final bool searchLoading;
  final String? error;
  final String? filterLanguage;
  final bool? filterLocked;
  final String searchQuery;

  static const Object _unset = Object();

  const PatternListState({
    this.items = const [],
    this.searchLoading = false,
    this.error,
    this.filterLanguage,
    this.filterLocked,
    this.searchQuery = '',
  });

  PatternListState copyWith({
    List<Pattern>? items,
    bool? searchLoading,
    String? error,
    Object? filterLanguage = _unset,
    Object? filterLocked = _unset,
    String? searchQuery,
    bool clearError = false,
  }) {
    return PatternListState(
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

class PatternListNotifier extends Notifier<PatternListState> {
  Timer? _searchTimer;

  @override
  PatternListState build() {
    ref.onDispose(() {
      _searchTimer?.cancel();
      _searchTimer = null;
    });
    return const PatternListState();
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    _searchTimer?.cancel();
    _searchTimer = Timer(const Duration(milliseconds: kSearchDebounceMs), () {
      _performSearch();
    });
  }

  void clearSearch() {
    _searchTimer?.cancel();
    state = state.copyWith(
      items: [],
      clearError: true,
      searchQuery: '',
      searchLoading: false,
    );
  }

  void setFilterLanguage(String? language) {
    state = state.copyWith(filterLanguage: language);
  }

  void toggleFilterLocked() {
    bool? newFilter;
    if (state.filterLocked == null) {
      newFilter = true;
    } else if (state.filterLocked == true) {
      newFilter = false;
    } else {
      newFilter = null;
    }
    state = state.copyWith(filterLocked: newFilter);
  }

  Future<void> performSearch({bool force = false}) async {
    await _performSearch(force: force);
  }

  Future<void> _performSearch({bool force = false}) async {
    final q = state.searchQuery.trim();
    if (q.isEmpty) {
      state = state.copyWith(items: [], clearError: true);
      return;
    }
    if (!force && q.length < kSearchMinLen) {
      return;
    }
    state = state.copyWith(searchLoading: true, clearError: true);
    try {
      final svc = ref.read(patternsServiceRefProvider);
      final data = await svc.searchPatterns(q);
      state = state.copyWith(items: data, searchLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), searchLoading: false);
    }
  }

  Future<void> smartSearch() async {
    _searchTimer?.cancel();
    final q = state.searchQuery.trim();
    if (q.isEmpty) return;

    final isSignedIn = ref.read(isSignedInProvider);
    if (!isSignedIn) {
      state = state.copyWith(error: 'Not signed in');
      return;
    }

    state = state.copyWith(searchLoading: true);

    try {
      final svc = ref.read(patternsServiceRefProvider);
      final res = await svc.smartSearchPatterns(q, limit: 5);
      if (res.isEmpty) {
        await _performSearch(force: true);
      } else {
        state = state.copyWith(items: res, searchLoading: false);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString(), searchLoading: false);
    }
  }

  void removeItem(String id) {
    state = state.copyWith(
      items: state.items.where((e) => e.id != id).toList(),
    );
  }
}

final patternListProvider =
    NotifierProvider<PatternListNotifier, PatternListState>(
      PatternListNotifier.new,
    );

class LastRowTap {
  final String id;
  final DateTime? at;

  const LastRowTap({this.id = '', this.at});
}

class LastRowTapNotifier extends Notifier<LastRowTap> {
  @override
  LastRowTap build() {
    return const LastRowTap();
  }

  void set(String id, DateTime at) {
    state = LastRowTap(id: id, at: at);
  }

  void clear() {
    state = const LastRowTap();
  }
}

final lastRowTapProvider = NotifierProvider<LastRowTapNotifier, LastRowTap>(
  LastRowTapNotifier.new,
);
