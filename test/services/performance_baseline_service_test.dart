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
  });
}
