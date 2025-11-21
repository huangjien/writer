import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novel_reader/widgets/side_bar.dart';
import 'package:novel_reader/state/novel_providers.dart';
import 'package:novel_reader/state/edit_permissions.dart';
import 'package:novel_reader/models/novel.dart';

void main() {
  testWidgets('SideBar renders navigation items and novel title', (
    tester,
  ) async {
    final sampleNovel = Novel(
      id: 'novel-1',
      title: 'Sample Novel',
      author: 'Author',
      description: 'Desc',
      coverUrl: null,
      languageCode: 'en',
      isPublic: true,
    );

    final container = ProviderContainer(
      overrides: [
        novelProvider.overrideWith(
          (ref, id) async => id == 'novel-1' ? sampleNovel : null,
        ),
        editRoleProvider.overrideWith((ref, id) async => EditRole.owner),
      ],
    );
    addTearDown(container.dispose);

    // Sanity-check provider override resolves to owner.
    final role = await container.read(editRoleProvider('novel-1').future);
    expect(role, EditRole.owner);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(body: SideBar(novelId: 'novel-1')),
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
    expect(find.text('Character Templates'), findsOneWidget);
    expect(find.text('Scene Templates'), findsOneWidget);
    // Owner actions are gated by permissions and verified separately.
  });
}
