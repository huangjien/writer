import 'package:flutter_test/flutter_test.dart';
import 'package:novel_reader/models/recent_progress_details.dart';
import 'package:novel_reader/models/user_progress.dart';
import 'package:novel_reader/models/novel.dart';
import 'package:novel_reader/models/chapter.dart';

void main() {
  test('RecentProgressDetails holds references', () {
    const n = Novel(
      id: 'n',
      title: 'T',
      author: null,
      description: null,
      coverUrl: null,
      languageCode: 'en',
      isPublic: true,
    );
    const c = Chapter(
      id: 'c',
      novelId: 'n',
      idx: 1,
      title: 'CT',
      content: 'Body',
    );
    final p = UserProgress(
      userId: 'u',
      novelId: 'n',
      chapterId: 'c',
      scrollOffset: 0,
      ttsCharIndex: 0,
      updatedAt: DateTime.now(),
    );
    final d = RecentProgressDetails(userProgress: p, novel: n, chapter: c);
    expect(d.userProgress.chapterId, 'c');
    expect(d.novel.id, 'n');
    expect(d.chapter.idx, 1);
  });
}
