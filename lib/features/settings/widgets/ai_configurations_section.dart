import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../state/agents_config_providers.dart';
import '../../ai_chat/services/agents_config_service.dart';

class AiConfigurationsSection extends ConsumerWidget {
  const AiConfigurationsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final types = const ['respond', 'qa', 'embedding'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AI Configurations',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        ...types.map((t) => _AgentTypePanel(type: t)),
      ],
    );
  }
}

class _AgentTypePanel extends ConsumerStatefulWidget {
  const _AgentTypePanel({required this.type});
  final String type;

  @override
  ConsumerState<_AgentTypePanel> createState() => _AgentTypePanelState();
}

class _AgentTypePanelState extends ConsumerState<_AgentTypePanel> {
  final _modelController = TextEditingController();
  final _tempController = TextEditingController();

  @override
  void dispose() {
    _modelController.dispose();
    _tempController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eff = ref.watch(effectiveAgentConfigProvider(widget.type));
    final list = ref.watch(agentConfigsListProvider(widget.type));
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.type.toUpperCase()),
            const SizedBox(height: 8),
            eff.when(
              data: (cfg) {
                final model = (cfg?['model'] as String?) ?? '';
                final temp = (cfg?['temperature'] as num?)?.toString() ?? '0';
                _modelController.text = model;
                _tempController.text = temp;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _modelController,
                      decoration: const InputDecoration(labelText: 'Model'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _tempController,
                      decoration: const InputDecoration(
                        labelText: 'Temperature',
                      ),
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            final svc = ref.read(agentsConfigServiceProvider);
                            final payload = {
                              'name': 'mine',
                              'model': _modelController.text.trim(),
                              'temperature':
                                  double.tryParse(
                                    _tempController.text.trim(),
                                  ) ??
                                  0,
                              'system_prompt':
                                  (cfg?['system_prompt'] as String?) ?? '',
                            };
                            final created = await svc.saveMyVersion(
                              widget.type,
                              payload,
                            );
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  created == null ? 'Save failed' : 'Saved',
                                ),
                              ),
                            );
                            ref.invalidate(
                              effectiveAgentConfigProvider(widget.type),
                            );
                            ref.invalidate(
                              agentConfigsListProvider(widget.type),
                            );
                          },
                          child: const Text('Save My Version'),
                        ),
                        const SizedBox(width: 12),
                        list.when(
                          data: (items) {
                            final mine = items
                                .where((m) => (m['user_id'] as String?) != null)
                                .toList();
                            final id = mine.isNotEmpty
                                ? (mine.first['id'] as String?)
                                : null;
                            return TextButton(
                              onPressed: id == null
                                  ? null
                                  : () async {
                                      final svc = ref.read(
                                        agentsConfigServiceProvider,
                                      );
                                      final ok = await svc.resetToPublic(id);
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            ok
                                                ? 'Reset to public'
                                                : 'Reset failed',
                                          ),
                                        ),
                                      );
                                      ref.invalidate(
                                        effectiveAgentConfigProvider(
                                          widget.type,
                                        ),
                                      );
                                      ref.invalidate(
                                        agentConfigsListProvider(widget.type),
                                      );
                                    },
                              child: const Text('Reset to Public'),
                            );
                          },
                          loading: () => const SizedBox.shrink(),
                          error: (e, st) => const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ],
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (e, st) => const Text('Failed to load config'),
            ),
          ],
        ),
      ),
    );
  }
}
