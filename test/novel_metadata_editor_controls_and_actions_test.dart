import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:writer/features/reader/novel_metadata_editor.dart';
import 'package:writer/models/novel.dart';
import 'package:writer/state/novel_providers.dart';
import 'package:writer/state/edit_permissions.dart';
import 'package:writer/repositories/novel_repository.dart';
import 'helpers/test_utils.dart';

class CapturingNovelRepository extends NovelRepository {
  CapturingNovelRepository()
    : super(
        SupabaseClient(
          'http://localhost',
          'anon',
          authOptions: const AuthClientOptions(autoRefreshToken: false),
        ),
      );
  Map<String, dynamic>? lastUpdate;
  String? lastAddedEmail;
  @override
  Future<Novel?> getNovel(String novelId) async {
    return const Novel(
      id: 'n-owner',
      title: 'Seed Title',
      author: 'Seed Author',
      description: 'Seed Desc',
      coverUrl: null,
      languageCode: 'en',
      isPublic: true,
    );
  }

  @override
  Future<void> updateNovelMetadata(
    String novelId, {
    String? title,
    String? description,
    String? coverUrl,
    String? languageCode,
    bool? isPublic,
  }) async {
    lastUpdate = {
      'novelId': novelId,
      'title': title,
      'description': description,
      'cover_url': coverUrl,
      'language_code': languageCode,
      'is_public': isPublic,
    };
  }

  @override
  Future<void> addContributorByEmail({
    required String novelId,
    required String email,
  }) async {
    lastAddedEmail = email;
  }
}

class ThrowingContributorRepo extends CapturingNovelRepository {
  @override
  Future<void> addContributorByEmail({
    required String novelId,
    required String email,
  }) async {
    throw Exception('boom');
  }
}

void main() {
  testWidgets('Owner role shows Public and Contributor controls', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final repo = CapturingNovelRepository();

    final scope = await buildAppScope(
      extraOverrides: [
        novelRepositoryProvider.overrideWith((ref) => repo),
        editRoleProvider.overrideWith((ref, id) async => EditRole.owner),
      ],
      child: materialAppFor(
        home: const Scaffold(body: NovelMetadataEditor(novelId: 'n-owner')),
        locale: const Locale('en'),
      ),
    );

    await tester.pumpWidget(scope);
    await tester.pumpAndSettle();

    expect(find.text('Public'), findsOneWidget);
    expect(
      find.widgetWithText(TextFormField, 'Contributor Email'),
      findsOneWidget,
    );
    expect(
      find.widgetWithText(OutlinedButton, 'Add Contributor'),
      findsOneWidget,
    );

    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Chinese'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.save));
    await tester.pumpAndSettle();
    expect(repo.lastUpdate, isNotNull);
    expect(repo.lastUpdate!['language_code'], equals('zh'));

    await tester.ensureVisible(find.widgetWithText(SwitchListTile, 'Public'));
    await tester.ensureVisible(find.widgetWithText(SwitchListTile, 'Public'));
  });

  testWidgets('Non-owner hides Public and Contributor controls', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final repo = CapturingNovelRepository();

    final scope = await buildAppScope(
      extraOverrides: [
        novelRepositoryProvider.overrideWith((ref) => repo),
        editRoleProvider.overrideWith((ref, id) async => EditRole.none),
      ],
      child: materialAppFor(
        home: const Scaffold(body: NovelMetadataEditor(novelId: 'n-owner')),
        locale: const Locale('en'),
      ),
    );

    await tester.pumpWidget(scope);
    await tester.pumpAndSettle();

    expect(find.text('Public'), findsNothing);
    expect(
      find.widgetWithText(TextFormField, 'Contributor Email'),
      findsNothing,
    );
    expect(
      find.widgetWithText(OutlinedButton, 'Add Contributor'),
      findsNothing,
    );
  });

  testWidgets('Add Contributor calls repo, shows snackbar, clears field', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final repo = CapturingNovelRepository();

    final scope = await buildAppScope(
      extraOverrides: [
        novelRepositoryProvider.overrideWith((ref) => repo),
        editRoleProvider.overrideWith((ref, id) async => EditRole.owner),
      ],
      child: materialAppFor(
        home: const Scaffold(body: NovelMetadataEditor(novelId: 'n-owner')),
        locale: const Locale('en'),
      ),
    );

    await tester.pumpWidget(scope);
    await tester.pumpAndSettle();

    final emailField = find.widgetWithText(TextFormField, 'Contributor Email');
    expect(emailField, findsOneWidget);
    await tester.enterText(emailField, 'user@example.com');
    await tester.pump();
    await tester.tap(find.widgetWithText(OutlinedButton, 'Add Contributor'));
    await tester.pumpAndSettle();

    expect(repo.lastAddedEmail, equals('user@example.com'));
    expect(find.text('Contributor added'), findsOneWidget);
    final tf = tester.widget<TextFormField>(emailField);
    expect(tf.controller?.text ?? '', equals(''));
  });

  testWidgets('Add Contributor error shows snackbar with message', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final repo = ThrowingContributorRepo();

    final scope = await buildAppScope(
      extraOverrides: [
        novelRepositoryProvider.overrideWith((ref) => repo),
        editRoleProvider.overrideWith((ref, id) async => EditRole.owner),
      ],
      child: materialAppFor(
        home: const Scaffold(body: NovelMetadataEditor(novelId: 'n-owner')),
        locale: const Locale('en'),
      ),
    );

    await tester.pumpWidget(scope);
    await tester.pumpAndSettle();

    final emailField = find.widgetWithText(TextFormField, 'Contributor Email');
    await tester.enterText(emailField, 'err@example.com');
    await tester.pump();
    await tester.tap(find.widgetWithText(OutlinedButton, 'Add Contributor'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Error:'), findsOneWidget);
  });
}
