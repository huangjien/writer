import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novel_reader/state/novel_providers.dart';
import 'package:novel_reader/state/mock_providers.dart';
import 'package:novel_reader/state/supabase_config.dart';
import 'package:novel_reader/models/novel.dart';

class CharactersScreen extends ConsumerWidget {
  const CharactersScreen({super.key, required this.novelId});

  final String novelId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Characters'),
        actions: [
          Tooltip(
            message: 'Create',
            child: IconButton(icon: const Icon(Icons.add), onPressed: () {}),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (supabaseEnabled)
              ref
                  .watch(novelProvider(novelId))
                  .when(
                    data: (novel) => _NovelHeader(novel: novel),
                    loading: () => const _LoadingTile(label: 'Loading novel…'),
                    error: (e, _) => _ErrorTile(label: 'Error: $e'),
                  )
            else
              ref
                  .watch(mockNovelsProvider)
                  .when(
                    data: (novels) {
                      final matches = novels.where((n) => n.id == novelId);
                      final novel = matches.isNotEmpty ? matches.first : null;
                      return _NovelHeader(novel: novel);
                    },
                    loading: () => const _LoadingTile(label: 'Loading novel…'),
                    error: (e, _) => _ErrorTile(label: 'Error: $e'),
                  ),
            const SizedBox(height: 16),
            const Text('No characters found.'),
          ],
        ),
      ),
    );
  }
}

class _NovelHeader extends StatelessWidget {
  const _NovelHeader({required this.novel});
  final Novel? novel;

  @override
  Widget build(BuildContext context) {
    final title = novel?.title ?? 'Unknown Novel';
    final author = novel?.author;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        if (author != null && author.isNotEmpty) Text(author),
      ],
    );
  }
}

class _LoadingTile extends StatelessWidget {
  const _LoadingTile({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircularProgressIndicator(strokeWidth: 2),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }
}

class _ErrorTile extends StatelessWidget {
  const _ErrorTile({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.warning_amber_rounded, size: 16),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }
}
