import 'package:flutter/material.dart';

import '../models/prompt.dart';
import '../services/prompts_service.dart';
import 'package:go_router/go_router.dart';

const int _previewLen = 50;

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
  final _keyCtrl = TextEditingController();
  final _langCtrl = TextEditingController();
  String _groupBy = 'None';
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

  List<Prompt> _filtered(List<Prompt> src) {
    final kq = _keyCtrl.text.trim().toLowerCase();
    final lq = _langCtrl.text.trim().toLowerCase();
    return src.where((p) {
      final okKey = kq.isEmpty || p.promptKey.toLowerCase().contains(kq);
      final okLang = lq.isEmpty || p.language.toLowerCase().contains(lq);
      return okKey && okLang;
    }).toList();
  }

  Map<String, List<Prompt>> _group(List<Prompt> src) {
    final g = <String, List<Prompt>>{};
    if (_groupBy == 'Language') {
      for (final p in src) {
        g.putIfAbsent(p.language, () => []).add(p);
      }
    } else if (_groupBy == 'Key') {
      for (final p in src) {
        g.putIfAbsent(p.promptKey, () => []).add(p);
      }
    } else {
      g['All'] = src;
    }
    return g;
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
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('New Prompt'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: keyCtrl,
                  decoration: const InputDecoration(labelText: 'Prompt Key'),
                ),
                TextField(
                  controller: langCtrl,
                  decoration: const InputDecoration(labelText: 'Language'),
                ),
                TextField(
                  controller: contentCtrl,
                  decoration: const InputDecoration(labelText: 'Content'),
                  maxLines: 6,
                ),
                if (widget.isAdmin)
                  Row(
                    children: [
                      const Text('Public'),
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
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    if (ok == true) {
      final key = keyCtrl.text.trim();
      final lang = langCtrl.text.trim();
      final content = contentCtrl.text.trim();
      if (!Prompt.isValidPromptKey(key) ||
          !Prompt.isValidLanguage(lang) ||
          content.isEmpty) {
        setState(() {
          _error = 'Invalid input';
        });
        return;
      }
      try {
        await widget.service.createPrompt(
          promptKey: key,
          language: lang,
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
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Make Public'),
        content: Text('Make ${p.promptKey} (${p.language}) public?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirm'),
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
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Prompt'),
        content: Text('Delete ${p.promptKey} (${p.language})?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Wrap(
        alignment: WrapAlignment.start,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12,
        runSpacing: 12,
        children: [
          if (widget.isAdmin) ...[
            const Text('View Public'),
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
          SizedBox(
            width: 260,
            child: TextField(
              controller: _keyCtrl,
              decoration: const InputDecoration(labelText: 'Filter by key'),
              onChanged: (_) => setState(() {}),
            ),
          ),
          SizedBox(
            width: 160,
            child: TextField(
              controller: _langCtrl,
              decoration: const InputDecoration(labelText: 'Language'),
              onChanged: (_) => setState(() {}),
            ),
          ),
          DropdownButton<String>(
            value: _groupBy,
            items: const [
              DropdownMenuItem(value: 'None', child: Text('Group: None')),
              DropdownMenuItem(
                value: 'Language',
                child: Text('Group: Language'),
              ),
              DropdownMenuItem(value: 'Key', child: Text('Group: Key')),
            ],
            onChanged: (v) => setState(() => _groupBy = v ?? 'None'),
          ),
          ElevatedButton(
            onPressed: _createPromptDialog,
            child: const Text('New Prompt'),
          ),
        ],
      ),
    );
  }

  DataTable _table(List<Prompt> src) {
    return DataTable(
      columns: const [
        DataColumn(label: Text('Prompt Key')),
        DataColumn(label: Text('Language')),
        DataColumn(label: Text('Preview')),
        DataColumn(label: Text('Actions')),
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
                          label: Text('Public'),
                          backgroundColor: Colors.greenAccent.withValues(
                            alpha: 0.2,
                          ),
                        )
                      else
                        Chip(label: const Text('Private')),
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
                      ),
                      if (widget.isAdmin && !p.isPublic)
                        IconButton(
                          icon: const Icon(Icons.public),
                          onPressed: () => _makePublic(p),
                        ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deletePrompt(p),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prompts'),
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
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
                      ? const Center(child: Text('No prompts'))
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
}
