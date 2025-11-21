import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chapter.dart';
import '../repositories/chapter_repository.dart';
import '../repositories/chapter_port.dart';

enum EditRequest { idle, saving, creating, deleting }

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
    );
  }
}

class ChapterEditController extends StateNotifier<ChapterEditState> {
  final ChapterPort _repo;

  ChapterEditController(Chapter initial, this._repo)
    : super(
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

  Future<bool> deleteCurrentChapter() async {
    state = state.copyWith(
      isSaving: true,
      request: EditRequest.deleting,
      errorMessage: null,
    );
    try {
      await _repo.deleteChapter(state.chapterId);
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
}

final chapterEditControllerProvider = StateNotifierProvider.autoDispose
    .family<ChapterEditController, ChapterEditState, Chapter>((ref, initial) {
      final repo = ref.watch(chapterRepositoryProvider);
      return ChapterEditController(initial, repo);
    });
