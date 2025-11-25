import 'package:flutter_test/flutter_test.dart';
import 'package:writer/models/recent_progress_details.dart';
import 'package:writer/models/user_progress.dart';
import 'package:writer/models/novel.dart';
import 'package:writer/models/chapter.dart';

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
