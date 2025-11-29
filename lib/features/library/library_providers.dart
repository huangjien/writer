import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final downloadStateProvider = StateProvider<Map<String, bool>>((ref) => {});
final removedNovelIdsProvider = StateProvider<Set<String>>((ref) => <String>{});
final downloadFeatureFlagProvider = Provider<bool>((ref) => false);
