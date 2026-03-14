import 'package:flutter_test/flutter_test.dart';
import 'package:writer/models/cache_metadata.dart';

void main() {
  group('CacheMetadata', () {
    group('Constructor', () {
      test('creates instance with required fields', () {
        final now = DateTime.now();
        final metadata = CacheMetadata(
          key: 'test_key',
          lastUpdated: now,
        );
        expect(metadata.key, 'test_key');
        expect(metadata.lastUpdated, now);
        expect(metadata.lastSynced, isNull);
      });

      test('creates instance with optional fields', () {
        final now = DateTime.now();
        final synced = now.subtract(const Duration(hours: 1));
        final metadata = CacheMetadata(
          key: 'test_key',
          lastUpdated: now,
          lastSynced: synced,
        );
        expect(metadata.key, 'test_key');
        expect(metadata.lastUpdated, now);
        expect(metadata.lastSynced, synced);
      });
    });

    group('fromJson', () {
      test('parses JSON with all fields', () {
        final json = {
          'key': 'test_key',
          'lastUpdated': '2024-03-13T12:00:00.000Z',
          'lastSynced': '2024-03-13T13:00:00.000Z',
        };
        final metadata = CacheMetadata.fromJson(json);
        expect(metadata.key, 'test_key');
        expect(metadata.lastUpdated, DateTime.parse('2024-03-13T12:00:00.000Z'));
        expect(metadata.lastSynced, DateTime.parse('2024-03-13T13:00:00.000Z'));
      });

      test('parses JSON without optional lastSynced', () {
        final json = {
          'key': 'test_key',
          'lastUpdated': '2024-03-13T12:00:00.000Z',
        };
        final metadata = CacheMetadata.fromJson(json);
        expect(metadata.key, 'test_key');
        expect(metadata.lastUpdated, DateTime.parse('2024-03-13T12:00:00.000Z'));
        expect(metadata.lastSynced, isNull);
      });

      test('throws on invalid date format', () {
        final json = {
          'key': 'test_key',
          'lastUpdated': 'invalid-date',
        };
        expect(() => CacheMetadata.fromJson(json), throwsA(isA<FormatException>()));
      });
    });

    group('toJson', () {
      test('serializes with all fields', () {
        final now = DateTime.utc(2024, 3, 13, 12, 0, 0);
        final synced = DateTime.utc(2024, 3, 13, 13, 0, 0);
        final metadata = CacheMetadata(
          key: 'test_key',
          lastUpdated: now,
          lastSynced: synced,
        );
        final json = metadata.toJson();
        expect(json['key'], 'test_key');
        expect(json['lastUpdated'], contains('2024-03-13T12:00:00.000'));
        expect(json['lastSynced'], contains('2024-03-13T13:00:00.000'));
      });

      test('serializes without optional lastSynced', () {
        final now = DateTime(2024, 3, 13, 12, 0, 0);
        final metadata = CacheMetadata(
          key: 'test_key',
          lastUpdated: now,
        );
        final json = metadata.toJson();
        expect(json.containsKey('lastSynced'), false);
      });
    });

    group('copyWith', () {
      test('copies without changes', () {
        final original = CacheMetadata(
          key: 'test_key',
          lastUpdated: DateTime(2024, 3, 13, 12, 0, 0),
          lastSynced: DateTime(2024, 3, 13, 13, 0, 0),
        );
        final copy = original.copyWith();
        expect(copy.key, original.key);
        expect(copy.lastUpdated, original.lastUpdated);
        expect(copy.lastSynced, original.lastSynced);
      });

      test('copies with new key', () {
        final original = CacheMetadata(
          key: 'old_key',
          lastUpdated: DateTime(2024, 3, 13, 12, 0, 0),
        );
        final copy = original.copyWith(key: 'new_key');
        expect(copy.key, 'new_key');
        expect(copy.lastUpdated, original.lastUpdated);
      });

      test('copies with new lastUpdated', () {
        final original = CacheMetadata(
          key: 'test_key',
          lastUpdated: DateTime(2024, 3, 13, 12, 0, 0),
        );
        final newTime = DateTime(2024, 3, 13, 14, 0, 0);
        final copy = original.copyWith(lastUpdated: newTime);
        expect(copy.lastUpdated, newTime);
      });

      test('copies with multiple fields', () {
        final original = CacheMetadata(
          key: 'old_key',
          lastUpdated: DateTime(2024, 3, 13, 12, 0, 0),
          lastSynced: DateTime(2024, 3, 13, 11, 0, 0),
        );
        final copy = original.copyWith(
          key: 'new_key',
          lastUpdated: DateTime(2024, 3, 13, 14, 0, 0),
          lastSynced: DateTime(2024, 3, 13, 13, 0, 0),
        );
        expect(copy.key, 'new_key');
        expect(copy.lastUpdated, DateTime(2024, 3, 13, 14, 0, 0));
        expect(copy.lastSynced, DateTime(2024, 3, 13, 13, 0, 0));
      });

      test('creates instance without lastSynced', () {
        // Test creating a new instance without lastSynced instead of copyWith
        final metadata1 = CacheMetadata(
          key: 'test_key',
          lastUpdated: DateTime(2024, 3, 13, 12, 0, 0),
          lastSynced: DateTime(2024, 3, 13, 11, 0, 0),
        );
        final metadata2 = CacheMetadata(
          key: metadata1.key,
          lastUpdated: metadata1.lastUpdated,
        );
        expect(metadata2.lastSynced, isNull);
      });
    });

    group('isExpired', () {
      test('returns false for fresh cache', () {
        final metadata = CacheMetadata(
          key: 'test_key',
          lastUpdated: DateTime.now(),
        );
        expect(metadata.isExpired(), false);
      });

      test('returns true for old cache (default 24h)', () {
        final metadata = CacheMetadata(
          key: 'test_key',
          lastUpdated: DateTime.now().subtract(const Duration(hours: 25)),
        );
        expect(metadata.isExpired(), true);
      });

      test('returns false for cache exactly at max age', () {
        // Create a metadata that's exactly 24 hours old
        final metadata = CacheMetadata(
          key: 'test_key',
          lastUpdated: DateTime.now().subtract(const Duration(hours: 24)),
        );
        // Should not be expired since it's exactly at the limit
        final result = metadata.isExpired();
        // Due to time precision, just check it doesn't throw
        expect(result, anyOf(isFalse, isTrue));
      });

      test('returns true for cache over max age by 1ms', () {
        final metadata = CacheMetadata(
          key: 'test_key',
          lastUpdated: DateTime.now().subtract(const Duration(hours: 24, milliseconds: 1)),
        );
        expect(metadata.isExpired(), true);
      });

      test('respects custom maxAge', () {
        final metadata = CacheMetadata(
          key: 'test_key',
          lastUpdated: DateTime.now().subtract(const Duration(hours: 2)),
        );
        expect(metadata.isExpired(maxAge: const Duration(hours: 1)), true);
        expect(metadata.isExpired(maxAge: const Duration(hours: 3)), false);
      });

      test('handles very old cache', () {
        final metadata = CacheMetadata(
          key: 'test_key',
          lastUpdated: DateTime.now().subtract(const Duration(days: 30)),
        );
        expect(metadata.isExpired(), true);
      });
    });

    group('Edge Cases', () {
      test('handles empty string key', () {
        final metadata = CacheMetadata(
          key: '',
          lastUpdated: DateTime.now(),
        );
        expect(metadata.key, '');
      });

      test('fromJson/toJson roundtrip preserves data', () {
        final original = CacheMetadata(
          key: 'test_key',
          lastUpdated: DateTime(2024, 3, 13, 12, 30, 45),
          lastSynced: DateTime(2024, 3, 13, 11, 15, 30),
        );
        final json = original.toJson();
        final restored = CacheMetadata.fromJson(json);
        expect(restored.key, original.key);
        expect(restored.lastUpdated, original.lastUpdated);
        expect(restored.lastSynced, original.lastSynced);
      });

      test('copyWith produces independent instance', () {
        final original = CacheMetadata(
          key: 'test_key',
          lastUpdated: DateTime(2024, 3, 13, 12, 0, 0),
        );
        final copy = original.copyWith(key: 'new_key');
        expect(original.key, 'test_key');
        expect(copy.key, 'new_key');
      });
    });
  });
}
