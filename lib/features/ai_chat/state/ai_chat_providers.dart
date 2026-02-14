import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:uuid/uuid.dart';
import 'package:writer/features/ai_chat/services/ai_chat_service.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/shared/constants.dart';
import 'package:writer/state/ai_agent_settings.dart';
import 'package:writer/state/app_settings.dart';
import '../models/chat_message.dart';
import '../models/chat_session.dart';
import '../services/chat_storage_service.dart';
import '../utils/context_utils.dart';

// --- Context Provider ---

@immutable
class AiContextState {
  final bool isEnabled;
  final String? currentType;
  final Future<String> Function()? loader;
  final bool isLoading;
  final String? cachedContent;
  final int tokenCount;

  const AiContextState({
    this.isEnabled = false,
    this.currentType,
    this.loader,
    this.isLoading = false,
    this.cachedContent,
    this.tokenCount = 0,
  });

  AiContextState copyWith({
    bool? isEnabled,
    String? currentType,
    Future<String> Function()? loader,
    bool? isLoading,
    String? cachedContent,
    int? tokenCount,
  }) {
    return AiContextState(
      isEnabled: isEnabled ?? this.isEnabled,
      currentType: currentType ?? this.currentType,
      loader: loader ?? this.loader,
      isLoading: isLoading ?? this.isLoading,
      cachedContent: cachedContent ?? this.cachedContent,
      tokenCount: tokenCount ?? this.tokenCount,
    );
  }
}

class AiContextNotifier extends StateNotifier<AiContextState> {
  AiContextNotifier(this._localeReader) : super(const AiContextState());

  final Locale Function() _localeReader;

  Locale _currentLocale() {
    try {
      return _localeReader();
    } catch (_) {
      return const Locale('en');
    }
  }

  AppLocalizations _l10n() {
    return lookupAppLocalizations(_currentLocale());
  }

  void setContextDelegate({
    required String type,
    required Future<String> Function() loader,
  }) {
    state = state.copyWith(
      currentType: type,
      loader: loader,
      cachedContent: null,
    );
    if (state.isEnabled) {
      _load();
    }
  }

  void clearContextDelegate() {
    state = state.copyWith(
      currentType: null,
      loader: null,
      cachedContent: null,
      tokenCount: 0,
    );
  }

  void toggle(bool value) {
    state = state.copyWith(isEnabled: value);
    if (value) {
      _load();
    }
  }

  Future<void> _load() async {
    if (state.loader == null) return;
    state = state.copyWith(isLoading: true);
    try {
      final content = await state.loader!();
      if (mounted) {
        final tokenCount = ContextUtils.estimateTokens(content);
        state = state.copyWith(
          isLoading: false,
          cachedContent: content,
          tokenCount: tokenCount,
        );
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(
          isLoading: false,
          cachedContent: _l10n().aiContextLoadError(e.toString()),
          tokenCount: 0,
        );
      }
    }
  }

  Future<String?> getActiveContext() async {
    if (!state.isEnabled) return null;
    if (state.cachedContent != null) return state.cachedContent;
    if (state.loader != null) {
      await _load();
      return state.cachedContent;
    }
    return null;
  }
}

final aiContextProvider =
    StateNotifierProvider<AiContextNotifier, AiContextState>((ref) {
      Locale readLocale() {
        try {
          return ref.read(appSettingsProvider);
        } catch (_) {
          return const Locale('en');
        }
      }

      return AiContextNotifier(readLocale);
    });

// --- Chat Session Provider ---

@immutable
class AiChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? currentSessionId;
  final List<ChatSession> sessions;

  const AiChatState({
    required this.messages,
    required this.isLoading,
    this.currentSessionId,
    this.sessions = const [],
  });

  AiChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? currentSessionId,
    List<ChatSession>? sessions,
  }) {
    return AiChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      currentSessionId: currentSessionId ?? this.currentSessionId,
      sessions: sessions ?? this.sessions,
    );
  }
}

class AiChatNotifier extends StateNotifier<AiChatState> {
  AiChatNotifier(
    this._aiChatService,
    this._settingsReader,
    this._storageService,
    this._contextNotifier,
    this._localeReader,
  ) : super(const AiChatState(messages: [], isLoading: false)) {
    _loadSessions();
  }

  final AiChatService _aiChatService;
  final AiAgentSettings Function() _settingsReader;
  final ChatStorageService _storageService;
  final AiContextNotifier _contextNotifier;
  final Locale Function() _localeReader;

  Locale _currentLocale() {
    try {
      return _localeReader();
    } catch (_) {
      return const Locale('en');
    }
  }

  AppLocalizations _l10n() {
    return lookupAppLocalizations(_currentLocale());
  }

  Future<void> _loadSessions() async {
    final sessions = _storageService.loadSessions();
    sessions.sort((a, b) => b.lastUpdatedAt.compareTo(a.lastUpdatedAt));
    state = state.copyWith(sessions: sessions);
  }

  void startNewSession() {
    state = state.copyWith(
      currentSessionId: null,
      messages: [],
      isLoading: false,
    );
  }

