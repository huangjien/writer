import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../state/providers.dart';

final downloadStateProvider = StateProvider<Map<String, bool>>((ref) => {});
final removedNovelIdsProvider = StateProvider<Set<String>>((ref) => <String>{});
final downloadFeatureFlagProvider = Provider<bool>((ref) => false);

/// IDs of novels that have content downloaded locally
final downloadedNovelIdsProvider = FutureProvider<Set<String>>((ref) async {
  final local = ref.watch(localStorageRepositoryProvider);
  return local.getDownloadedNovelIds();
});
