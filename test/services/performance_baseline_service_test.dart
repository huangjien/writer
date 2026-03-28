import 'package:flutter_test/flutter_test.dart';
import 'package:writer/services/performance_baseline_service.dart';

void main() {
  group('PerformanceBaselineService', () {
    test('records measured operation duration', () async {
      final service = PerformanceBaselineService();

      final value = await service.measure(
        'library.load',
        () async => 7,
        tags: const {'online': 'true'},
      );

      expect(value, 7);
      final samples = service.samplesFor('library.load');
      expect(samples.length, 1);
      expect(samples.first.durationMs, greaterThanOrEqualTo(0));
      expect(samples.first.tags['online'], 'true');
    });

    test('keeps only configured max samples per metric', () {
      final service = PerformanceBaselineService(maxSamplesPerMetric: 2);

      service.record('reader.load', 5);
      service.record('reader.load', 6);
      service.record('reader.load', 7);

      final samples = service.samplesFor('reader.load');
      expect(samples.length, 2);
      expect(samples.first.durationMs, 6);
      expect(samples.last.durationMs, 7);
    });

    test('returns empty list for unknown metric', () {
      final service = PerformanceBaselineService();
      expect(service.samplesFor('unknown'), isEmpty);
    });

    test('snapshot returns all metrics and samples', () {
      final service = PerformanceBaselineService();
      service.record('a', 1);
      service.record('b', 2);

      final snap = service.snapshot();
      expect(snap.containsKey('a'), isTrue);
      expect(snap.containsKey('b'), isTrue);
      expect(snap['a']!.length, 1);
      expect(snap['a']!.first.durationMs, 1);
      // Verify snapshot list is unmodifiable
      try {
        (snap['a'] as List).add(42);
        fail('Should throw');
      } catch (_) {}
    });

    test('clear removes all samples', () {
      final service = PerformanceBaselineService();
      service.record('a', 1);
      service.record('b', 2);
      service.clear();
      expect(service.samplesFor('a'), isEmpty);
      expect(service.snapshot(), isEmpty);
    });

    test('snapshot is empty when no samples recorded', () {
      final service = PerformanceBaselineService();
      expect(service.snapshot(), isEmpty);
    });

    test('measure rethrows error but still records duration', () async {
      final service = PerformanceBaselineService();
      await expectLater(
        () => service.measure('fail', () async => throw Exception('boom')),
        throwsA(isA<Exception>()),
      );
      expect(service.samplesFor('fail').length, 1);
    });

    test('record with default tags stores empty map', () {
      final service = PerformanceBaselineService();
      service.record('test', 10);
      expect(service.samplesFor('test').first.tags, isEmpty);
    });
  });
}
