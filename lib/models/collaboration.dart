class CollaborationSession {
  final String id;
  final String documentId;
  final String ownerId;
  final List<String> collaboratorIds;
  final SessionStatus status;
  final DateTime createdAt;
  final DateTime? endedAt;
  final SessionSettings settings;

  CollaborationSession({
    required this.id,
    required this.documentId,
    required this.ownerId,
    required this.collaboratorIds,
    required this.status,
    required this.createdAt,
    this.endedAt,
    required this.settings,
  });

  bool get isActive => status == SessionStatus.active;
  int get collaboratorCount => collaboratorIds.length;

  CollaborationSession copyWith({
    String? id,
    String? documentId,
    String? ownerId,
    List<String>? collaboratorIds,
    SessionStatus? status,
    DateTime? createdAt,
    DateTime? endedAt,
    SessionSettings? settings,
  }) {
    return CollaborationSession(
      id: id ?? this.id,
      documentId: documentId ?? this.documentId,
      ownerId: ownerId ?? this.ownerId,
      collaboratorIds: collaboratorIds ?? this.collaboratorIds,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      endedAt: endedAt ?? this.endedAt,
      settings: settings ?? this.settings,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'document_id': documentId,
      'owner_id': ownerId,
      'collaborator_ids': collaboratorIds,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      'ended_at': endedAt?.toIso8601String(),
      'settings': settings.toMap(),
    };
  }

  factory CollaborationSession.fromMap(Map<String, dynamic> map) {
    return CollaborationSession(
      id: map['id'] as String,
      documentId: map['document_id'] as String,
      ownerId: map['owner_id'] as String,
      collaboratorIds: List<String>.from(map['collaborator_ids'] ?? []),
      status: SessionStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => SessionStatus.pending,
      ),
      createdAt: DateTime.parse(map['created_at'] as String),
      endedAt: map['ended_at'] != null
          ? DateTime.parse(map['ended_at'] as String)
          : null,
      settings: SessionSettings.fromMap(
        map['settings'] as Map<String, dynamic>,
      ),
    );
  }
}

enum SessionStatus { pending, active, paused, ended }

class SessionSettings {
  final bool allowRealTimeEditing;
  final bool allowComments;
  final bool allowSuggestions;
  final bool showCursors;
  final bool showPresence;
  final int? maxCollaborators;
  final Duration? sessionTimeout;
  final bool autoSave;

  SessionSettings({
    this.allowRealTimeEditing = true,
    this.allowComments = true,
    this.allowSuggestions = true,
    this.showCursors = true,
    this.showPresence = true,
    this.maxCollaborators,
    this.sessionTimeout,
    this.autoSave = true,
  });

  SessionSettings copyWith({
    bool? allowRealTimeEditing,
    bool? allowComments,
    bool? allowSuggestions,
    bool? showCursors,
    bool? showPresence,
    int? maxCollaborators,
    Duration? sessionTimeout,
    bool? autoSave,
  }) {
    return SessionSettings(
      allowRealTimeEditing: allowRealTimeEditing ?? this.allowRealTimeEditing,
      allowComments: allowComments ?? this.allowComments,
      allowSuggestions: allowSuggestions ?? this.allowSuggestions,
      showCursors: showCursors ?? this.showCursors,
      showPresence: showPresence ?? this.showPresence,
      maxCollaborators: maxCollaborators ?? this.maxCollaborators,
      sessionTimeout: sessionTimeout ?? this.sessionTimeout,
      autoSave: autoSave ?? this.autoSave,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'allow_realtime_editing': allowRealTimeEditing,
      'allow_comments': allowComments,
      'allow_suggestions': allowSuggestions,
      'show_cursors': showCursors,
      'show_presence': showPresence,
      'max_collaborators': maxCollaborators,
      'session_timeout': sessionTimeout?.inMinutes,
      'auto_save': autoSave,
    };
  }

  factory SessionSettings.fromMap(Map<String, dynamic> map) {
    return SessionSettings(
      allowRealTimeEditing: map['allow_realtime_editing'] as bool? ?? true,
      allowComments: map['allow_comments'] as bool? ?? true,
      allowSuggestions: map['allow_suggestions'] as bool? ?? true,
      showCursors: map['show_cursors'] as bool? ?? true,
      showPresence: map['show_presence'] as bool? ?? true,
      maxCollaborators: map['max_collaborators'] as int?,
      sessionTimeout: map['session_timeout'] != null
          ? Duration(minutes: map['session_timeout'] as int)
          : null,
      autoSave: map['auto_save'] as bool? ?? true,
    );
  }
}

