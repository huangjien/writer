import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/state/novel_providers.dart';
import 'package:writer/state/mock_providers.dart';
import 'package:writer/state/supabase_config.dart';
import 'package:writer/models/novel.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/l10n/app_localizations_en.dart';
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
  bool _isDirty = false;
  String _baseTitle = '';
  String _baseLocation = '';
  String _baseSummary = '';

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
    _baseTitle = _titleController.text;
    _baseLocation = _locationController.text;
    _baseSummary = _summaryController.text;
    _isDirty = false;
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
    final l10n = AppLocalizations.of(context) ?? AppLocalizationsEn();
    return Scaffold(
      appBar: AppBar(title: Text(l10n.scenes), actions: const []),
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
                    loading: () => _LoadingTile(label: l10n.loadingNovels),
                    error: (e, _) => _ErrorTile(label: '${l10n.error}: $e'),
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
                    loading: () => _LoadingTile(label: l10n.loadingNovels),
                    error: (e, _) => _ErrorTile(label: '${l10n.error}: $e'),
                  ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(labelText: l10n.titleLabel),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? l10n.required : null,
                    onChanged: (_) {
                      final dirty =
                          _titleController.text.trim() != _baseTitle.trim() ||
                          _locationController.text.trim() !=
                              _baseLocation.trim() ||
                          _summaryController.text.trim() != _baseSummary.trim();
                      if (dirty != _isDirty) setState(() => _isDirty = dirty);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _locationController,
                    decoration: InputDecoration(labelText: l10n.locationLabel),
                    onChanged: (_) {
                      final dirty =
                          _titleController.text.trim() != _baseTitle.trim() ||
                          _locationController.text.trim() !=
                              _baseLocation.trim() ||
                          _summaryController.text.trim() != _baseSummary.trim();
                      if (dirty != _isDirty) setState(() => _isDirty = dirty);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _summaryController,
                    decoration: InputDecoration(
                      labelText: l10n.descriptionLabel,
                    ),
                    maxLines: 5,
                    onChanged: (_) {
                      final dirty =
                          _titleController.text.trim() != _baseTitle.trim() ||
                          _locationController.text.trim() !=
                              _baseLocation.trim() ||
                          _summaryController.text.trim() != _baseSummary.trim();
                      if (dirty != _isDirty) setState(() => _isDirty = dirty);
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: (_saving || !_isDirty)
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
                                    SnackBar(content: Text(l10n.saved)),
                                  );
                                } catch (e) {
                                  setState(() => _error = e.toString());
                                } finally {
                                  if (mounted) setState(() => _saving = false);
                                }
                              },
                        child: Text(l10n.save),
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
    final l10n = AppLocalizations.of(context) ?? AppLocalizationsEn();
    final title = novel?.title ?? l10n.unknownNovel;
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
