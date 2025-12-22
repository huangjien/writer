import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/remote_repository.dart';
import 'providers.dart';

/// Granular edit role used to gate UI controls.
/// - owner: full edit permissions on the novel and its chapters
/// - contributor: edit permissions on chapters within the assigned novel
/// - none: no edit permissions
enum EditRole { none, owner, contributor }

/// Computes the current user's edit role for a given novel.
final editRoleProvider = FutureProvider.family<EditRole, String>((
  ref,
  novelId,
) async {
  ref.watch(authStateProvider);
  final isSignedIn = ref.watch(isSignedInProvider);
  if (!isSignedIn) return EditRole.none;

  final remote = ref.watch(remoteRepositoryProvider);
  try {
    final res = await remote.get('permissions/novels/$novelId');
    if (res is Map) {
      final role = res['role'];
      if (role == 'owner') return EditRole.owner;
      if (role == 'contributor') return EditRole.contributor;
    }
  } catch (_) {}
  return EditRole.none;
});

/// Computes whether the current user can edit a given novel.
/// A user can edit if they are the owner of the novel or a contributor.
final editPermissionsProvider = FutureProvider.family<bool, String>((
  ref,
  novelId,
) async {
  // Re-run when auth changes to keep permissions accurate.
  ref.watch(authStateProvider);
  final role = await ref.watch(editRoleProvider(novelId).future);
  return role != EditRole.none;
});
