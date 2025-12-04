import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/state/novel_providers.dart';
import 'package:writer/state/mock_providers.dart';
import 'package:writer/state/supabase_config.dart';
import 'package:writer/models/novel.dart';
import '../../main.dart';
import '../../models/scene.dart';

class ScenesScreen extends ConsumerStatefulWidget {
  const ScenesScreen({super.key, required this.novelId, this.idx});

  final String novelId;
  final int? idx;

  @override
  ConsumerState<ScenesScreen> createState() => _ScenesScreenState();
}

class _ScenesScreenState extends ConsumerState<ScenesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _summaryController = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = ref.read(localStorageRepositoryProvider);
    final item = await repo.getSceneForm(widget.novelId, idx: widget.idx);
    if (item != null) {
      _titleController.text = item.title;
      _locationController.text = item.location ?? '';
      _summaryController.text = item.summary ?? '';
    }
    setState(() {});
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _summaryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scenes'), actions: const []),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (supabaseEnabled)
              ref
                  .watch(novelProvider(widget.novelId))
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
                      final matches = novels.where(
                        (n) => n.id == widget.novelId,
                      );
                      final novel = matches.isNotEmpty ? matches.first : null;
                      return _NovelHeader(novel: novel);
                    },
                    loading: () => const _LoadingTile(label: 'Loading novel…'),
                    error: (e, _) => _ErrorTile(label: 'Error: $e'),
                  ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(labelText: 'Location'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _summaryController,
                    decoration: const InputDecoration(labelText: 'Summary'),
                    maxLines: 5,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: _saving
                            ? null
                            : () async {
                                final ok =
                                    _formKey.currentState?.validate() ?? false;
                                if (!ok) return;
                                setState(() {
                                  _saving = true;
                                  _error = null;
                                });
                                try {
                                  final repo = ref.read(
                                    localStorageRepositoryProvider,
                                  );
                                  final useIdx =
                                      widget.idx ??
                                      await repo.nextSceneIdx(widget.novelId);
                                  await repo.saveSceneForm(
                                    widget.novelId,
                                    Scene(
                                      novelId: widget.novelId,
                                      title: _titleController.text.trim(),
                                      location:
                                          _locationController.text
                                              .trim()
                                              .isEmpty
                                          ? null
                                          : _locationController.text.trim(),
                                      summary:
                                          _summaryController.text.trim().isEmpty
                                          ? null
                                          : _summaryController.text.trim(),
                                    ),
                                    idx: useIdx,
                                  );
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Saved')),
                                  );
                                } catch (e) {
                                  setState(() => _error = e.toString());
                                } finally {
                                  if (mounted) setState(() => _saving = false);
                                }
                              },
                        child: const Text('Save'),
                      ),
                      const SizedBox(width: 12),
                      if (_error != null)
                        Expanded(
                          child: Text(
                            _error!,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.redAccent),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
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
