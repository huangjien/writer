import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:writer/features/library/widgets/library_grid_item.dart';
import 'package:writer/features/reader/reader_screen.dart';
import 'package:writer/models/novel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const novel = Novel(
    id: '123',
    title: 'Test Novel',
    languageCode: 'en',
    isPublic: false,
  );

  const novelWithAuthor = Novel(
    id: '124',
    title: 'Novel With Author',
    author: 'Test Author',
    languageCode: 'en',
    isPublic: false,
  );

  testWidgets('LibraryGridItem renders title and gradient when no cover', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: LibraryGridItem(
              novel: novel,
              isSignedIn: true,
              canRemove: true,
              canDownload: true,
            ),
          ),
        ),
      ),
    );

    // The title appears twice:
    // 1. On the gradient cover (placeholder for missing image)
    // 2. Below the cover in the card details
    expect(find.text('Test Novel'), findsNWidgets(2));
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('LibraryGridItem renders image when coverUrl is present', (
    tester,
  ) async {
    const novelWithCover = Novel(
      id: '124',
      title: 'Cover Novel',
      coverUrl: 'https://example.com/cover.jpg',
      languageCode: 'en',
      isPublic: false,
    );

    await HttpOverrides.runZoned(() async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: LibraryGridItem(
                novel: novelWithCover,
                isSignedIn: true,
                canRemove: true,
                canDownload: true,
              ),
            ),
          ),
        ),
      );
    }, createHttpClient: (_) => _MockHttpClient());

    // It should find an Image widget (Image.network creates an Image widget)
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('LibraryGridItem navigates to novel details on tap', (
    tester,
  ) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(
            body: LibraryGridItem(
              novel: novel,
              isSignedIn: true,
              canRemove: true,
              canDownload: true,
            ),
          ),
        ),
        GoRoute(
          path: '/novel/:id',
          builder: (context, state) =>
              Scaffold(body: Text('Details for ${state.pathParameters['id']}')),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(child: MaterialApp.router(routerConfig: router)),
    );

    await tester.tap(find.byType(LibraryGridItem));
    await tester.pumpAndSettle();

    expect(find.text('Details for 123'), findsOneWidget);
  });

  testWidgets('LibraryGridItem renders author when present', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: LibraryGridItem(
              novel: novelWithAuthor,
              isSignedIn: true,
              canRemove: true,
              canDownload: true,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Test Author'), findsOneWidget);
  });

  testWidgets('LibraryGridItem shows progress indicator', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: LibraryGridItem(
              novel: novel,
              isSignedIn: true,
              canRemove: true,
              canDownload: true,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Not started'), findsOneWidget);
  });

  testWidgets(
    'LibraryGridItem does not show menu button when canRemove is false',
    (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: LibraryGridItem(
                novel: novel,
                isSignedIn: true,
                canRemove: false,
                canDownload: true,
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.more_vert), findsNothing);
    },
  );

  testWidgets('LibraryGridItem handles image loading error', (tester) async {
    const novelWithBadCover = Novel(
      id: '125',
      title: 'Bad Cover Novel',
      coverUrl: 'https://example.com/bad-cover.jpg',
      languageCode: 'en',
      isPublic: false,
    );

    await HttpOverrides.runZoned(() async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: LibraryGridItem(
                novel: novelWithBadCover,
                isSignedIn: true,
                canRemove: false,
                canDownload: true,
              ),
            ),
          ),
        ),
      );
    }, createHttpClient: (_) => _MockErrorHttpClient());

    expect(find.text('Bad Cover Novel'), findsOneWidget);
  });

  testWidgets('LibraryGridItem navigation works without GoRouter', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: LibraryGridItem(
              novel: novel,
              isSignedIn: true,
              canRemove: false,
              canDownload: true,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(LibraryGridItem));
    await tester.pumpAndSettle();

    expect(find.byType(ReaderScreen), findsOneWidget);
  });
}

class _MockErrorHttpClient extends Fake implements HttpClient {
  @override
  Future<HttpClientRequest> getUrl(Uri url) async {
    return _MockErrorHttpClientRequest();
  }
}

class _MockErrorHttpClientRequest extends Fake implements HttpClientRequest {
  @override
  Future<HttpClientResponse> close() async {
    return _MockErrorHttpClientResponse();
  }
}

class _MockErrorHttpClientResponse extends Fake implements HttpClientResponse {
  @override
  int get statusCode => 404;

  @override
  int get contentLength => 0;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.value([]).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}

class _MockHttpClient extends Fake implements HttpClient {
  @override
  Future<HttpClientRequest> getUrl(Uri url) async {
    return _MockHttpClientRequest();
  }
}

class _MockHttpClientRequest extends Fake implements HttpClientRequest {
  @override
  Future<HttpClientResponse> close() async {
    return _MockHttpClientResponse();
  }
}

class _MockHttpClientResponse extends Fake implements HttpClientResponse {
  @override
  int get statusCode => 200;

  @override
  int get contentLength => 0;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.value([]).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}
