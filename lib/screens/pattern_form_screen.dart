import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/pattern.dart';
import '../state/pattern_providers.dart';
import '../state/supabase_config.dart';
import '../l10n/app_localizations.dart';

class PatternFormScreen extends ConsumerStatefulWidget {
  final Pattern? initial;
  const PatternFormScreen({super.key, this.initial});
  @override
  ConsumerState<PatternFormScreen> createState() => _PatternFormScreenState();
}

class _PatternFormScreenState extends ConsumerState<PatternFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _contentCtrl;
  late final TextEditingController _usageCtrl;
  late final TextEditingController _languageCtrl;
  late bool _isPublic;
  bool _saving = false;
  String? _error;
  bool _canDelete = false;

  bool get _isEdit => widget.initial != null;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.initial?.title ?? '');
    _descCtrl = TextEditingController(text: widget.initial?.description ?? '');
    _contentCtrl = TextEditingController(text: widget.initial?.content ?? '');
    _usageCtrl = TextEditingController(
      text: widget.initial?.usageRules != null
          ? const JsonEncoder.withIndent(
              '  ',
            ).convert(widget.initial!.usageRules)
          : '',
    );
    _languageCtrl = TextEditingController(
      text: widget.initial?.language ?? 'en',
    );
    _isPublic = widget.initial?.isPublic ?? true;
    _canDelete = _computeCanDelete();
  }

  String? _required(String? v) {
    final s = v?.trim() ?? '';
    if (s.isEmpty) return AppLocalizations.of(context)!.required;
    return null;
  }

  Map<String, dynamic>? _parseUsage(String s) {
    final t = s.trim();
    if (t.isEmpty) return null;
    try {
      final obj = jsonDecode(t);
      return obj is Map<String, dynamic> ? obj : Map<String, dynamic>.from(obj);
    } catch (e) {
      setState(() {
        _error = 'Invalid JSON';
      });
      return null;
    }
  }

  Map<String, dynamic>? _parseUsageForAi(String s) {
    final t = s.trim();
    if (t.isEmpty) return null;
    try {
      final obj = jsonDecode(t);
      return obj is Map<String, dynamic> ? obj : Map<String, dynamic>.from(obj);
    } catch (_) {
      return null;
    }
  }

  bool _computeCanDelete() {
    final initial = widget.initial;
    if (initial == null) return false;
    if (!supabaseEnabled) return false;
    try {
      final client = Supabase.instance.client;
      final user = client.auth.currentUser;
      if (user == null) return false;
      final userId = user.id;
      final dynamic appMeta = user.appMetadata;
      final dynamic userMeta = user.userMetadata;
      if (appMeta == null && userMeta == null) {
        return false;
      }
      bool admin = false;
      dynamic roles = appMeta != null ? appMeta['roles'] : null;
      roles ??= userMeta != null ? userMeta['roles'] : null;
      if (roles is List) {
        admin = roles.any((r) => r.toString().toLowerCase() == 'admin');
      }
      dynamic role = appMeta != null ? appMeta['role'] : null;
      role ??= userMeta != null ? userMeta['role'] : null;
      if (!admin && role is String) {
        admin = role.toLowerCase() == 'admin';
      }
      dynamic flag = appMeta != null ? appMeta['isAdmin'] : null;
      flag ??= userMeta != null ? userMeta['isAdmin'] : null;
      if (!admin && flag is bool) {
        admin = flag;
      }
      if (admin) return true;
      final ownerId = initial.ownerId;
      if (ownerId == null) return false;
      return ownerId == userId;
    } catch (_) {
      return false;
    }
  }

  Future<void> _applyAi() async {
    if (_saving) return;
    setState(() {
      _error = null;
      _saving = true;
    });
    try {
      final svc = ref.read(patternsServiceRefProvider);
      final usage = _parseUsageForAi(_usageCtrl.text);
      final langText = _languageCtrl.text.trim();
      final language = langText.isEmpty ? null : langText;
      final improved = await svc.improvePattern(
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim().isEmpty
            ? null
            : _descCtrl.text.trim(),
        content: _contentCtrl.text.trim(),
        usageRules: usage,
        language: language,
      );
      final title = improved['title'];
      final desc = improved['description'];
      final content = improved['content'];
      final usageOut = improved['usage_rules'];
      final langOut = improved['language'];
      setState(() {
        if (title is String && title.trim().isNotEmpty) {
          _titleCtrl.text = title.trim();
        }
        if (desc is String) {
          _descCtrl.text = desc;
        }
        if (content is String && content.trim().isNotEmpty) {
          _contentCtrl.text = content;
        }
        if (usageOut is Map<String, dynamic>) {
          _usageCtrl.text = const JsonEncoder.withIndent(
            '  ',
          ).convert(usageOut);
        }
        if (langOut is String && langOut.trim().isNotEmpty) {
          _languageCtrl.text = langOut.trim();
        }
      });
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

  Future<void> _delete() async {
    if (!_isEdit || _saving) return;
    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.confirmDelete),
        content: Text(l10n.confirmDeleteDescription(widget.initial!.title)),
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
    if (ok != true) return;
    setState(() {
      _error = null;
      _saving = true;
    });
    final svc = ref.read(patternsServiceRefProvider);
    try {
      final success = await svc.deletePattern(widget.initial!.id);
      if (!success) {
        setState(() {
          _error = 'Delete failed';
        });
        return;
      }
      if (mounted) {
        Navigator.pop(context, null);
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

  Future<void> _save() async {
    if (_saving) return;
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _error = null;
      _saving = true;
    });
    final svc = ref.read(patternsServiceRefProvider);
    try {
      final usage = _parseUsage(_usageCtrl.text) ?? widget.initial?.usageRules;
      final langText = _languageCtrl.text.trim();
      final language = langText.isEmpty ? null : langText;
      if (_isEdit) {
        final res = await svc.updatePattern(
          id: widget.initial!.id,
          title: _titleCtrl.text.trim(),
          description: _descCtrl.text.trim().isEmpty
              ? null
              : _descCtrl.text.trim(),
          content: _contentCtrl.text.trim(),
          usageRules: usage,
          language: language,
          isPublic: _isPublic,
        );
        if (mounted) Navigator.pop(context, res);
      } else {
        final res = await svc.createPattern(
          title: _titleCtrl.text.trim(),
          description: _descCtrl.text.trim().isEmpty
              ? null
              : _descCtrl.text.trim(),
          content: _contentCtrl.text.trim(),
          usageRules: usage,
          language: language,
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
    final l10n = AppLocalizations.of(context)!;
    final isLocked = widget.initial?.locked == true;
    final canDelete = _isEdit && _canDelete && !isLocked && !_saving;
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Edit Pattern' : 'New Pattern')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _titleCtrl,
                      decoration: InputDecoration(labelText: l10n.titleLabel),
                      validator: _required,
                      enabled: !isLocked && !_saving,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _descCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                      enabled: !isLocked && !_saving,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  SizedBox(
                    width: 120,
                    child: TextFormField(
                      controller: _languageCtrl,
                      decoration: const InputDecoration(labelText: 'Language'),
                      enabled: !isLocked && !_saving,
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (_isEdit)
                    Row(
                      children: [
                        Icon(isLocked ? Icons.lock : Icons.lock_open, size: 18),
                        const SizedBox(width: 4),
                        Text(isLocked ? 'Locked' : 'Unlocked'),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Checkbox(
                    value: _isPublic,
                    onChanged: _saving
                        ? null
                        : (v) {
                            if (v == null) return;
                            setState(() {
                              _isPublic = v;
                            });
                          },
                  ),
                  const SizedBox(width: 4),
                  const Text('Public pattern'),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: TextFormField(
                  controller: _contentCtrl,
                  maxLines: null,
                  expands: true,
                  validator: _required,
                  decoration: InputDecoration(labelText: l10n.content),
                  enabled: !isLocked && !_saving,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _usageCtrl,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: 'Usage Rules (JSON)',
                ),
                enabled: !isLocked && !_saving,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  TextButton(
                    onPressed: _saving ? null : () => Navigator.pop(context),
                    child: Text(l10n.cancel),
                  ),
                  const SizedBox(width: 8),
                  if (_isEdit)
                    TextButton(
                      onPressed: canDelete ? _delete : null,
                      child: Text(l10n.delete),
                    ),
                  if (_isEdit) const SizedBox(width: 8),
                  TextButton(
                    onPressed: _saving || isLocked ? null : _applyAi,
                    child: const Text('AI'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _saving || isLocked ? null : _save,
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
            ],
          ),
        ),
      ),
    );
  }
}
