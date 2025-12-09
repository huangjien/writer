import 'package:flutter/material.dart';

import '../models/prompt.dart';
import '../services/prompts_service.dart';
import '../l10n/app_localizations.dart';

const _keys = [
  'system.beta.male',
  'system.beta.female',
  'system.beta.teenager',
  'system.beta.editor',
];

const _langs = ['en', 'zh', 'zh-CN'];

class PromptFormScreen extends StatefulWidget {
  final PromptsService service;
  final Prompt? initial;
  final bool defaultPublic;
  final bool isAdmin;
  const PromptFormScreen({
    super.key,
    required this.service,
    this.initial,
    this.defaultPublic = false,
    this.isAdmin = false,
  });
  @override
  State<PromptFormScreen> createState() => _PromptFormScreenState();
}

class _PromptFormScreenState extends State<PromptFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _contentCtrl;
  String _key = _keys.first;
  String _lang = _langs.first;
  bool _isPublic = false;
  bool _saving = false;
  String? _error;

  bool get _isEdit => widget.initial != null;

  @override
  void initState() {
    super.initState();
    _isPublic = widget.initial?.isPublic ?? widget.defaultPublic;
    _key = widget.initial?.promptKey ?? _keys.first;
    _lang = widget.initial?.language ?? _langs.first;
    _contentCtrl = TextEditingController(text: widget.initial?.content ?? '');
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
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final preview = _contentCtrl.text;
    final l10n = AppLocalizations.of(context)!;
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
                      items: _keys
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                      onChanged: _isEdit
                          ? null
                          : (v) => setState(() => _key = v ?? _key),
                      validator: _isEdit ? null : _validateKey,
                      decoration: InputDecoration(labelText: l10n.promptKey),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 180,
                    child: DropdownButtonFormField<String>(
                      initialValue: _lang,
                      items: _langs
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                      onChanged: _isEdit
                          ? null
                          : (v) => setState(() => _lang = v ?? _lang),
                      validator: _isEdit ? null : _validateLang,
                      decoration: InputDecoration(labelText: l10n.language),
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (widget.isAdmin)
                    Row(
                      children: [
                        Text(l10n.publicLabel),
                        Switch(
                          value: _isPublic,
                          onChanged: (v) => setState(() => _isPublic = v),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: TextFormField(
                  controller: _contentCtrl,
                  maxLines: null,
                  expands: true,
                  onChanged: (_) => setState(() {}),
                  validator: _validateContent,
                  decoration: InputDecoration(labelText: l10n.content),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(l10n.charsCount(_contentCtrl.text.length)),
                  const Spacer(),
                  TextButton(
                    onPressed: _saving ? null : () => Navigator.pop(context),
                    child: Text(l10n.cancel),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _saving ? null : _save,
                    child: Text(l10n.save),
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
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: SizedBox(width: double.infinity, child: Text(preview)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
