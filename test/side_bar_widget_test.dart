import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:writer/widgets/side_bar.dart';
import 'package:writer/state/novel_providers.dart';
import 'package:writer/state/edit_permissions.dart';
import 'package:writer/features/reader/novel_metadata_editor.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/models/novel.dart';
import 'package:writer/repositories/novel_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockNovelRepository extends Mock implements NovelRepository {}

void main() {
  const sampleNovel = Novel(
    id: 'novel-1',
    title: 'Sample Novel',
    author: 'Author',
    description: 'Desc',
    coverUrl: null,
    languageCode: 'en',
    isPublic: true,
  );

  GoRouter createRouter() {
    return GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) =>
              const Scaffold(body: SideBar(novelId: 'novel-1')),
        ),
        GoRoute(
          path: '/home',
          name: 'home',
          builder: (context, state) =>
              const Scaffold(body: Text('Home Screen')),
        ),
        GoRoute(
          path: '/library',
          name: 'library',
          builder: (context, state) =>
              const Scaffold(body: Text('Library Screen')),
        ),
      ],
    );
  }

  GoRouter createDrawerRouter({required bool includeEditRoute}) {
    return GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            appBar: AppBar(),
            drawer: const SideBar(novelId: 'novel-1'),
            body: const Text('Root Screen'),
          ),
        ),
        GoRoute(
          path: '/library',
          name: 'library',
          builder: (context, state) =>
              const Scaffold(body: Text('Library Screen')),
        ),
        if (includeEditRoute)
          GoRoute(
            path: '/novel/:id/edit',
            name: 'editNovel',
            builder: (context, state) =>
                const Scaffold(body: Text('Edit Screen')),
          ),
      ],
    );
  }

  testWidgets('SideBar renders navigation items and novel title (owner)', (
    tester,
  ) async {
    final mockNovelRepository = MockNovelRepository();
    final container = ProviderContainer(
      overrides: [
        novelProvider.overrideWith(
          (ref, id) async => id == 'novel-1' ? sampleNovel : null,
        ),
        editRoleProvider.overrideWith((ref, id) async => EditRole.owner),
        novelRepositoryProvider.overrideWithValue(mockNovelRepository),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          routerConfig: createRouter(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sample Novel'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Chapter Index'), findsOneWidget);
    expect(find.text('Summary'), findsOneWidget);
    expect(find.text('Characters'), findsOneWidget);
    expect(find.text('Scenes'), findsOneWidget);
    expect(find.text('Character Templates'), findsNothing);
    expect(find.text('Scene Templates'), findsNothing);
    // Owner actions
    // Scroll to bottom to ensure actions are visible
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();

    expect(find.text('Update Novel'), findsOneWidget);
    expect(find.text('Delete Novel'), findsOneWidget);
  });

  testWidgets('SideBar hides update/delete for viewer', (tester) async {
    final container = ProviderContainer(
      overrides: [
        novelProvider.overrideWith(
          (ref, id) async => id == 'novel-1' ? sampleNovel : null,
        ),
        editRoleProvider.overrideWith((ref, id) async => EditRole.contributor),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          routerConfig: createRouter(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sample Novel'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);

    // Scroll to bottom just in case
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();

    expect(find.text('Update Novel'), findsNothing);
    expect(find.text('Delete Novel'), findsNothing);
  });

  testWidgets('Delete Novel shows confirmation dialog', (tester) async {
    final mockNovelRepository = MockNovelRepository();
    when(() => mockNovelRepository.deleteNovel(any())).thenAnswer((_) async {});

    final container = ProviderContainer(
      overrides: [
        novelProvider.overrideWith(
          (ref, id) async => id == 'novel-1' ? sampleNovel : null,
        ),
        editRoleProvider.overrideWith((ref, id) async => EditRole.owner),
        novelRepositoryProvider.overrideWithValue(mockNovelRepository),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          routerConfig: createRouter(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Scroll to ensure Delete Novel is visible
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();

    // Tap Delete Novel
    await tester.tap(find.text('Delete Novel'));
    await tester.pumpAndSettle();

    // Verify dialog
    expect(find.text('Delete'), findsOneWidget); // Button
    expect(find.text('Cancel'), findsOneWidget); // Button

    // Tap Cancel
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    verifyNever(() => mockNovelRepository.deleteNovel(any()));

    // Tap Delete again
    await tester.tap(find.text('Delete Novel'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    verify(() => mockNovelRepository.deleteNovel('novel-1')).called(1);
  });

  testWidgets('Update Novel falls back when edit route is missing', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        novelProvider.overrideWith(
          (ref, id) async => id == 'novel-1' ? sampleNovel : null,
        ),
        editRoleProvider.overrideWith((ref, id) async => EditRole.owner),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          routerConfig: createDrawerRouter(includeEditRoute: false),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();

    tester.state<ScaffoldState>(find.byType(Scaffold).first).openDrawer();
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Update Novel'));
    await tester.pumpAndSettle();

    expect(find.byType(NovelMetadataEditor), findsOneWidget);
  });

  testWidgets('Delete Novel navigates to library on confirm', (tester) async {
    final mockNovelRepository = MockNovelRepository();
    when(() => mockNovelRepository.deleteNovel(any())).thenAnswer((_) async {});

    final container = ProviderContainer(
      overrides: [
        novelProvider.overrideWith(
          (ref, id) async => id == 'novel-1' ? sampleNovel : null,
        ),
        editRoleProvider.overrideWith((ref, id) async => EditRole.owner),
        novelRepositoryProvider.overrideWithValue(mockNovelRepository),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          routerConfig: createDrawerRouter(includeEditRoute: true),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();

    tester.state<ScaffoldState>(find.byType(Scaffold).first).openDrawer();
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Delete Novel'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    verify(() => mockNovelRepository.deleteNovel('novel-1')).called(1);
    expect(find.text('Library Screen'), findsOneWidget);
  });
}
