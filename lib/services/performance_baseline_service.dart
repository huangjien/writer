import 'dart:collection';

class BaselineMetricSample {
  const BaselineMetricSample({
    required this.metric,
    required this.durationMs,
    required this.recordedAt,
    required this.tags,
  });

  final String metric;
  final int durationMs;
  final DateTime recordedAt;
  final Map<String, String> tags;
}

class PerformanceBaselineService {
  PerformanceBaselineService({this.maxSamplesPerMetric = 120});

  final int maxSamplesPerMetric;
  final Map<String, ListQueue<BaselineMetricSample>> _samplesByMetric = {};

  Future<T> measure<T>(
    String metric,
    Future<T> Function() operation, {
    Map<String, String> tags = const {},
  }) async {
    final stopwatch = Stopwatch()..start();
    try {
      return await operation();
    } finally {
      stopwatch.stop();
      record(metric, stopwatch.elapsedMilliseconds, tags: tags);
    }
  }

  void record(
    String metric,
    int durationMs, {
    Map<String, String> tags = const {},
  }) {
    final queue = _samplesByMetric.putIfAbsent(metric, ListQueue.new);
    queue.add(
      BaselineMetricSample(
        metric: metric,
        durationMs: durationMs,
        recordedAt: DateTime.now(),
        tags: Map<String, String>.unmodifiable(tags),
      ),
    );
    while (queue.length > maxSamplesPerMetric) {
      queue.removeFirst();
    }
  }

  List<BaselineMetricSample> samplesFor(String metric) {
    final queue = _samplesByMetric[metric];
    if (queue == null) {
      return const [];
    }
    return List<BaselineMetricSample>.unmodifiable(queue);
  }

  Map<String, List<BaselineMetricSample>> snapshot() {
    return Map<String, List<BaselineMetricSample>>.unmodifiable(
      _samplesByMetric.map(
        (key, value) =>
            MapEntry(key, List<BaselineMetricSample>.unmodifiable(value)),
      ),
    );
  }

  void clear() {
    _samplesByMetric.clear();
  }
}
