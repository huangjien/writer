import './user_progress.dart';
import './novel.dart';
import './chapter.dart';

class RecentProgressDetails {
  final UserProgress userProgress;
  final Novel novel;
  final Chapter chapter;

  RecentProgressDetails({
    required this.userProgress,
    required this.novel,
    required this.chapter,
  });
}
