import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  final isEnabled = ref.watch(supabaseEnabledProvider);
  if (!isEnabled) return EditRole.none;
  final client = ref.watch(supabaseClientProvider);
  final userId = client.auth.currentUser?.id;
  if (userId == null) return EditRole.none;

  // Check ownership via secure RPC to avoid RLS issues on private novels
  try {
    final dynamic own = await client.rpc(
      'is_owner',
      params: {'novel_id': novelId},
    );
    final bool isOwner = own == true || own == 1;
    if (isOwner) return EditRole.owner;
  } catch (_) {
    // Fall through to member check if RPC not available
  }

  // Check contributor membership via RPC
  try {
    final dynamic res = await client.rpc(
      'is_member',
      params: {'novel_id': novelId},
    );
    final bool isMember = res == true || res == 1;
    if (isMember) return EditRole.contributor;
  } catch (_) {
    // Ignore errors
  }

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
