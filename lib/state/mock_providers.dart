import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/novel.dart';
import '../models/chapter.dart';
import '../models/user_progress.dart';

// Simple in-memory mock data for offline development.

final _mockNovels = <Novel>[
  const Novel(
    id: 'novel-001',
    title: 'The Whispering Forest',
    author: 'A. Storyteller',
    description: 'A gentle adventure through a mysterious forest.',
    coverUrl: null,
    languageCode: 'en',
    isPublic: true,
  ),
  const Novel(
    id: 'novel-002',
    title: 'Stars Above, Seas Below',
    author: 'M. Voyager',
    description: 'Exploring the cosmos and the depths of the ocean.',
    coverUrl: null,
    languageCode: 'en',
    isPublic: true,
  ),
  const Novel(
    id: 'novel-003',
    title: 'Quiet City Nights',
    author: 'L. Dreamer',
    description: 'Slice-of-life stories set in a peaceful city.',
    coverUrl: null,
    languageCode: 'en',
    isPublic: true,
  ),
];

final _mockChaptersByNovel = <String, List<Chapter>>{
  'novel-001': [
    const Chapter(
      id: 'chap-001-01',
      novelId: 'novel-001',
      idx: 1,
      title: 'Into the Woods',
      content:
          'The forest whispered secrets as the traveler stepped beneath its canopy...',
    ),
    const Chapter(
      id: 'chap-001-02',
      novelId: 'novel-001',
      idx: 2,
      title: 'Hidden Creek',
      content:
          'Veiled by ferns, a creek murmured softly, guiding the way forward...',
    ),
  ],
  'novel-002': [
    const Chapter(
      id: 'chap-002-01',
      novelId: 'novel-002',
      idx: 1,
      title: 'Starlight',
      content:
          'Under a tapestry of stars, the journey began among constellations...',
    ),
    const Chapter(
      id: 'chap-002-02',
      novelId: 'novel-002',
      idx: 2,
      title: 'Abyssal Drift',
      content:
          'Beneath the waves, silent currents carried tales older than the moon...',
    ),
  ],
  'novel-003': [
    const Chapter(
      id: 'chap-003-01',
      novelId: 'novel-003',
      idx: 1,
      title: 'Midnight Walk',
      content:
          'Neon reflections danced on rain-soaked streets as night unfolded...',
    ),
  ],
};

final mockNovelsProvider = FutureProvider<List<Novel>>((ref) async {
  // Simulate async fetch for consistency with real provider.
  await Future<void>.delayed(const Duration(milliseconds: 100));
  return _mockNovels;
});

final mockChaptersProvider = FutureProvider.family<List<Chapter>, String>((
  ref,
  novelId,
) async {
  await Future<void>.delayed(const Duration(milliseconds: 100));
  return _mockChaptersByNovel[novelId] ?? const <Chapter>[];
});

/// Neutral offline progress: returns null (not started) for any novel.
/// This surfaces a determinate 0% ring in the Library.
final mockLastProgressProvider = FutureProvider.family<UserProgress?, String>((
  ref,
  novelId,
) async {
  await Future<void>.delayed(const Duration(milliseconds: 50));
  return null;
});
