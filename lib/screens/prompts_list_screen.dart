import 'package:flutter/material.dart';
import 'dart:async';

import '../models/prompt.dart';
import '../services/prompts_service.dart';
import 'package:go_router/go_router.dart';
import '../l10n/app_localizations.dart';

const int _previewLen = 50;
const int _searchDebounceMs = 600;
const int _searchMinLen = 2;

class PromptsListScreen extends StatefulWidget {
  final PromptsService service;
  final bool showPublic;
  final bool isAdmin;
  final void Function(Prompt)? onEdit;
  const PromptsListScreen({
    super.key,
    required this.service,
    this.showPublic = false,
    this.isAdmin = false,
    this.onEdit,
  });
  @override
  State<PromptsListScreen> createState() => _PromptsListScreenState();
}

class _PromptsListScreenState extends State<PromptsListScreen> {
  List<Prompt> _items = [];
  bool _loading = false;
  String? _error;
  final _searchCtrl = TextEditingController();
  Timer? _searchTimer;
  late bool _showPublic;

  @override
  void initState() {
    super.initState();
    _showPublic = widget.showPublic;
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await widget.service.fetchPrompts(
        isPublic: _showPublic ? true : null,
      );
      setState(() {
        _items = data;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _search({bool force = false}) async {
    final q = _searchCtrl.text.trim();
    if (q.isEmpty) {
      return _load();
    }
    if (!force && q.length < _searchMinLen) {
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await widget.service.searchPrompts(
        q,
        isPublic: _showPublic ? true : null,
      );
      setState(() {
        _items = data;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  List<Prompt> _filtered(List<Prompt> src) {
    return src;
  }

  Map<String, List<Prompt>> _group(List<Prompt> src) {
    return {'All': src};
  }

  String _preview(String s) {
    if (s.length <= _previewLen) return s;
    return '${s.substring(0, _previewLen)}…';
  }

  Future<void> _createPromptDialog() async {
    final keyCtrl = TextEditingController();
    final langCtrl = TextEditingController();
    final contentCtrl = TextEditingController();
    bool makePublic = _showPublic;
    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(l10n.newPrompt),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: keyCtrl,
                  decoration: InputDecoration(labelText: l10n.promptKey),
                ),
                TextField(
                  controller: langCtrl,
                  decoration: InputDecoration(labelText: l10n.language),
                ),
                TextField(
                  controller: contentCtrl,
                  decoration: InputDecoration(labelText: l10n.content),
                  maxLines: 6,
                ),
                if (widget.isAdmin)
                  Row(
                    children: [
                      Text(l10n.publicLabel),
                      Switch(
                        value: makePublic,
                        onChanged: (v) => setState(() => makePublic = v),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.save),
            ),
          ],
        );
      },
    );
    if (ok == true) {
      final key = keyCtrl.text.trim();
      final lang = langCtrl.text.trim();
      final content = contentCtrl.text.trim();
      if (content.isEmpty) {
        setState(() {
          _error = l10n.invalidInput;
        });
        return;
      }
      try {
        await widget.service.createPrompt(
          promptKey: key,
          language: lang.isNotEmpty ? lang : 'en',
          content: content,
          isPublic: makePublic,
        );
        await _load();
      } catch (e) {
        setState(() {
          _error = e.toString();
        });
      }
    }
  }

  Future<void> _makePublic(Prompt p) async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.makePublic),
        content: Text(l10n.makePublicPromptConfirm(p.promptKey, p.language)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
    if (ok == true) {
      try {
        await widget.service.createPrompt(
          promptKey: p.promptKey,
          language: p.language,
          content: p.content,
          isPublic: true,
        );
        await _load();
      } catch (e) {
        setState(() {
          _error = e.toString();
        });
      }
    }
  }

  Future<void> _deletePrompt(Prompt p) async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.delete),
        content: Text(l10n.deletePromptConfirm(p.promptKey, p.language)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (ok == true) {
      try {
        await widget.service.deletePrompt(p.id);
        await _load();
      } catch (e) {
        setState(() {
          _error = e.toString();
        });
      }
    }
  }

  Widget _filters() {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Wrap(
        alignment: WrapAlignment.start,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12,
        runSpacing: 12,
        children: [
          SizedBox(
            width: 320,
            child: TextField(
              controller: _searchCtrl,
              decoration: const InputDecoration(labelText: 'Search'),
              onChanged: (_) {
                _searchTimer?.cancel();
                _searchTimer = Timer(
                  const Duration(milliseconds: _searchDebounceMs),
                  _search,
                );
              },
              onSubmitted: (_) => _search(force: true),
            ),
          ),
          if (widget.isAdmin) ...[
            Text(l10n.viewPublic),
            Switch(
              value: _showPublic,
              onChanged: (v) async {
                setState(() {
                  _showPublic = v;
                });
                await _load();
              },
            ),
          ],
          const SizedBox.shrink(),
        ],
      ),
    );
  }

  DataTable _table(List<Prompt> src) {
    final l10n = AppLocalizations.of(context)!;
    return DataTable(
      columns: [
        DataColumn(label: Text(l10n.promptKey)),
        DataColumn(label: Text(l10n.language)),
        DataColumn(label: Text(l10n.preview)),
        DataColumn(label: Text(l10n.actions)),
      ],
      rows: src
          .map(
            (p) => DataRow(
              cells: [
                DataCell(
                  Row(
                    children: [
                      Text(p.promptKey),
                      const SizedBox(width: 8),
                      if (p.isPublic)
                        Chip(
                          label: Text(l10n.publicLabel),
                          backgroundColor: Colors.greenAccent.withValues(
                            alpha: 0.2,
                          ),
                        )
                      else
                        Chip(label: Text(l10n.privateLabel)),
                    ],
                  ),
                ),
                DataCell(Text(p.language)),
                DataCell(Text(_preview(p.content))),
                DataCell(
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          if (widget.onEdit != null) {
                            widget.onEdit!(p);
                          } else {
                            context.push('/prompt_form', extra: p);
                          }
                        },
                        tooltip: l10n.editPrompt,
                      ),
                      if (widget.isAdmin && !p.isPublic)
                        IconButton(
                          icon: const Icon(Icons.public),
                          onPressed: () => _makePublic(p),
                          tooltip: l10n.makePublic,
                        ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deletePrompt(p),
                        tooltip: l10n.delete,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered(_items);
    final grouped = _group(filtered);
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.prompts),
        actions: [
          IconButton(
            onPressed: _load,
            icon: const Icon(Icons.refresh),
            tooltip: l10n.refreshTooltip,
          ),
          IconButton(
            onPressed: _createPromptDialog,
            icon: const Icon(Icons.add),
            tooltip: l10n.newPrompt,
          ),
          IconButton(
            onPressed: () => context.go('/'),
            icon: const Icon(Icons.home),
            tooltip: l10n.home,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : Column(
              children: [
                _filters(),
                Expanded(
                  child:
                      grouped.isEmpty ||
                          (grouped.length == 1 &&
                              (grouped.values.first.isEmpty))
                      ? Center(child: Text(l10n.noPrompts))
                      : ListView(
                          children: grouped.entries.map((e) {
                            final title = e.key;
                            final list = e.value;
                            return Card(
                              margin: const EdgeInsets.all(8),
                              child: ExpansionTile(
                                title: Text(title),
                                initiallyExpanded: true,
                                children: [
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: _table(list),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchTimer?.cancel();
    super.dispose();
  }
}
