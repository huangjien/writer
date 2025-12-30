import 'package:flutter_test/flutter_test.dart';
import 'package:writer/models/user.dart';

void main() {
  group('User model', () {
    const testId = 'user-123';
    const testEmail = 'test@example.com';

    test('creates user with required properties', () {
      final user = User(id: testId);

      expect(user.id, equals(testId));
      expect(user.email, isNull);
      expect(user.isApproved, isFalse);
      expect(user.isAdmin, isFalse);
    });

    test('creates user with all properties', () {
      final user = User(
        id: testId,
        email: testEmail,
        isApproved: true,
        isAdmin: true,
      );

      expect(user.id, equals(testId));
      expect(user.email, equals(testEmail));
      expect(user.isApproved, isTrue);
      expect(user.isAdmin, isTrue);
    });

    test('fromJson creates user from complete JSON', () {
      final json = {
        'id': testId,
        'email': testEmail,
        'is_approved': true,
        'is_admin': false,
      };

      final user = User.fromJson(json);

      expect(user.id, equals(testId));
      expect(user.email, equals(testEmail));
      expect(user.isApproved, isTrue);
      expect(user.isAdmin, isFalse);
    });

    test('fromJson creates user from minimal JSON', () {
      final json = {'id': testId};

      final user = User.fromJson(json);

      expect(user.id, equals(testId));
      expect(user.email, isNull);
      expect(user.isApproved, isFalse);
      expect(user.isAdmin, isFalse);
    });

    test('fromJson handles null values in JSON', () {
      final json = {
        'id': testId,
        'email': null,
        'is_approved': null,
        'is_admin': null,
      };

      final user = User.fromJson(json);

      expect(user.id, equals(testId));
      expect(user.email, isNull);
      expect(user.isApproved, isFalse);
      expect(user.isAdmin, isFalse);
    });

    test('toJson converts user to JSON', () {
      final user = User(
        id: testId,
        email: testEmail,
        isApproved: true,
        isAdmin: false,
      );

      final json = user.toJson();

      expect(json['id'], equals(testId));
      expect(json['email'], equals(testEmail));
      expect(json['is_approved'], isTrue);
      expect(json['is_admin'], isFalse);
    });

    test('toJson handles null email', () {
      final user = User(id: testId);

      final json = user.toJson();

      expect(json['id'], equals(testId));
      expect(json['email'], isNull);
      expect(json['is_approved'], isFalse);
      expect(json['is_admin'], isFalse);
    });

    test('copyWith creates new user with updated properties', () {
      final original = User(
        id: testId,
        email: testEmail,
        isApproved: false,
        isAdmin: false,
      );

      final updated = original.copyWith(
        email: 'new@example.com',
        isApproved: true,
      );

      expect(updated.id, equals(testId)); // unchanged
      expect(updated.email, equals('new@example.com')); // changed
      expect(updated.isApproved, isTrue); // changed
      expect(updated.isAdmin, isFalse); // unchanged
    });

    test('copyWith preserves all properties when no arguments provided', () {
      final original = User(
        id: testId,
        email: testEmail,
        isApproved: true,
        isAdmin: true,
      );

      final copied = original.copyWith();

      expect(copied.id, equals(original.id));
      expect(copied.email, equals(original.email));
      expect(copied.isApproved, equals(original.isApproved));
      expect(copied.isAdmin, equals(original.isAdmin));
    });

    test('copyWith can update all properties', () {
      final original = User(
        id: testId,
        email: testEmail,
        isApproved: false,
        isAdmin: false,
      );

      final updated = original.copyWith(
        id: 'new-id',
        email: 'new@example.com',
        isApproved: true,
        isAdmin: true,
      );

      expect(updated.id, equals('new-id'));
      expect(updated.email, equals('new@example.com'));
      expect(updated.isApproved, isTrue);
      expect(updated.isAdmin, isTrue);
    });
  });
}
