// ignore_for_file: avoid_print
import 'dart:io';

void main() async {
  final file = File('coverage/lcov.info');
  if (!await file.exists()) {
    print('coverage/lcov.info not found');
    return;
  }

  final lines = await file.readAsLines();
  final files = <String, Map<String, int>>{};
  String? currentFile;

  for (final line in lines) {
    if (line.startsWith('SF:')) {
      currentFile = line.substring(3);
      files[currentFile] = {'lines': 0, 'hit': 0};
    } else if (line.startsWith('DA:') && currentFile != null) {
      final parts = line.substring(3).split(',');
      final hits = int.parse(parts[1]);
      files[currentFile]!['lines'] = files[currentFile]!['lines']! + 1;
      if (hits > 0) {
        files[currentFile]!['hit'] = files[currentFile]!['hit']! + 1;
      }
    }
  }

  print('Files with coverage < 85%:');
  print('--------------------------------------------------');
  
  final sortedFiles = files.entries.toList()
    ..sort((a, b) {
      final coverageA = a.value['lines']! == 0 ? 0.0 : a.value['hit']! / a.value['lines']!;
      final coverageB = b.value['lines']! == 0 ? 0.0 : b.value['hit']! / b.value['lines']!;
      return coverageA.compareTo(coverageB);
    });

  for (final entry in sortedFiles) {
    final total = entry.value['lines']!;
    final hit = entry.value['hit']!;
    final percentage = total == 0 ? 0.0 : (hit / total) * 100;
    
    // Filter out generated files or files that shouldn't be tested if necessary
    if (percentage < 85.0 && !entry.key.endsWith('.g.dart') && !entry.key.endsWith('.freezed.dart')) {
      print('${percentage.toStringAsFixed(1)}% ($hit/$total) - ${entry.key}');
    }
  }
}
