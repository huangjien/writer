import 'package:go_router/go_router.dart';

import 'package:writer/features/library/screens/library_screen.dart';

final libraryRoutes = [
  GoRoute(
    path: '/',
    name: 'library',
    builder: (context, state) => const LibraryScreen(),
  ),
];