class Collaborator {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final CollaboratorRole role;
  final DateTime joinedAt;
  final CollaboratorStatus status;

  Collaborator({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    required this.role,
    required this.joinedAt,
    required this.status,
  });

  bool get isOnline => status == CollaboratorStatus.online;
  bool get canEdit =>
      role == CollaboratorRole.editor || role == CollaboratorRole.owner;

  Collaborator copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    CollaboratorRole? role,
    DateTime? joinedAt,
    CollaboratorStatus? status,
  }) {
    return Collaborator(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar_url': avatarUrl,
      'role': role.name,
      'joined_at': joinedAt.toIso8601String(),
      'status': status.name,
    };
  }

  factory Collaborator.fromMap(Map<String, dynamic> map) {
    return Collaborator(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      avatarUrl: map['avatar_url'] as String?,
      role: CollaboratorRole.values.firstWhere(
        (e) => e.name == map['role'],
        orElse: () => CollaboratorRole.viewer,
      ),
      joinedAt: DateTime.parse(map['joined_at'] as String),
      status: CollaboratorStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => CollaboratorStatus.offline,
      ),
    );
  }
}

enum CollaboratorRole { owner, editor, commenter, viewer }

enum CollaboratorStatus { online, away, offline }

class Comment {
  final String id;
  final String documentId;
  final String authorId;
  final String authorName;
  final String content;
  final int? startPosition;
  final int? endPosition;
  final String? selectedText;
  final DateTime createdAt;
  final DateTime? editedAt;
  final List<CommentReply> replies;
  final CommentStatus status;
  final String? resolvedBy;

  Comment({
    required this.id,
    required this.documentId,
    required this.authorId,
    required this.authorName,
    required this.content,
    this.startPosition,
    this.endPosition,
    this.selectedText,
    required this.createdAt,
    this.editedAt,
    this.replies = const [],
    this.status = CommentStatus.active,
    this.resolvedBy,
  });

  bool get isResolved => status == CommentStatus.resolved;
  bool get hasSelection => startPosition != null && endPosition != null;
  bool get hasReplies => replies.isNotEmpty;

  Comment copyWith({
    String? id,
    String? documentId,
    String? authorId,
    String? authorName,
    String? content,
    int? startPosition,
    int? endPosition,
    String? selectedText,
    DateTime? createdAt,
    DateTime? editedAt,
    List<CommentReply>? replies,
    CommentStatus? status,
    String? resolvedBy,
  }) {
    return Comment(
      id: id ?? this.id,
      documentId: documentId ?? this.documentId,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      content: content ?? this.content,
      startPosition: startPosition ?? this.startPosition,
      endPosition: endPosition ?? this.endPosition,
      selectedText: selectedText ?? this.selectedText,
      createdAt: createdAt ?? this.createdAt,
      editedAt: editedAt ?? this.editedAt,
      replies: replies ?? this.replies,
      status: status ?? this.status,
      resolvedBy: resolvedBy ?? this.resolvedBy,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'document_id': documentId,
      'author_id': authorId,
      'author_name': authorName,
      'content': content,
      'start_position': startPosition,
      'end_position': endPosition,
      'selected_text': selectedText,
      'created_at': createdAt.toIso8601String(),
      'edited_at': editedAt?.toIso8601String(),
      'replies': replies.map((r) => r.toMap()).toList(),
      'status': status.name,
      'resolved_by': resolvedBy,
    };
  }

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'] as String,
      documentId: map['document_id'] as String,
      authorId: map['author_id'] as String,
      authorName: map['author_name'] as String,
      content: map['content'] as String,
      startPosition: map['start_position'] as int?,
      endPosition: map['end_position'] as int?,
      selectedText: map['selected_text'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      editedAt: map['edited_at'] != null
          ? DateTime.parse(map['edited_at'] as String)
          : null,
      replies:
          (map['replies'] as List<dynamic>?)
              ?.map((r) => CommentReply.fromMap(r as Map<String, dynamic>))
              .toList() ??
          [],
      status: CommentStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => CommentStatus.active,
      ),
      resolvedBy: map['resolved_by'] as String?,
    );
  }
}

