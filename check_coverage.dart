// ignore_for_file: avoid_print

import "dart:io";
void main() {
  final lines = File("coverage/lcov.info").readAsLinesSync();
  String? currentFile;
  int found = 0;
  int hit = 0;
  List<int> missedLines = [];
  for (final line in lines) {
    if (line.startsWith("SF:")) {
      currentFile = line.substring(3);
    } else if (line.startsWith("DA:")) {
      if (currentFile != null && currentFile.endsWith("chapter_reader_screen.dart")) {
        found++;
        if (!line.endsWith(",0")) {
          hit++;
        } else {
          final parts = line.substring(3).split(",");
          missedLines.add(int.parse(parts[0]));
        }
      }
    }
  }
  if (found > 0) {
    print("File: chapter_reader_screen.dart");
    print("Lines: $found");
    print("Hit: $hit");
    print("Coverage: ${(hit / found * 100).toStringAsFixed(1)}%");
    print("Missed lines: ${missedLines.join(', ')}");
  } else {
    print("File not found in coverage");
  }
}
