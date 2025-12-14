import 'package:flutter_riverpod/legacy.dart';
import 'dart:async';
import '../models/chapter.dart';
import '../repositories/chapter_repository.dart';
import '../repositories/chapter_port.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:writer/features/ai_chat/services/ai_chat_service.dart';
import 'package:writer/shared/constants.dart';

enum EditRequest { idle, saving, creating, deleting }

enum IndexRoundingMode { before, after }

class ChapterEditState {
  final String chapterId;
  final String novelId;
  final int idx;
  final String title;
  final String content;
  final bool isDirty;
  final bool isSaving;
  final String? errorMessage;
  final EditRequest request;
  final bool embeddingInFlight;
  final String? embeddingStatus;

  const ChapterEditState({
    required this.chapterId,
    required this.novelId,
    required this.idx,
    required this.title,
    required this.content,
    this.isDirty = false,
    this.isSaving = false,
    this.errorMessage,
    this.request = EditRequest.idle,
    this.embeddingInFlight = false,
    this.embeddingStatus,
  });

  ChapterEditState copyWith({
    String? chapterId,
    String? novelId,
    int? idx,
    String? title,
    String? content,
    bool? isDirty,
    bool? isSaving,
    String? errorMessage,
    EditRequest? request,
    bool? embeddingInFlight,
    String? embeddingStatus,
  }) {
    return ChapterEditState(
      chapterId: chapterId ?? this.chapterId,
      novelId: novelId ?? this.novelId,
      idx: idx ?? this.idx,
      title: title ?? this.title,
      content: content ?? this.content,
      isDirty: isDirty ?? this.isDirty,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
      request: request ?? this.request,
      embeddingInFlight: embeddingInFlight ?? this.embeddingInFlight,
      embeddingStatus: embeddingStatus,
    );
  }
}

class ChapterEditController extends StateNotifier<ChapterEditState> {
  final ChapterPort _repo;
  final AiChatService _ai;
  Timer? _embedTimer;
  String? _lastEmbeddedContentHash;

  ChapterEditController(Chapter initial, this._repo, [AiChatService? ai])
    : _ai = ai ?? AiChatService('http://localhost:5600/'),
      super(
        ChapterEditState(
          chapterId: initial.id,
          novelId: initial.novelId,
          idx: initial.idx,
          title: initial.title ?? '',
          content: initial.content ?? '',
          request: EditRequest.idle,
        ),
      );

  void setTitle(String title) {
    state = state.copyWith(title: title, isDirty: true);
  }

  void setContent(String content) {
    state = state.copyWith(content: content, isDirty: true);
  }

  void formatContent() {
    if (state.content.isEmpty) return;

    final lines = state.content.split('\n');
    final formattedLines = <String>[];

    for (var line in lines) {
      final trimmed = line.trim();
      if (trimmed.isNotEmpty) {
        formattedLines.add(trimmed);
      }
    }

    final newContent = formattedLines.join('\n\n');
    if (newContent != state.content) {
      state = state.copyWith(content: newContent, isDirty: true);
    }
  }

