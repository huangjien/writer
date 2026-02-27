import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/models/prompt.dart';
import 'package:writer/services/prompts_service.dart';
import 'package:writer/shared/api_exception.dart';
import 'package:writer/shared/constants.dart';
import 'package:writer/shared/widgets/app_buttons.dart';
import 'package:writer/shared/widgets/app_dialog.dart';
import 'package:writer/shared/widgets/error_state.dart';
import 'package:writer/shared/widgets/loading/skeleton_list_items.dart';
import 'package:writer/shared/widgets/neumorphic_switch.dart';
import 'package:writer/shared/widgets/neumorphic_textfield.dart';
import 'package:writer/theme/design_tokens.dart';

const int _previewLen = kPreviewLenShort;
const int _searchDebounceMs = kSearchDebounceMs;
const int _searchMinLen = kSearchMinLen;

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
      if (e is ApiException && e.statusCode == 401) return;
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
      if (e is ApiException && e.statusCode == 401) return;
      _showError(e.toString());
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  String _preview(String s) {
    final firstLine = s.split('\n').first.trim();
    if (firstLine.length <= _previewLen) return firstLine;
    return '${firstLine.substring(0, _previewLen)}…';
  }

  void _showError(String message) {
    // Strip "ApiException(400): " prefix if present for cleaner display
    final cleanMsg = message.replaceFirst(
      RegExp(r'^ApiException\(\d+\): '),
      '',
    );
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (ctx) => AppDialog(
        title: l10n.error,
        content: SelectableText(cleanMsg),
        actions: [
          AppButtons.secondary(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: cleanMsg));
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(l10n.copiedToClipboard)));
            },
            label: l10n.copy,
            icon: Icons.copy,
          ),
          AppButtons.text(
            onPressed: () => Navigator.pop(ctx),
            label: l10n.close,
          ),
        ],
      ),
    );
  }

  Future<void> _createPromptDialog() async {
    final keyCtrl = TextEditingController();
    final langCtrl = TextEditingController();
    final contentCtrl = TextEditingController();
    bool makePublic = _showPublic;
    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateSB) => AppDialog(
          title: l10n.newPrompt,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.promptKey, style: Theme.of(ctx).textTheme.labelLarge),
              const SizedBox(height: Spacing.xs),
              NeumorphicTextField(
                controller: keyCtrl,
                hintText: l10n.promptKey,
              ),
              const SizedBox(height: Spacing.m),
              Text(l10n.language, style: Theme.of(ctx).textTheme.labelLarge),
              const SizedBox(height: Spacing.xs),
              NeumorphicTextField(
                controller: langCtrl,
                hintText: l10n.language,
              ),
              const SizedBox(height: Spacing.m),
              Text(l10n.content, style: Theme.of(ctx).textTheme.labelLarge),
              const SizedBox(height: Spacing.xs),
              NeumorphicTextField(
                controller: contentCtrl,
                hintText: l10n.content,
                maxLines: 6,
              ),
              if (widget.isAdmin) ...[
                const SizedBox(height: Spacing.m),
                Row(
                  children: [
                    Expanded(child: Text(l10n.publicLabel)),
                    NeumorphicSwitch(
                      value: makePublic,
                      onChanged: (v) => setStateSB(() => makePublic = v),
                    ),
                  ],
                ),
              ],
            ],
          ),
          actions: [
            AppButtons.text(
              onPressed: () => Navigator.pop(ctx, false),
              label: l10n.cancel,
            ),
            AppButtons.primary(
              onPressed: () => Navigator.pop(ctx, true),
              label: l10n.save,
            ),
          ],
        ),
      ),
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
        _showError(e.toString());
      }
    }
  }

  Future<void> _makePublic(Prompt p) async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AppDialog(
        title: l10n.makePublic,
        content: Text(l10n.makePublicPromptConfirm(p.promptKey, p.language)),
        actions: [
          AppButtons.text(
            onPressed: () => Navigator.pop(ctx, false),
            label: l10n.cancel,
          ),
          AppButtons.primary(
            onPressed: () => Navigator.pop(ctx, true),
            label: l10n.confirm,
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
        _showError(e.toString());
      }
    }
  }

  Future<void> _deletePrompt(Prompt p) async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AppDialog(
        title: l10n.delete,
        content: Text(l10n.deletePromptConfirm(p.promptKey, p.language)),
        actions: [
          AppButtons.text(
            onPressed: () => Navigator.pop(ctx, false),
            label: l10n.cancel,
          ),
          AppButtons.text(
            onPressed: () => Navigator.pop(ctx, true),
            label: l10n.delete,
            color: Theme.of(ctx).colorScheme.error,
          ),
        ],
      ),
    );
    if (ok == true) {
      try {
        await widget.service.deletePrompt(p.id);
        await _load();
      } catch (e) {
        _showError(e.toString());
      }
    }
  }

  DateTime? _lastRowTapAt;
  String? _lastRowTapId;

  void _onRowTap(Prompt p) {
    final now = DateTime.now();
    if (_lastRowTapId == p.id &&
        _lastRowTapAt != null &&
        now.difference(_lastRowTapAt!) < kDoubleTapThreshold) {
      context.push('/prompt_form', extra: p);
      _lastRowTapAt = null;
      _lastRowTapId = null;
    } else {
      _lastRowTapAt = now;
      _lastRowTapId = p.id;
    }
  }

  Widget _filters(int count) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                labelText: l10n.searchLabel,
                suffixIconConstraints: const BoxConstraints(
                  minWidth: 0,
                  minHeight: 0,
                ),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? AppButtons.icon(
                        iconData: Icons.clear,
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() {});
                        },
                        tooltip: 'Clear search',
                        focusPadding: EdgeInsets.zero,
                      )
                    : null,
              ),
              onChanged: (_) {
                setState(() {}); // Rebuild to show/hide clear button
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
            const SizedBox(width: 16),
            Row(
              children: [
                Text(l10n.viewPublic, style: theme.textTheme.bodyMedium),
                const SizedBox(width: 8),
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
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPromptItem(BuildContext context, Prompt p) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.titleMedium;
    final subtitleStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onRowTap(p),
        hoverColor: theme.colorScheme.surfaceContainerHighest,
        child: ListTile(
          title: Row(
            children: [
              Text(p.promptKey, style: titleStyle),
              const SizedBox(width: 8),
              Chip(
                label: Text(
                  p.isPublic ? l10n.publicLabel : l10n.privateLabel,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: p.isPublic
                        ? theme.colorScheme.onPrimaryContainer
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                backgroundColor: p.isPublic
                    ? theme.colorScheme.primaryContainer
                    : theme.colorScheme.surfaceContainerHighest,
              ),
            ],
          ),
          subtitle: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '${l10n.language}: ${p.language}',
                  style: subtitleStyle,
                ),
                const TextSpan(text: '  •  '),
                TextSpan(text: _preview(p.content), style: subtitleStyle),
              ],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            final r = GoRouter.of(context);
            if (r.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
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
          ? Center(
              child: ListView.builder(
                itemCount: 5,
                itemBuilder: (context, index) => const PromptItemSkeleton(),
              ),
            )
          : _error != null
          ? ErrorState(message: _error!, onRetry: _load)
          : Column(
              children: [
                _filters(_items.length),
                Expanded(
                  child: _items.isEmpty
                      ? Center(child: Text(l10n.noPrompts))
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemBuilder: (ctx, i) {
                            return _buildPromptItem(ctx, _items[i]);
                          },
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 8),
                          itemCount: _items.length,
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
