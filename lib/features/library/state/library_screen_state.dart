import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/features/library/widgets/library_list_header.dart';
import 'package:writer/shared/widgets/mobile_bottom_nav_bar.dart';

enum LibrarySort { titleAsc, authorAsc }

enum LibraryFilter { all, reading, completed, downloaded }

@immutable
class LibraryScreenState {
  final LibrarySort sort;
  final LibraryViewMode viewMode;
  final LibraryFilter filter;
  final String searchQuery;
  final MobileNavTab currentTab;

  const LibraryScreenState({
    this.sort = LibrarySort.titleAsc,
    this.viewMode = LibraryViewMode.list,
    this.filter = LibraryFilter.all,
    this.searchQuery = '',
    this.currentTab = MobileNavTab.home,
  });

  LibraryScreenState copyWith({
    LibrarySort? sort,
    LibraryViewMode? viewMode,
    LibraryFilter? filter,
    String? searchQuery,
    MobileNavTab? currentTab,
  }) {
    return LibraryScreenState(
      sort: sort ?? this.sort,
      viewMode: viewMode ?? this.viewMode,
      filter: filter ?? this.filter,
      searchQuery: searchQuery ?? this.searchQuery,
      currentTab: currentTab ?? this.currentTab,
    );
  }
}

class LibraryScreenNotifier extends Notifier<LibraryScreenState> {
  @override
  LibraryScreenState build() => const LibraryScreenState();

  void setSort(LibrarySort value) {
    state = state.copyWith(sort: value);
  }

  void setViewMode(LibraryViewMode value) {
    state = state.copyWith(viewMode: value);
  }

  void setFilter(LibraryFilter value) {
    state = state.copyWith(filter: value);
  }

  void setSearchQuery(String value) {
    state = state.copyWith(searchQuery: value);
  }

  void setCurrentTab(MobileNavTab value) {
    state = state.copyWith(currentTab: value);
  }
}

final libraryScreenProvider =
    NotifierProvider<LibraryScreenNotifier, LibraryScreenState>(
      LibraryScreenNotifier.new,
    );