  Future<bool> save() async {
    state = state.copyWith(
      isSaving: true,
      request: EditRequest.saving,
      errorMessage: null,
    );
    try {
      final updated = Chapter(
        id: state.chapterId,
        novelId: state.novelId,
        idx: state.idx,
        title: state.title,
        content: state.content,
      );
      await _repo.updateChapter(updated);
      _scheduleEmbedding();
      state = state.copyWith(
        isSaving: false,
        request: EditRequest.idle,
        isDirty: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        request: EditRequest.idle,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  void clearEmbeddingStatus() {
    state = state.copyWith(embeddingStatus: null);
  }

  Future<Chapter?> createNextChapter({String? defaultTitle}) async {
    state = state.copyWith(
      isSaving: true,
      request: EditRequest.creating,
      errorMessage: null,
    );
    try {
      final nextIdx = await _repo.getNextIdx(state.novelId);
      final created = await _repo.createChapter(
        novelId: state.novelId,
        idx: nextIdx,
        title: defaultTitle ?? 'Chapter $nextIdx',
        content: '',
      );
      state = state.copyWith(
        isSaving: false,
        request: EditRequest.idle,
        isDirty: false,
      );
      return created;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        request: EditRequest.idle,
        errorMessage: e.toString(),
      );
      return null;
    }
  }

  Future<bool> changeIndexFromFloat(
    double target, {
    IndexRoundingMode mode = IndexRoundingMode.after,
  }) async {
    state = state.copyWith(
      isSaving: true,
      request: EditRequest.saving,
      errorMessage: null,
    );
    try {
      final newIdx = mode == IndexRoundingMode.after
          ? target.ceil()
          : target.floor();
      final oldIdx = state.idx;
      if (newIdx == oldIdx) {
        state = state.copyWith(isSaving: false, request: EditRequest.idle);
        return true;
      }
      final chapters = await _repo.getChapters(state.novelId);
      final maxIdx = chapters.isEmpty
          ? oldIdx
          : chapters.map((c) => c.idx).reduce((a, b) => a > b ? a : b);
      final tempIdx = maxIdx + 1;
      await _repo.updateChapterIdx(state.chapterId, tempIdx);
      if (newIdx < oldIdx) {
        final impacted =
            chapters.where((c) => c.idx >= newIdx && c.idx < oldIdx).toList()
              ..sort((a, b) => b.idx.compareTo(a.idx));
        for (final c in impacted) {
          await _repo.updateChapterIdx(c.id, c.idx + 1);
        }
      } else {
        final impacted =
            chapters.where((c) => c.idx > oldIdx && c.idx <= newIdx).toList()
              ..sort((a, b) => a.idx.compareTo(b.idx));
        for (final c in impacted) {
          await _repo.updateChapterIdx(c.id, c.idx - 1);
        }
      }
      await _repo.updateChapterIdx(state.chapterId, newIdx);
      state = state.copyWith(
        idx: newIdx,
        isSaving: false,
        request: EditRequest.idle,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        request: EditRequest.idle,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<bool> deleteCurrentChapter() async {
    state = state.copyWith(
      isSaving: true,
      request: EditRequest.deleting,
      errorMessage: null,
    );
    try {
      final novelId = state.novelId;
      await _repo.deleteChapter(state.chapterId);
      await _normalizeIndices(novelId);
      state = state.copyWith(
        isSaving: false,
        request: EditRequest.idle,
        isDirty: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        request: EditRequest.idle,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<void> _normalizeIndices(String novelId) async {
    final chapters = await _repo.getChapters(novelId);
    if (chapters.isEmpty) return;
    chapters.sort((a, b) => a.idx.compareTo(b.idx));
    final stagingBase = chapters.length + 102400;
    for (int i = 0; i < chapters.length; i++) {
      final c = chapters[i];
      await _repo.updateChapterIdx(c.id, stagingBase + i).catchError((_) {});
    }
    for (int i = 0; i < chapters.length; i++) {
      final c = chapters[i];
      await _repo.updateChapterIdx(c.id, i + 1).catchError((_) {});
    }
    final verify = await _repo.getChapters(novelId);
    verify.sort((a, b) => a.idx.compareTo(b.idx));
    bool ok = true;
    for (int i = 0; i < verify.length; i++) {
      if (verify[i].idx != i + 1) {
        ok = false;
        break;
      }
    }
    if (!ok) {
      for (int i = 0; i < verify.length; i++) {
        final c = verify[i];
        await _repo.updateChapterIdx(c.id, i + 1).catchError((_) {});
      }
    }
  }

  void _scheduleEmbedding() {
    final text = state.content.trim();
    if (text.isEmpty) return;
    final hash = text.hashCode.toString();
    if (_lastEmbeddedContentHash == hash) {
      return;
    }
    _embedTimer?.cancel();
    var delay = kEmbeddingDebounce;
    assert(() {
      delay = Duration.zero;
      return true;
    }());
    if (delay == Duration.zero) {
      scheduleMicrotask(() {
        if (!mounted) return;
        final latest = state.content.trim();
        if (latest.isEmpty) return;
        final latestHash = latest.hashCode.toString();
        state = state.copyWith(embeddingInFlight: true, embeddingStatus: null);
        _startEmbedding(latest, latestHash);
      });
      return;
    }
    _embedTimer = Timer(delay, () {
      if (!mounted) return;
      final latest = state.content.trim();
      if (latest.isEmpty) return;
      final latestHash = latest.hashCode.toString();
      state = state.copyWith(embeddingInFlight: true, embeddingStatus: null);
      _startEmbedding(latest, latestHash);
    });
  }

  void _startEmbedding(String latest, String latestHash) {
    Future(() async {
      try {
        final vec = await _ai.embed(latest);
        if (vec != null && vec.isNotEmpty) {
          await Supabase.instance.client.rpc(
            'upsert_chapter_embedding',
            params: {'p_chapter_id': state.chapterId, 'p_embedding': vec},
          );
          if (mounted) {
            _lastEmbeddedContentHash = latestHash;
            state = state.copyWith(
              embeddingInFlight: false,
              embeddingStatus: 'embedding_updated',
            );
          }
        } else {
          if (mounted) {
            state = state.copyWith(
              embeddingInFlight: false,
              embeddingStatus: 'embedding_failed',
            );
          }
        }
      } catch (_) {
        if (mounted) {
          state = state.copyWith(
            embeddingInFlight: false,
            embeddingStatus: 'embedding_failed',
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _embedTimer?.cancel();
    super.dispose();
  }
}

final chapterEditControllerProvider = StateNotifierProvider.autoDispose
    .family<ChapterEditController, ChapterEditState, Chapter>((ref, initial) {
      final repo = ref.watch(chapterRepositoryProvider);
      final ai = ref.watch(aiChatServiceProvider);
      return ChapterEditController(initial, repo, ai);
    });
