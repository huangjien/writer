import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pattern.dart';
import '../state/pattern_providers.dart';
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
  bool _saving = false;
  String? _error;

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
      if (_isEdit) {
        final res = await svc.updatePattern(
          id: widget.initial!.id,
          title: _titleCtrl.text.trim(),
          description: _descCtrl.text.trim().isEmpty
              ? null
              : _descCtrl.text.trim(),
          content: _contentCtrl.text.trim(),
          usageRules: usage,
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
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _descCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                    ),
                  ),
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
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _usageCtrl,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: 'Usage Rules (JSON)',
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
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
            ],
          ),
        ),
      ),
    );
  }
}
