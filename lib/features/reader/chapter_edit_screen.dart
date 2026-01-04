import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';
import '../../repositories/chapter_repository.dart';
import '../../state/novel_providers.dart';

class ChapterEditScreen extends ConsumerStatefulWidget {
  const ChapterEditScreen({super.key, required this.novelId});

  final String novelId;

  @override
  ConsumerState<ChapterEditScreen> createState() => _ChapterEditScreenState();
}

class _ChapterEditScreenState extends ConsumerState<ChapterEditScreen> {
  bool _creating = false;
  String? _error;

  Future<void> _createChapter() async {
    setState(() {
      _creating = true;
      _error = null;
    });

    try {
      final repo = ref.read(chapterRepositoryProvider);
      final nextIdx = await repo.getNextIdx(widget.novelId);
      final created = await repo.createChapter(
        novelId: widget.novelId,
        idx: nextIdx,
        title: 'Chapter $nextIdx',
        content: '',
      );

      if (!mounted) return;

      // Invalidate the chapters provider to refresh the list
      ref.invalidate(chaptersProvider(widget.novelId));

      // Navigate to the chapter reader in edit mode
      context.go('/novel/${widget.novelId}/chapters/${created.id}');
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _creating = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // Automatically create the chapter when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _createChapter();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_creating) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.newChapter)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.newChapter)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${l10n.error}: $_error',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.pop(),
                  child: Text(l10n.back),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // This shouldn't be reached if the chapter creation succeeded
    return Scaffold(
      appBar: AppBar(title: Text(l10n.newChapter)),
      body: const Center(child: CircularProgressIndicator()),
    );
  }
}
