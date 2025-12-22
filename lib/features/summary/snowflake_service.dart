import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/repositories/remote_repository.dart';
import '../../models/snowflake.dart';

class SnowflakeService {
  final RemoteRepository remote;

  SnowflakeService(this.remote);

  Future<SnowflakeRefinementOutput?> refineSummary(
    SnowflakeRefinementInput input,
  ) async {
    try {
      final res = await remote.post('snowflake/refine', input.toJson());
      if (res is Map<String, dynamic>) {
        return SnowflakeRefinementOutput.fromJson(res);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}

final snowflakeServiceProvider = Provider<SnowflakeService>((ref) {
  return SnowflakeService(ref.watch(remoteRepositoryProvider));
});
