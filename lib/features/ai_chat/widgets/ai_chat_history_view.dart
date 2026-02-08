import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/ai_chat_providers.dart';

class AiChatHistoryView extends ConsumerWidget {
  const AiChatHistoryView({super.key, required this.onClose});
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(aiChatProvider);
    final notifier = ref.read(aiChatProvider.notifier);
    final sessions = state.sessions;

    return Column(
      children: [
        AppBar(
          title: const Text('History'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: onClose,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                notifier.startNewSession();
                onClose();
              },
              tooltip: 'New Chat',
            ),
          ],
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        Expanded(
          child: sessions.isEmpty
              ? const Center(child: Text('No history'))
              : ListView.builder(
                  itemCount: sessions.length,
                  itemBuilder: (context, index) {
                    final session = sessions[index];
                    final isSelected = session.id == state.currentSessionId;
                    return ListTile(
                      title: Text(
                        session.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: isSelected
                            ? const TextStyle(fontWeight: FontWeight.bold)
                            : null,
                      ),
                      subtitle: Text(
                        session.preview,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      selected: isSelected,
                      selectedTileColor: Theme.of(
                        context,
                      ).colorScheme.primaryContainer,
                      onTap: () {
                        notifier.selectSession(session.id);
                        onClose();
                      },
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20),
                        onPressed: () => notifier.deleteSession(session.id),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
