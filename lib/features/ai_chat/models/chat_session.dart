import 'chat_message.dart';

class ChatSession {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime lastUpdatedAt;
  final List<ChatMessage> messages;
  final String preview;

  ChatSession({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.lastUpdatedAt,
    required this.messages,
    required this.preview,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'createdAt': createdAt.toIso8601String(),
    'lastUpdatedAt': lastUpdatedAt.toIso8601String(),
    'messages': messages.map((m) => m.toJson()).toList(),
    'preview': preview,
  };

  factory ChatSession.fromJson(Map<String, dynamic> json) => ChatSession(
    id: json['id'] as String,
    title: json['title'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    lastUpdatedAt: DateTime.parse(json['lastUpdatedAt'] as String),
    messages: (json['messages'] as List)
        .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
        .toList(),
    preview: json['preview'] as String,
  );

  ChatSession copyWith({
    String? title,
    DateTime? lastUpdatedAt,
    List<ChatMessage>? messages,
    String? preview,
  }) {
    return ChatSession(
      id: id,
      title: title ?? this.title,
      createdAt: createdAt,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      messages: messages ?? this.messages,
      preview: preview ?? this.preview,
    );
  }
}
