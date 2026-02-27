import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:go_router/go_router.dart';

import 'package:writer/models/prompt.dart';
import 'package:writer/services/prompts_service.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/shared/api_exception.dart';
import 'package:writer/shared/widgets/neumorphic_switch.dart';
import 'package:writer/shared/widgets/app_buttons.dart';
import 'package:writer/shared/widgets/responsive_button_row.dart';

const _keys = [
  'system.beta.male',
  'system.beta.female',
  'system.beta.teenager',
  'system.beta.editor',
  'system.qa.direct',
  'system.qa.autogen',
];

const _langs = ['en', 'zh', 'zh-CN'];

class PromptFormScreen extends StatefulWidget {
  final PromptsService service;
  final Prompt? initial;
  final bool defaultPublic;
  final bool isAdmin;
  final bool isSignedIn;
  final bool canEdit;
  const PromptFormScreen({
    super.key,
    required this.service,
    this.initial,
    this.defaultPublic = false,
    this.isAdmin = false,
    this.isSignedIn = true,
    this.canEdit = true,
  });
  @override
  State<PromptFormScreen> createState() => _PromptFormScreenState();
}

class _PromptFormScreenState extends State<PromptFormScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _contentCtrl;
  late final TabController _tabController;
  String _key = _keys.first;
  String _lang = _langs.first;
  bool _isPublic = false;
  bool _saving = false;
  String? _error;
  bool _isDirty = false;

  bool get _isEdit => widget.initial != null;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: 1,
    ); // Default to Edit tab
    _isPublic = widget.initial?.isPublic ?? widget.defaultPublic;
    _key = widget.initial?.promptKey ?? _keys.first;
    _lang = widget.initial?.language ?? _langs.first;
    _contentCtrl = TextEditingController(text: widget.initial?.content ?? '');
    _isDirty = false;
    _contentCtrl.addListener(_updateDirty);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  void _updateDirty() {
    final initialContent = widget.initial?.content ?? '';
    final contentChanged = _contentCtrl.text.trim() != initialContent.trim();
    final keyChanged = _key != (widget.initial?.promptKey ?? _keys.first);
    final langChanged = _lang != (widget.initial?.language ?? _langs.first);
    final publicChanged =
        _isPublic != (widget.initial?.isPublic ?? widget.defaultPublic);
    final dirty =
        contentChanged ||
        (!_isEdit && (keyChanged || langChanged)) ||
        publicChanged;
    if (dirty != _isDirty) {
      setState(() {
        _isDirty = dirty;
      });
    }
  }

  String? _validateKey(String? v) {
    final s = v?.trim() ?? '';
    if (s.isEmpty) return AppLocalizations.of(context)!.required;
    if (!Prompt.isValidPromptKey(s)) {
      return AppLocalizations.of(context)!.invalidKey;
    }
    return null;
  }

  String? _validateLang(String? v) {
    final s = v?.trim() ?? '';
    if (s.isEmpty) return AppLocalizations.of(context)!.required;
    if (!Prompt.isValidLanguage(s)) {
      return AppLocalizations.of(context)!.invalidLanguage;
    }
    return null;
  }

  String? _validateContent(String? v) {
    final s = v?.trim() ?? '';
    if (s.isEmpty) return AppLocalizations.of(context)!.required;
    return null;
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() {
      _error = null;
    });
    if (!_isEdit) {
      final kErr = _validateKey(_key);
      final lErr = _validateLang(_lang);
      final cErr = _validateContent(_contentCtrl.text);
      if (kErr != null || lErr != null || cErr != null) {
        setState(() {
          _error = kErr ?? lErr ?? cErr;
        });
        return;
      }
    } else {
      final cErr = _validateContent(_contentCtrl.text);
      if (cErr != null) {
        setState(() {
          _error = cErr;
        });
        return;
      }
    }
    setState(() {
      _saving = true;
    });
    try {
      if (_isEdit) {
        final res = await widget.service.updatePrompt(
          id: widget.initial!.id,
          content: _contentCtrl.text.trim(),
          isPublic: widget.initial!.isPublic && widget.initial!.userId == null,
        );
        if (mounted) Navigator.pop(context, res);
      } else {
        final res = await widget.service.createPrompt(
          promptKey: _key,
          language: _lang,
          content: _contentCtrl.text.trim(),
          isPublic: _isPublic,
        );
        if (mounted) Navigator.pop(context, res);
      }
    } catch (e) {
      if (e is ApiException && e.statusCode == 401) return;
      if (e is ApiException && e.statusCode == 403) {
        if (!mounted) return;
        if (!widget.isSignedIn) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.notSignedIn),
              action: SnackBarAction(
                label: AppLocalizations.of(context)!.signIn,
                onPressed: () => context.push('/auth'),
              ),
            ),
          );
        } else {
          final msg = Localizations.localeOf(context).languageCode == 'zh'
              ? '您没有权限执行此操作。'
              : 'You don’t have permission to do that.';
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(msg)));
        }
      } else {
        setState(() {
          _error = e.toString();
        });
      }
    } finally {
      setState(() {
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Ensure current key is in the list to prevent crash
    final effectiveKeys = {..._keys};
    if (!_keys.contains(_key)) {
      effectiveKeys.add(_key);
    }

    final effectiveLangs = {..._langs};
    if (!_langs.contains(_lang)) {
      effectiveLangs.add(_lang);
    }

    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? l10n.editPrompt : l10n.newPrompt)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _key,
                      isExpanded: true,
                      items: effectiveKeys
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text(
                                e,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: _isEdit
                          ? null
                          : (v) {
                              setState(() => _key = v ?? _key);
                              _updateDirty();
                            },
                      validator: _isEdit ? null : _validateKey,
                      decoration: InputDecoration(
                        hintText: l10n.promptKey,
                        labelText: l10n.promptKey,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _lang,
                      isExpanded: true,
                      items: effectiveLangs
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text(
                                e,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: _isEdit
                          ? null
                          : (v) {
                              setState(() => _lang = v ?? _lang);
                              _updateDirty();
                            },
                      validator: _isEdit ? null : _validateLang,
                      decoration: InputDecoration(
                        hintText: l10n.language,
                        labelText: l10n.language,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (widget.isAdmin)
                    Row(
                      children: [
                        Text(l10n.publicLabel),
                        const SizedBox(width: 8),
                        NeumorphicSwitch(
                          value: _isPublic,
                          onChanged: (v) {
                            setState(() => _isPublic = v);
                            _updateDirty();
                          },
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 12),
              TabBar(
                controller: _tabController,
                labelColor: Theme.of(context).primaryColor,
                unselectedLabelColor: Colors.grey,
                tabs: [
                  Tab(text: l10n.previewLabel),
                  Tab(text: l10n.edit),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Markdown(
                        data: _contentCtrl.text,
                        padding: const EdgeInsets.all(8),
                      ),
                    ),
                    TextFormField(
                      controller: _contentCtrl,
                      maxLines: null,
                      expands: true,
                      textAlign: TextAlign.start,
                      textAlignVertical: TextAlignVertical.top,
                      readOnly: _isEdit && !widget.isSignedIn,
                      onChanged: (_) => _updateDirty(),
                      validator: _validateContent,
                      decoration: InputDecoration(hintText: l10n.content),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(l10n.charsCount(_contentCtrl.text.length)),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: ResponsiveButtonRow(
                        children: [
                          AppButtons.text(
                            onPressed: _saving
                                ? () {}
                                : () => Navigator.pop(context),
                            label: l10n.cancel,
                          ),
                          AppButtons.primary(
                            onPressed:
                                (_saving ||
                                    !_isDirty ||
                                    (_isEdit && !widget.isSignedIn))
                                ? () {}
                                : _save,
                            label: l10n.save,
                            enabled:
                                !(_saving ||
                                    !_isDirty ||
                                    (_isEdit && !widget.isSignedIn)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              if (_isEdit && !widget.isSignedIn)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    AppLocalizations.of(context)!.notSignedIn,
                    style: const TextStyle(color: Colors.orange),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
