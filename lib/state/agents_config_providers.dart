import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/features/ai_chat/services/agents_config_service.dart';

final effectiveAgentConfigProvider =
    FutureProvider.family<Map<String, dynamic>?, String>((ref, type) async {
      final svc = ref.watch(agentsConfigServiceProvider);
      return svc.getEffective(type);
    });

final agentConfigsListProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((
      ref,
      type,
    ) async {
      final svc = ref.watch(agentsConfigServiceProvider);
      return svc.list(type);
    });
