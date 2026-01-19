// ignore_for_file: avoid_print

import "dart:io";

String _normalizeFilePath(String sf) {
  final idx = sf.lastIndexOf('/writer/');
  if (idx >= 0) {
    return sf.substring(idx + '/writer/'.length);
  }
  return sf;
}

double _parseThreshold(List<String> args) {
  if (args.isEmpty) return 90.0;
  final v = double.tryParse(args.first);
  return v ?? 90.0;
}

const _targets = <String>{
  'lib/repositories/chapter_repository.dart',
  'lib/repositories/local_storage_repository.dart',
  'lib/repositories/remote_repository.dart',
  'lib/services/offline_queue_service.dart',
  'lib/services/sync_service.dart',
  'lib/shared/api_exception.dart',
  'lib/state/sync_service_provider.dart',
};

void main(List<String> args) {
  final threshold = _parseThreshold(args);
  final lines = File('coverage/lcov.info').readAsLinesSync();

  String? currentFile;
  int? lf;
  int? lh;
  int found = 0;
  int hit = 0;

  final seen = <String, ({int lines, int hits, double pct})>{};

  void flush() {
    final file = currentFile;
    if (file == null) return;
    final normalized = _normalizeFilePath(file);
    if (!_targets.contains(normalized)) return;

    final totalLines = lf ?? found;
    final hitLines = lh ?? hit;
    if (totalLines <= 0) return;

    final pct = hitLines / totalLines * 100.0;
    seen[normalized] = (lines: totalLines, hits: hitLines, pct: pct);
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

  final missing = _targets.difference(seen.keys.toSet());
  if (missing.isNotEmpty) {
    for (final f in missing.toList()..sort()) {
      print('  0.0%      0/0  $f');
    }
    stderr.writeln(
      'Missing coverage records for ${missing.length} target files',
    );
    exit(1);
  }

  final below = <String>[];
  final ordered = seen.entries.toList()..sort((a, b) => a.key.compareTo(b.key));

  for (final e in ordered) {
    final r = e.value;
    final pct = r.pct.toStringAsFixed(1).padLeft(5);
    final ratio = '${r.hits}/${r.lines}'.padLeft(9);
    print('$pct%  $ratio  ${e.key}');
    if (r.pct < threshold) below.add(e.key);
  }

  if (below.isNotEmpty) {
    stderr.writeln(
      'Targeted coverage below ${threshold.toStringAsFixed(1)}%: ${below.length}',
    );
    exit(1);
  }
}
