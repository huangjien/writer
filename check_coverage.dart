// ignore_for_file: avoid_print

import "dart:io";

String _normalizeFilePath(String sf) {
  final idx = sf.lastIndexOf('/writer/');
  if (idx >= 0) {
    return sf.substring(idx + '/writer/'.length);
  }
  return sf;
}

bool _isTrackedDartFile(String path) {
  if (!path.endsWith('.dart')) return false;
  if (path.contains('/.dart_tool/')) return false;
  if (!path.contains('lib/')) return false;
  return true;
}

double _parseThreshold(List<String> args) {
  if (args.isEmpty) return 85.0;
  final v = double.tryParse(args.first);
  return v ?? 85.0;
}

void main(List<String> args) {
  final threshold = _parseThreshold(args);
  final lines = File('coverage/lcov.info').readAsLinesSync();

  String? currentFile;
  int? lf;
  int? lh;
  int found = 0;
  int hit = 0;

  final below = <({String file, int lines, int hits, double pct})>[];

  void flush() {
    final file = currentFile;
    if (file == null) return;
    final normalized = _normalizeFilePath(file);
    if (!_isTrackedDartFile(normalized)) return;

    final totalLines = lf ?? found;
    final hitLines = lh ?? hit;
    if (totalLines <= 0) return;

    final pct = hitLines / totalLines * 100.0;
    if (pct < threshold) {
      below.add((file: normalized, lines: totalLines, hits: hitLines, pct: pct));
    }
  }

  for (final line in lines) {
    if (line.startsWith('SF:')) {
      currentFile = line.substring(3);
      lf = null;
      lh = null;
      found = 0;
      hit = 0;
      continue;
    }

    if (line.startsWith('LF:')) {
      lf = int.tryParse(line.substring(3));
      continue;
    }
    if (line.startsWith('LH:')) {
      lh = int.tryParse(line.substring(3));
      continue;
    }

    if (line.startsWith('DA:')) {
      final parts = line.substring(3).split(',');
      if (parts.length >= 2) {
        found++;
        final cnt = int.tryParse(parts[1]) ?? 0;
        if (cnt > 0) hit++;
      }
      continue;
    }

    if (line == 'end_of_record') {
      flush();
      currentFile = null;
      lf = null;
      lh = null;
      found = 0;
      hit = 0;
    }
  }

  below.sort((a, b) {
    final c = a.pct.compareTo(b.pct);
    if (c != 0) return c;
    return a.file.compareTo(b.file);
  });

  for (final r in below) {
    final pct = r.pct.toStringAsFixed(1).padLeft(5);
    final ratio = '${r.hits}/${r.lines}'.padLeft(9);
    print('$pct%  $ratio  ${r.file}');
  }
  print('Total below ${threshold.toStringAsFixed(1)}%: ${below.length}');
}