  void selectSession(String sessionId) {
    final session = state.sessions.firstWhere(
      (s) => s.id == sessionId,
      orElse: () => throw Exception('Session not found'),
    );
    state = state.copyWith(
      currentSessionId: sessionId,
      messages: session.messages,
      isLoading: false,
    );
  }

  Future<void> deleteSession(String sessionId) async {
    final sessions = state.sessions.where((s) => s.id != sessionId).toList();
    await _storageService.saveSessions(sessions);
    if (state.currentSessionId == sessionId) {
      startNewSession();
    } else {
      state = state.copyWith(sessions: sessions);
    }
  }

  void _updateSession(List<ChatMessage> messages) {
    if (messages.isEmpty) return;
    final now = DateTime.now();
    final lastMsg = messages.last;
    final preview = lastMsg.content
        .replaceAll('\n', ' ')
        .substring(
          0,
          lastMsg.content.length > 50 ? 50 : lastMsg.content.length,
        );

    ChatSession session;
    if (state.currentSessionId == null) {
      final newId = const Uuid().v4();
      final firstMsg = messages.first;
      final title = firstMsg.content.substring(
        0,
        firstMsg.content.length > 30 ? 30 : firstMsg.content.length,
      );
      session = ChatSession(
        id: newId,
        title: title,
        createdAt: now,
        lastUpdatedAt: now,
        messages: messages,
        preview: preview,
      );
      state = state.copyWith(currentSessionId: newId);
    } else {
      final existing = state.sessions.firstWhere(
        (s) => s.id == state.currentSessionId,
      );
      session = existing.copyWith(
        lastUpdatedAt: now,
        messages: messages,
        preview: preview,
      );
    }

    final otherSessions = state.sessions
        .where((s) => s.id != session.id)
        .toList();
    final newSessions = [session, ...otherSessions];
    state = state.copyWith(sessions: newSessions);
    _storageService.saveSessions(newSessions);
  }

  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    if (message.startsWith('/search ')) {
      await _handleRagSearch(message);
      return;
    }

    if (message.startsWith('/deep ')) {
      await _handleDeepAgent(message);
      return;
    }

    // Get and potentially compress context
    String? contextContent = await _contextNotifier.getActiveContext();

    // Auto-compress if context is too long
    if (contextContent != null &&
        ContextUtils.isContextTooLong(contextContent)) {
      final l10n = _l10n();
      // Add a system message about compression
      final compressionNotice = ChatMessage(
        content: l10n.aiChatContextTooLongCompressing(
          ContextUtils.estimateTokens(contextContent),
        ),
        isUser: false,
      );
      final messagesWithNotice = <ChatMessage>[
        ...state.messages,
        compressionNotice,
      ];
      state = state.copyWith(messages: messagesWithNotice);

      try {
        contextContent = await _aiChatService.compressContext(
          contextContent,
          l10n: l10n,
        );
      } catch (e) {
        // If compression fails, use original context but add error note
        contextContent =
            '$contextContent\n\n${l10n.aiChatContextCompressionFailedNote(e.toString())}';
      }
    }

    final effectiveMessage = contextContent != null
        ? "Context:\n$contextContent\n\nQuestion:\n$message"
        : message;

    final userMsg = ChatMessage(content: message, isUser: true);
    final newMessages = <ChatMessage>[...state.messages, userMsg];

    state = state.copyWith(messages: newMessages, isLoading: true);
    _updateSession(newMessages);

