import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/models/token_usage.dart';
import 'package:writer/repositories/remote_repository.dart';

final currentMonthUsageProvider = FutureProvider<TokenUsage?>((ref) async {
  final repository = ref.watch(remoteRepositoryProvider);
  return repository.getCurrentMonthUsage();
});

final usageHistoryProvider =
    FutureProvider.family<TokenUsageHistory?, UsageHistoryParams>((
      ref,
      params,
    ) async {
      final repository = ref.watch(remoteRepositoryProvider);
      return repository.getUsageHistory(
        startDate: params.startDate,
        endDate: params.endDate,
        limit: params.limit,
        offset: params.offset,
      );
    });

class UsageHistoryParams {
  final String? startDate;
  final String? endDate;
  final int limit;
  final int offset;

  UsageHistoryParams({
    this.startDate,
    this.endDate,
    this.limit = 100,
    this.offset = 0,
  });

  UsageHistoryParams copyWith({
    String? startDate,
    String? endDate,
    int? limit,
    int? offset,
  }) {
    return UsageHistoryParams(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UsageHistoryParams &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.limit == limit &&
        other.offset == offset;
  }

  @override
  int get hashCode {
    return startDate.hashCode ^
        endDate.hashCode ^
        limit.hashCode ^
        offset.hashCode;
  }
}
