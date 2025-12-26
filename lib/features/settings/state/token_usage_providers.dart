import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/models/token_usage.dart';
import 'package:writer/repositories/remote_repository.dart';

final currentMonthUsageProvider = FutureProvider<TokenUsage?>((ref) async {
  final repository = ref.watch(remoteRepositoryProvider);
  return repository.getCurrentMonthUsage();
});
