import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/features/ai_chat/state/ai_chat_providers.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:writer/shared/widgets/app_buttons.dart';
import 'ai_context_toggle.dart';
import 'ai_chat_history_view.dart';
import '../models/chat_message.dart';

class AiChatSidebar extends ConsumerStatefulWidget {
  const AiChatSidebar({super.key, this.width});
  final double? width;

  @override
  ConsumerState<AiChatSidebar> createState() => _AiChatSidebarState();
}

class _AiChatSidebarState extends ConsumerState<AiChatSidebar> {
  late final ScrollController _scrollController;
  late final TextEditingController _textController;
  int _lastLen = 0;
  bool _showHistory = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _textController = TextEditingController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    final max = _scrollController.position.maxScrollExtent;
    _scrollController.jumpTo(max);
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(aiChatProvider);
    final chatNotifier = ref.read(aiChatProvider.notifier);
    final messages = chatState.messages;
    final isLoading = chatState.isLoading;

    if (messages.length != _lastLen) {
      _lastLen = messages.length;
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }

    final l10n = AppLocalizations.of(context)!;
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return Container(
      width: widget.width ?? 350,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          left: BorderSide(
            color: Theme.of(
              context,
            ).colorScheme.outline.withValues(alpha: isRTL ? 0 : 0.2),
            width: 1,
          ),
          right: BorderSide(
            color: Theme.of(
              context,
            ).colorScheme.outline.withValues(alpha: isRTL ? 0.2 : 0),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(-2, 0),
          ),
        ],
      ),
      child: _showHistory
          ? AiChatHistoryView(
              onClose: () => setState(() => _showHistory = false),
            )
          : Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.history),
                        tooltip: 'History',
                        onPressed: () => setState(() => _showHistory = true),
                      ),
                      Text(
                        'AI Assistant',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          ref.read(aiChatUiProvider.notifier).closeSidebar();
                        },
                        tooltip: l10n.close,
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // Messages
                Expanded(
                  child: messages.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.auto_awesome,
                                size: 64,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.3),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'How can I help you?',
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.5),
                                    ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final message = messages[index];
                            return _ChatMessageBubble(message: message);
                          },
                        ),
                ),

                if (isLoading)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.aiThinking,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                        ),
                      ],
                    ),
                  ),

                // Input Area
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    border: Border(
                      top: BorderSide(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8.0),
                        child: AiContextToggle(),
                      ),
                      TextField(
                        controller: _textController,
                        decoration: InputDecoration(
                          hintText: l10n.aiChatHint,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surface,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          suffixIcon: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: AppButtons.icon(
                              iconData: Icons.send,
                              color: Theme.of(context).colorScheme.primary,
                              enabled: !isLoading,
                              onPressed: isLoading
                                  ? () {}
                                  : () {
                                      final t = _textController.text.trim();
                                      if (t.isNotEmpty) {
                                        chatNotifier.sendMessage(t);
                                        _textController.clear();
                                      }
                                    },
                            ),
                          ),
                        ),
                        maxLines: 4,
                        minLines: 1,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (text) {
                          final t = text.trim();
                          if (t.isNotEmpty && !isLoading) {
                            chatNotifier.sendMessage(t);
                            _textController.clear();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _ChatMessageBubble extends StatelessWidget {
  const _ChatMessageBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isUser = message.isUser;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final extras = 48.0;
          final maxW = (constraints.maxWidth - extras).clamp(
            100.0,
            constraints.maxWidth,
          );
          final textColor = isUser
              ? Theme.of(context).colorScheme.onPrimary
              : Theme.of(context).colorScheme.onSurface;
          final base = MarkdownStyleSheet.fromTheme(Theme.of(context));
          final sheet = base.copyWith(
            p:
                (base.p?.copyWith(color: textColor)) ??
                TextStyle(color: textColor),
            code:
                (base.code?.copyWith(color: textColor)) ??
                TextStyle(color: textColor),
            a:
                (base.a?.copyWith(color: textColor)) ??
                TextStyle(color: textColor),
          );
          final bubbleText = SelectionArea(
            child: MarkdownBody(data: message.content, styleSheet: sheet),
          );
          final bubble = ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxW),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(20).copyWith(
                  topLeft: isUser ? const Radius.circular(20) : Radius.zero,
                  topRight: isUser ? Radius.zero : const Radius.circular(20),
                ),
              ),
              child: bubbleText,
            ),
          );
          final row = Row(
            mainAxisAlignment: isUser
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isUser) ...[
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Icon(
                    Icons.auto_awesome,
                    size: 16,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              bubble,
              if (isUser) ...[
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  child: Icon(
                    Icons.person,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSecondary,
                  ),
                ),
              ],
            ],
          );
          if (!isUser) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                row,
                Padding(
                  padding: const EdgeInsets.only(left: 40, top: 4),
                  child: IconButton(
                    iconSize: 16,
                    visualDensity: VisualDensity.compact,
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: message.content));
                      try {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.copiedToClipboard)),
                        );
                      } catch (_) {}
                    },
                    icon: const Icon(Icons.copy),
                    tooltip: l10n.copy,
                  ),
                ),
              ],
            );
          }
          return row;
        },
      ),
    );
  }
}
