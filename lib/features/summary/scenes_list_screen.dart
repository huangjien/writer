import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/l10n/app_localizations_en.dart';
import '../../models/scene_note.dart';
import 'package:writer/repositories/notes_repository.dart';
import '../../state/providers.dart';
import '../../shared/api_exception.dart';
import '../../shared/widgets/loading/skeleton_list_items.dart';
import '../../shared/widgets/error_state.dart';

class ScenesListScreen extends ConsumerStatefulWidget {
  const ScenesListScreen({super.key, required this.novelId});
  final String novelId;

  @override
  ConsumerState<ScenesListScreen> createState() => _ScenesListScreenState();
}

class _ScenesListScreenState extends ConsumerState<ScenesListScreen> {
  List<SceneNote> _items = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repo = ref.read(notesRepositoryProvider);
      if (ref.read(isSignedInProvider)) {
        _items = await repo.listSceneNotes(widget.novelId);
      } else {
        _items = [];
      }
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    } catch (e) {
      if (e is ApiException && e.statusCode == 401) return;
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context) ?? AppLocalizationsEn();
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.scenes),
        actions: [
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              onPressed: _load,
              icon: const Icon(Icons.refresh),
              tooltip: l10n.refreshTooltip,
            ),
          IconButton(
            onPressed: () =>
                context.push('/novel/${widget.novelId}/scenes/new'),
            icon: const Icon(Icons.add),
            tooltip: l10n.newLabel,
          ),
          IconButton(
            onPressed: () => context.go('/'),
            icon: const Icon(Icons.home),
            tooltip: l10n.home,
          ),
        ],
      ),
      body: _loading
          ? Center(
              child: ListView.builder(
                itemCount: 5,
                itemBuilder: (context, index) => const SceneItemSkeleton(),
              ),
            )
          : _error != null
          ? ErrorState(message: _error!, onRetry: _load)
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemBuilder: (ctx, i) {
                final it = _items[i];
                final title = it.title ?? l10n.untitled;
                final subtitle = it.sceneSummaries ?? it.sceneSynopses ?? '';
                final firstLine = subtitle.split('\n').first.trim();
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      context.push('/novel/${widget.novelId}/scenes/${it.idx}');
                    },
                    hoverColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    child: ListTile(
                      title: Text(title),
                      subtitle: firstLine.isEmpty
                          ? null
                          : Text(
                              firstLine,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              context.push(
                                '/novel/${widget.novelId}/scenes/${it.idx}',
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () async {
                              final ok = await showDialog<bool>(
                                context: context,
                                builder: (d) => AlertDialog(
                                  title: Text(l10n.deleteSceneTitle),
                                  content: Text(l10n.confirmDeleteGeneric),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(d, false),
                                      child: Text(l10n.cancel),
                                    ),
                                    FilledButton(
                                      onPressed: () => Navigator.pop(d, true),
                                      child: Text(l10n.delete),
                                    ),
                                  ],
                                ),
                              );
                              if (ok == true) {
                                final repo = ref.read(notesRepositoryProvider);
                                if (ref.read(isSignedInProvider)) {
                                  await repo.deleteSceneNoteByIdx(
                                    widget.novelId,
                                    it.idx,
                                  );
                                }
                                await _load();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemCount: _items.length,
            ),
    );
  }
}