enum CommentStatus { active, resolved, deleted }

class CommentReply {
  final String id;
  final String commentId;
  final String authorId;
  final String authorName;
  final String content;
  final DateTime createdAt;
  final DateTime? editedAt;

  CommentReply({
    required this.id,
    required this.commentId,
    required this.authorId,
    required this.authorName,
    required this.content,
    required this.createdAt,
    this.editedAt,
  });

  CommentReply copyWith({
    String? id,
    String? commentId,
    String? authorId,
    String? authorName,
    String? content,
    DateTime? createdAt,
    DateTime? editedAt,
  }) {
    return CommentReply(
      id: id ?? this.id,
      commentId: commentId ?? this.commentId,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      editedAt: editedAt ?? this.editedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'comment_id': commentId,
      'author_id': authorId,
      'author_name': authorName,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'edited_at': editedAt?.toIso8601String(),
    };
  }

  factory CommentReply.fromMap(Map<String, dynamic> map) {
    return CommentReply(
      id: map['id'] as String,
      commentId: map['comment_id'] as String,
      authorId: map['author_id'] as String,
      authorName: map['author_name'] as String,
      content: map['content'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      editedAt: map['edited_at'] != null
          ? DateTime.parse(map['edited_at'] as String)
          : null,
    );
  }
}

class Suggestion {
  final String id;
  final String documentId;
  final String authorId;
  final String authorName;
  final String originalText;
  final String suggestedText;
  final int startPosition;
  final int endPosition;
  final SuggestionType type;
  final SuggestionStatus status;
  final DateTime createdAt;
  final String? feedback;
  final DateTime? appliedAt;

  Suggestion({
    required this.id,
    required this.documentId,
    required this.authorId,
    required this.authorName,
    required this.originalText,
    required this.suggestedText,
    required this.startPosition,
    required this.endPosition,
    required this.type,
    required this.status,
    required this.createdAt,
    this.feedback,
    this.appliedAt,
  });

  bool get isPending => status == SuggestionStatus.pending;
  bool get isAccepted => status == SuggestionStatus.accepted;
  bool get isRejected => status == SuggestionStatus.rejected;

  Suggestion copyWith({
    String? id,
    String? documentId,
    String? authorId,
    String? authorName,
    String? originalText,
    String? suggestedText,
    int? startPosition,
    int? endPosition,
    SuggestionType? type,
    SuggestionStatus? status,
    DateTime? createdAt,
    String? feedback,
    DateTime? appliedAt,
  }) {
    return Suggestion(
      id: id ?? this.id,
      documentId: documentId ?? this.documentId,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      originalText: originalText ?? this.originalText,
      suggestedText: suggestedText ?? this.suggestedText,
      startPosition: startPosition ?? this.startPosition,
      endPosition: endPosition ?? this.endPosition,
      type: type ?? this.type,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      feedback: feedback ?? this.feedback,
      appliedAt: appliedAt ?? this.appliedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'document_id': documentId,
      'author_id': authorId,
      'author_name': authorName,
      'original_text': originalText,
      'suggested_text': suggestedText,
      'start_position': startPosition,
      'end_position': endPosition,
      'type': type.name,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      'feedback': feedback,
      'applied_at': appliedAt?.toIso8601String(),
    };
  }

  factory Suggestion.fromMap(Map<String, dynamic> map) {
    return Suggestion(
      id: map['id'] as String,
      documentId: map['document_id'] as String,
      authorId: map['author_id'] as String,
      authorName: map['author_name'] as String,
      originalText: map['original_text'] as String,
      suggestedText: map['suggested_text'] as String,
      startPosition: map['start_position'] as int,
      endPosition: map['end_position'] as int,
      type: SuggestionType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => SuggestionType.edit,
      ),
      status: SuggestionStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => SuggestionStatus.pending,
      ),
      createdAt: DateTime.parse(map['created_at'] as String),
      feedback: map['feedback'] as String?,
      appliedAt: map['applied_at'] != null
          ? DateTime.parse(map['applied_at'] as String)
          : null,
    );
  }
}

enum SuggestionType { edit, addition, deletion, formatting, comment }

enum SuggestionStatus { pending, accepted, rejected }