    try {
      final l10n = _l10n();
      final response = await _aiChatService.sendMessage(
        effectiveMessage,
        settings: _settingsReader(),
        l10n: l10n,
      );

      final aiMsg = ChatMessage(content: response, isUser: false);
      final finalMessages = <ChatMessage>[...newMessages, aiMsg];

      state = state.copyWith(messages: finalMessages, isLoading: false);
      _updateSession(finalMessages);
    } catch (e) {
      final l10n = _l10n();
      final errorMsg = ChatMessage(
        content: l10n.aiChatError(e.toString()),
        isUser: false,
      );
      final finalMessages = <ChatMessage>[...newMessages, errorMsg];
      state = state.copyWith(messages: finalMessages, isLoading: false);
      _updateSession(finalMessages);
    }
  }

  Future<void> _handleDeepAgent(String message) async {
    final question = message.replaceFirst('/deep ', '').trim();
    if (question.isEmpty) return;

    final settings = _settingsReader();
    final userMsg = ChatMessage(content: message, isUser: true);
    final newMessages = <ChatMessage>[...state.messages, userMsg];

    state = state.copyWith(messages: newMessages, isLoading: true);
    _updateSession(newMessages);

    try {
      final l10n = _l10n();
      // Pass context if enabled
      final contextContent = await _contextNotifier.getActiveContext();

      final response = await _aiChatService.sendMessageDeepAgent(
        question,
        context: contextContent,
        maxPlanSteps: settings.deepAgentMaxPlanSteps,
        maxToolRounds: settings.deepAgentMaxToolRounds,
        reflectionMode: settings.deepAgentReflectionMode.wireValue,
        includeDetails: settings.deepAgentShowDetails,
        l10n: l10n,
      );

      final aiMsg = ChatMessage(content: response, isUser: false);
      final finalMessages = <ChatMessage>[...newMessages, aiMsg];

      state = state.copyWith(messages: finalMessages, isLoading: false);
      _updateSession(finalMessages);
    } catch (e) {
      final l10n = _l10n();
      final errorMsg = ChatMessage(
        content: l10n.aiChatDeepAgentError(e.toString()),
        isUser: false,
      );
      final finalMessages = <ChatMessage>[...newMessages, errorMsg];
      state = state.copyWith(messages: finalMessages, isLoading: false);
      _updateSession(finalMessages);
    }
  }

  Future<void> _handleRagSearch(String message) async {
    final query = message.replaceFirst('/search ', '').trim();
    if (query.isEmpty) return;

    final userMsg = ChatMessage(content: message, isUser: true);
    final newMessages = <ChatMessage>[...state.messages, userMsg];

    state = state.copyWith(messages: newMessages, isLoading: true);
    _updateSession(newMessages);

    try {
      final l10n = _l10n();
      final result = await _aiChatService.ragSearch(query: query);

      if (result == null) {
        throw Exception(l10n.aiChatSearchFailed);
      }

      final refinedQuery = result['refined_query'];
      final results = (result['results'] as List).cast<Map>();

      final sb = StringBuffer();
      sb.writeln('### ${l10n.aiChatRagSearchResultsTitle}');
      if (refinedQuery != null) {
        sb.writeln(
          '> ${l10n.aiChatRagRefinedQuery(refinedQuery.toString())}\n',
        );
      }

      if (results.isEmpty) {
        sb.writeln(l10n.aiChatRagNoResults);
      } else {
        for (final item in results) {
          final title = item['title'] ?? l10n.untitled;
          final type = item['type'] ?? l10n.aiChatRagUnknownType;
          final score = ((item['score'] as num) * 100).toStringAsFixed(1);
          final content = item['content'] as String? ?? '';
          final preview = content.length > 150
              ? '${content.substring(0, 150)}...'
              : content;

          sb.writeln('**$title** ($type) - $score%');
          sb.writeln(preview);
          sb.writeln('');
        }
      }

      final aiMsg = ChatMessage(content: sb.toString(), isUser: false);
      final finalMessages = <ChatMessage>[...newMessages, aiMsg];

      state = state.copyWith(messages: finalMessages, isLoading: false);
      _updateSession(finalMessages);
    } catch (e) {
      final l10n = _l10n();
      final errorMsg = ChatMessage(
        content: l10n.aiChatSearchError(e.toString()),
        isUser: false,
      );
      final finalMessages = <ChatMessage>[...newMessages, errorMsg];
      state = state.copyWith(messages: finalMessages, isLoading: false);
      _updateSession(finalMessages);
    }
  }

  void clearMessages() {
    state = state.copyWith(messages: [], isLoading: false);
    startNewSession();
  }
}

final aiChatProvider = StateNotifierProvider<AiChatNotifier, AiChatState>((
  ref,
) {
  final aiChatService = ref.watch(aiChatServiceProvider);
  final storageService = ref.watch(chatStorageServiceProvider);
  final contextNotifier = ref.watch(aiContextProvider.notifier);

  Locale readLocale() {
    try {
      return ref.read(appSettingsProvider);
    } catch (_) {
      return const Locale('en');
    }
  }

  return AiChatNotifier(
    aiChatService,
    () => ref.read(aiAgentSettingsProvider),
    storageService,
    contextNotifier,
    readLocale,
  );
});

class AiChatUiNotifier extends StateNotifier<bool> {
  AiChatUiNotifier() : super(false);

  void toggleSidebar() {
    state = !state;
  }

  void openSidebar() {
    state = true;
  }

  void closeSidebar() {
    state = false;
  }
}

final aiChatUiProvider = StateNotifierProvider<AiChatUiNotifier, bool>((ref) {
  return AiChatUiNotifier();
});

class AiServiceStatusNotifier extends StateNotifier<bool> {
  AiServiceStatusNotifier(this._aiChatService) : super(false) {
    _checkAndSchedule(initial: true);
  }

  final AiChatService _aiChatService;
  Timer? _timer;
  final Duration _okInterval = kAiHealthCheckIntervalOk;
  final Duration _failInterval = kAiHealthCheckIntervalFail;

  void _scheduleNext(Duration delay) {
    _timer?.cancel();
    _timer = Timer(delay, () => _checkAndSchedule());
  }

  Future<void> _checkAndSchedule({bool initial = false}) async {
    final isHealthy = await _aiChatService.checkHealth();
    if (mounted) {
      state = isHealthy;
    }
    final next = isHealthy ? _okInterval : _failInterval;
    _scheduleNext(initial ? next : next);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final aiServiceStatusProvider =
    StateNotifierProvider.autoDispose<AiServiceStatusNotifier, bool>((ref) {
      final aiChatService = ref.watch(aiChatServiceProvider);
      return AiServiceStatusNotifier(aiChatService);
    });
