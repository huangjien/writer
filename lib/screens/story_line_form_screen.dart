import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/theme/design_tokens.dart';
import 'package:writer/shared/widgets/neumorphic_checkbox.dart';
import 'package:writer/shared/widgets/app_buttons.dart';
import 'package:writer/shared/widgets/app_dialog.dart';
import 'package:writer/shared/widgets/responsive_button_row.dart';
import 'package:writer/models/story_line.dart';
import 'package:writer/shared/api_exception.dart';
import 'package:writer/state/story_line_providers.dart';
import 'package:writer/state/providers.dart';
import 'package:writer/l10n/app_localizations.dart';

class StoryLineFormScreen extends ConsumerStatefulWidget {
  final StoryLine? initial;
  const StoryLineFormScreen({super.key, this.initial});
  @override
  ConsumerState<StoryLineFormScreen> createState() =>
      _StoryLineFormScreenState();
}

class _StoryLineFormScreenState extends ConsumerState<StoryLineFormScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _contentCtrl;
  late final TextEditingController _usageCtrl;
  late final TabController _tabController;
  late String _language;
  late bool _isPublic;
  late bool _locked;
  bool _saving = false;
  bool _isDirty = false;
  String? _error;

  bool get _isEdit => widget.initial != null;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
    _language = widget.initial?.language ?? 'en';
    _isPublic = widget.initial?.isPublic ?? true;
    _locked = widget.initial?.locked ?? false;

    _titleCtrl.addListener(_checkDirty);
    _descCtrl.addListener(_checkDirty);
    _contentCtrl.addListener(_checkDirty);
    _usageCtrl.addListener(_checkDirty);
  }

  void _checkDirty() {
    final initial = widget.initial;

    final newTitle = _titleCtrl.text;
    final newDesc = _descCtrl.text;
    final newContent = _contentCtrl.text;
    final newUsage = _usageCtrl.text;
    final newLang = _language;
    final newPublic = _isPublic;
    final newLocked = _locked;

    final oldTitle = initial?.title ?? '';
    final oldDesc = initial?.description ?? '';
    final oldContent = initial?.content ?? '';
    final oldUsage = initial?.usageRules != null
        ? const JsonEncoder.withIndent('  ').convert(initial!.usageRules)
        : '';
    final oldLang = initial?.language ?? 'en';
    final oldPublic = initial?.isPublic ?? true;
    final oldLocked = initial?.locked ?? false;

    final isDirty =
        newTitle.trim() != oldTitle ||
        newDesc.trim() != oldDesc ||
        newContent.trim() != oldContent ||
        newUsage.trim() != oldUsage ||
        newLang != oldLang ||
        newPublic != oldPublic ||
        newLocked != oldLocked;

    if (_isDirty != isDirty) {
      setState(() => _isDirty = isDirty);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _contentCtrl.dispose();
    _usageCtrl.dispose();
    super.dispose();
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

  Future<void> _applyAi() async {
    if (_saving) return;
    setState(() {
      _error = null;
      _saving = true;
    });
    try {
      final svc = ref.read(storyLinesServiceRefProvider);
      final usage = _parseUsageForAi(_usageCtrl.text);
      final language = _language.trim().isEmpty ? null : _language.trim();
      final improved = await svc.improveStoryLine(
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
          _language = langOut.trim();
        }
      });
      _checkDirty();
    } catch (e) {
      if (e is ApiException && e.statusCode == 401) return;
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
      builder: (ctx) => AppDialog(
        title: l10n.confirmDelete,
        content: Text(l10n.confirmDeleteDescription(widget.initial!.title)),
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
    if (ok != true) return;
    setState(() {
      _error = null;
      _saving = true;
    });
    final svc = ref.read(storyLinesServiceRefProvider);
    try {
      final success = await svc.deleteStoryLine(widget.initial!.id);
      if (!success) {
        if (!mounted) return;
        final l10n = AppLocalizations.of(context)!;
        setState(() {
          _error = l10n.deleteFailed;
        });
        return;
      }
      if (mounted) {
        Navigator.pop(context, null);
      }
    } catch (e) {
      if (e is ApiException && e.statusCode == 401) return;
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
    final svc = ref.read(storyLinesServiceRefProvider);
    try {
      final usage = _parseUsage(_usageCtrl.text) ?? widget.initial?.usageRules;
      final language = _language.trim().isEmpty ? null : _language.trim();
      if (_isEdit) {
        final res = await svc.updateStoryLine(
          id: widget.initial!.id,
          title: _titleCtrl.text.trim(),
          description: _descCtrl.text.trim().isEmpty
              ? null
              : _descCtrl.text.trim(),
          content: _contentCtrl.text.trim(),
          usageRules: usage,
          language: language,
          isPublic: _isPublic,
          locked: _locked,
        );
        if (mounted) Navigator.pop(context, res);
      } else {
        final res = await svc.createStoryLine(
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
      if (e is ApiException && e.statusCode == 401) return;
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
    final theme = Theme.of(context);
    final isSignedIn = ref.watch(isSignedInProvider);
    final isAdmin = ref.watch(isAdminProvider);
    final currentUser = ref.watch(currentUserProvider).asData?.value;
    final ownerId = widget.initial?.ownerId;
    final canDelete =
        _isEdit &&
        isSignedIn &&
        !_locked &&
        !_saving &&
        (isAdmin || (ownerId != null && ownerId == currentUser?.id));
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? l10n.editStoryLineTitle : l10n.newStoryLineTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 860;
                  final titleField = TextFormField(
                    controller: _titleCtrl,
                    decoration: InputDecoration(
                      hintText: l10n.titleLabel,
                      labelText: l10n.titleLabel,
                    ),
                    validator: _required,
                    enabled: !_locked && !_saving,
                  );
                  final languageField = DropdownButtonFormField<String>(
                    key: ValueKey(_language),
                    initialValue: _language,
                    isExpanded: true,
                    decoration: InputDecoration(
                      hintText: l10n.languageLabel(''),
                      labelText: l10n.languageLabel(''),
                    ),
                    items: [
                      DropdownMenuItem(value: 'en', child: Text(l10n.english)),
                      DropdownMenuItem(value: 'zh', child: Text(l10n.chinese)),
                    ],
                    onChanged: (!_locked && !_saving)
                        ? (v) {
                            if (v != null) {
                              setState(() => _language = v);
                              _checkDirty();
                            }
                          }
                        : null,
                  );
                  final publicToggle = Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      NeumorphicCheckbox(
                        value: _isPublic,
                        onChanged: _saving || _locked
                            ? null
                            : (v) {
                                if (v == null) return;
                                setState(() {
                                  _isPublic = v;
                                });
                                _checkDirty();
                              },
                      ),
                      const SizedBox(width: 8),
                      Text(l10n.publicStoryLineLabel),
                    ],
                  );
                  final lockToggle = InkWell(
                    onTap: _saving
                        ? null
                        : () {
                            setState(() => _locked = !_locked);
                            _checkDirty();
                          },
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _locked ? Icons.lock : Icons.lock_open,
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(_locked ? l10n.lockedLabel : l10n.unlockedLabel),
                        ],
                      ),
                    ),
                  );

                  if (wide) {
                    return Row(
                      children: [
                        SizedBox(width: 260, child: titleField),
                        const SizedBox(width: 12),
                        SizedBox(width: 160, child: languageField),
                        const SizedBox(width: 12),
                        publicToggle,
                        if (_isEdit) ...[const SizedBox(width: 12), lockToggle],
                      ],
                    );
                  }

                  return Column(
                    children: [
                      titleField,
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(width: 160, child: languageField),
                            const SizedBox(width: 12),
                            publicToggle,
                            if (_isEdit) ...[
                              const SizedBox(width: 12),
                              lockToggle,
                            ],
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descCtrl,
                decoration: InputDecoration(
                  hintText: l10n.descriptionLabel,
                  labelText: l10n.descriptionLabel,
                ),
                enabled: !_locked && !_saving,
              ),
              const SizedBox(height: 12),
              TabBar(
                controller: _tabController,
                labelColor: theme.primaryColor,
                unselectedLabelColor: Colors.grey,
                tabs: [
                  Tab(text: l10n.previewLabel),
                  Tab(text: l10n.edit),
                  Tab(text: l10n.usageRulesLabel),
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
                      validator: _required,
                      decoration: InputDecoration(hintText: l10n.content),
                      enabled: !_locked && !_saving,
                    ),
                    TextFormField(
                      controller: _usageCtrl,
                      maxLines: null,
                      expands: true,
                      textAlign: TextAlign.start,
                      textAlignVertical: TextAlignVertical.top,
                      decoration: InputDecoration(
                        hintText: l10n.usageRulesLabel,
                      ),
                      enabled: !_locked && !_saving,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              ResponsiveButtonRow(
                alignment: WrapAlignment.start,
                children: [
                  AppButtons.text(
                    onPressed: _saving ? () {} : () => Navigator.pop(context),
                    label: l10n.cancel,
                    enabled: !_saving,
                  ),
                  if (_isEdit)
                    AppButtons.text(
                      onPressed: canDelete ? _delete : () {},
                      label: l10n.delete,
                      color: canDelete ? AppColors.error : null,
                      enabled: canDelete,
                    ),
                  AppButtons.secondary(
                    onPressed: _saving || _locked ? () {} : _applyAi,
                    label: l10n.aiButton,
                    isLoading: _saving,
                    enabled: !(_saving || _locked),
                  ),
                  AppButtons.primary(
                    onPressed: (_saving || !_isDirty) ? () {} : _save,
                    icon: Icons.save,
                    label: l10n.save,
                    isLoading: _saving,
                    enabled: !(_saving || !_isDirty),
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
