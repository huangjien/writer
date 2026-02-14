import 'package:flutter_test/flutter_test.dart';
import 'package:writer/features/library/state/library_screen_state.dart';
import 'package:writer/features/library/widgets/library_list_header.dart';
import 'package:writer/shared/widgets/mobile_bottom_nav_bar.dart';

void main() {
  group('LibraryScreenState', () {
    test('constructor uses default values', () {
      const state = LibraryScreenState();

      expect(state.sort, LibrarySort.titleAsc);
      expect(state.viewMode, LibraryViewMode.list);
      expect(state.filter, LibraryFilter.all);
      expect(state.searchQuery, '');
      expect(state.currentTab, MobileNavTab.home);
    });

    test('constructor accepts custom values', () {
      const state = LibraryScreenState(
        sort: LibrarySort.authorAsc,
        viewMode: LibraryViewMode.grid,
        filter: LibraryFilter.reading,
        searchQuery: 'test query',
        currentTab: MobileNavTab.tools,
      );

      expect(state.sort, LibrarySort.authorAsc);
      expect(state.viewMode, LibraryViewMode.grid);
      expect(state.filter, LibraryFilter.reading);
      expect(state.searchQuery, 'test query');
      expect(state.currentTab, MobileNavTab.tools);
    });

    test('copyWith returns new instance with updated values', () {
      const originalState = LibraryScreenState(
        sort: LibrarySort.titleAsc,
        viewMode: LibraryViewMode.list,
        filter: LibraryFilter.all,
        searchQuery: 'original',
        currentTab: MobileNavTab.home,
      );

      final updatedState = originalState.copyWith(
        sort: LibrarySort.authorAsc,
        filter: LibraryFilter.completed,
      );

      expect(updatedState.sort, LibrarySort.authorAsc);
      expect(updatedState.viewMode, LibraryViewMode.list);
      expect(updatedState.filter, LibraryFilter.completed);
      expect(updatedState.searchQuery, 'original');
      expect(updatedState.currentTab, MobileNavTab.home);
    });

    test('copyWith preserves original values when parameters are null', () {
      const originalState = LibraryScreenState(
        sort: LibrarySort.authorAsc,
        viewMode: LibraryViewMode.grid,
        filter: LibraryFilter.downloaded,
        searchQuery: 'test',
        currentTab: MobileNavTab.tools,
      );

      final copiedState = originalState.copyWith();

      expect(copiedState.sort, LibrarySort.authorAsc);
      expect(copiedState.viewMode, LibraryViewMode.grid);
      expect(copiedState.filter, LibraryFilter.downloaded);
      expect(copiedState.searchQuery, 'test');
      expect(copiedState.currentTab, MobileNavTab.tools);
    });

    test('copyWith updates all properties', () {
      const originalState = LibraryScreenState();

      final updatedState = originalState.copyWith(
        sort: LibrarySort.authorAsc,
        viewMode: LibraryViewMode.grid,
        filter: LibraryFilter.reading,
        searchQuery: 'new search',
        currentTab: MobileNavTab.write,
      );

      expect(updatedState.sort, LibrarySort.authorAsc);
      expect(updatedState.viewMode, LibraryViewMode.grid);
      expect(updatedState.filter, LibraryFilter.reading);
      expect(updatedState.searchQuery, 'new search');
      expect(updatedState.currentTab, MobileNavTab.write);
    });

    test('copyWith handles empty search query', () {
      const state = LibraryScreenState(searchQuery: 'test');

      final updated = state.copyWith(searchQuery: '');

      expect(updated.searchQuery, '');
    });

    test('copyWith handles null search query', () {
      const state = LibraryScreenState(searchQuery: 'test');

      final updated = state.copyWith(searchQuery: null);

      expect(updated.searchQuery, 'test');
    });

    test('copyWith maintains immutability', () {
      const originalState = LibraryScreenState(
        sort: LibrarySort.titleAsc,
        filter: LibraryFilter.all,
      );

      originalState.copyWith(sort: LibrarySort.authorAsc);

      expect(originalState.sort, LibrarySort.titleAsc);
    });

    test('multiple copyWith operations maintain independence', () {
      const state1 = LibraryScreenState(sort: LibrarySort.titleAsc);
      final state2 = state1.copyWith(filter: LibraryFilter.reading);
      final state3 = state2.copyWith(searchQuery: 'test');

      expect(state1.sort, LibrarySort.titleAsc);
      expect(state1.filter, LibraryFilter.all);
      expect(state1.searchQuery, '');

      expect(state2.sort, LibrarySort.titleAsc);
      expect(state2.filter, LibraryFilter.reading);
      expect(state2.searchQuery, '');

      expect(state3.sort, LibrarySort.titleAsc);
      expect(state3.filter, LibraryFilter.reading);
      expect(state3.searchQuery, 'test');
    });
  });

  group('LibrarySort enum', () {
    test('LibrarySort has two values', () {
      expect(LibrarySort.values.length, 2);
      expect(LibrarySort.values, contains(LibrarySort.titleAsc));
      expect(LibrarySort.values, contains(LibrarySort.authorAsc));
    });

    test('LibrarySort values are correct', () {
      expect(LibrarySort.titleAsc, isNotNull);
      expect(LibrarySort.authorAsc, isNotNull);
    });
  });

  group('LibraryFilter enum', () {
    test('LibraryFilter has four values', () {
      expect(LibraryFilter.values.length, 4);
      expect(LibraryFilter.values, contains(LibraryFilter.all));
      expect(LibraryFilter.values, contains(LibraryFilter.reading));
      expect(LibraryFilter.values, contains(LibraryFilter.completed));
      expect(LibraryFilter.values, contains(LibraryFilter.downloaded));
    });

    test('LibraryFilter values are correct', () {
      expect(LibraryFilter.all, isNotNull);
      expect(LibraryFilter.reading, isNotNull);
      expect(LibraryFilter.completed, isNotNull);
      expect(LibraryFilter.downloaded, isNotNull);
    });
  });

  group('LibraryViewMode enum', () {
    test('LibraryViewMode has two values', () {
      expect(LibraryViewMode.values.length, 2);
      expect(LibraryViewMode.values, contains(LibraryViewMode.list));
      expect(LibraryViewMode.values, contains(LibraryViewMode.grid));
    });
  });

  group('MobileNavTab enum', () {
    test('MobileNavTab has five values', () {
      expect(MobileNavTab.values.length, 5);
      expect(MobileNavTab.values, contains(MobileNavTab.home));
      expect(MobileNavTab.values, contains(MobileNavTab.write));
      expect(MobileNavTab.values, contains(MobileNavTab.read));
      expect(MobileNavTab.values, contains(MobileNavTab.tools));
      expect(MobileNavTab.values, contains(MobileNavTab.more));
    });
  });
}
