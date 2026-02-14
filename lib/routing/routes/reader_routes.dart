import 'package:go_router/go_router.dart';

import 'package:writer/features/reader/reader_screen.dart';
import 'package:writer/features/reader/chapter_reader_screen.dart' as reader;

final readerRoutes = [
  GoRoute(
    path: '/novels/:id',
    name: 'novel',
    builder: (context, state) {
      final id = state.pathParameters['id'];
      return ReaderScreen(novelId: id!);
    },
  ),
  GoRoute(
    path: '/novels/:noveId/chapters/:chapterId',
    name: 'chapter',
    builder: (context, state) {
      final novelId = state.pathParameters['noveId'];
      final chapterId = state.pathParameters['chapterId'];
      return reader.ChapterReaderScreen(
        novelId: novelId!,
        chapterId: chapterId!,
        title: 'Chapter $chapterId',
      );
    },
  ),
];
