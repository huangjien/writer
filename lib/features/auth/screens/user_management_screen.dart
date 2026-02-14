import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../state/session_state.dart';
import '../../../state/user_state.dart';
import '../../../l10n/app_localizations.dart';
import '../../../repositories/remote_repository.dart';
import '../../../shared/api_exception.dart';
import '../../../shared/widgets/app_buttons.dart';
import '../../../shared/widgets/neumorphic_switch.dart';
import '../state/user_management_state.dart';

class UserManagementScreen extends ConsumerWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const _UserManagementContent();
  }
}

class _UserManagementContent extends ConsumerStatefulWidget {
  const _UserManagementContent();

  @override
  ConsumerState<_UserManagementContent> createState() =>
      _UserManagementContentState();
}

class _UserManagementContentState
    extends ConsumerState<_UserManagementContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _debugCurrentState();
      _validateSession();
      _loadUsers();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _debugCurrentState() {
    final sessionId = ref.read(sessionProvider);
    final userAsync = ref.read(userProvider);
    debugPrint('[UserManagement Debug] Session ID: ${sessionId ?? 'null'}');
    debugPrint('[UserManagement Debug] User Async: $userAsync');
    if (userAsync.hasValue) {
      debugPrint('[UserManagement Debug] User Value: ${userAsync.value}');
      debugPrint(
        '[UserManagement Debug] Is Admin: ${userAsync.value?.isAdmin}',
      );
    } else if (userAsync.hasError) {
      debugPrint('[UserManagement Debug] User Error: ${userAsync.error}');
    } else {
      debugPrint('[UserManagement Debug] User Loading: ${userAsync.isLoading}');
    }
  }

  Future<void> _loadUsers() async {
    final state = ref.read(userManagementProvider);
    if (state.isLoading) return;

    ref.read(userManagementProvider.notifier).setLoading(true);
    ref.read(userManagementProvider.notifier).clearError();

    try {
      final repo = ref.read(remoteRepositoryProvider);
      final sessionId = ref.read(sessionProvider);
      debugPrint('[UserManagement] Session ID: $sessionId');
      if (sessionId == null || sessionId.isEmpty) {
        final l10n = AppLocalizations.of(context)!;
        throw Exception(l10n.noActiveSessionFound);
      }

      final userAsync = ref.read(userProvider);
      final currentUser = userAsync.value;
      debugPrint(
        '[UserManagement] Current user: ${currentUser?.email}, Admin: ${currentUser?.isAdmin}',
      );

      final data = await repo.get('admin/users');
      ref
          .read(userManagementProvider.notifier)
          .setUsers(data['users'] as List<dynamic>);
    } catch (e) {
      if (e is ApiException && e.statusCode == 401) return;
      debugPrint('[UserManagement] Error: $e');
      if (mounted) {
        ref.read(userManagementProvider.notifier).setError(e.toString());
      }
    } finally {
      if (mounted) ref.read(userManagementProvider.notifier).setLoading(false);
    }
  }

  Future<void> _validateSession() async {
    try {
      final repo = ref.read(remoteRepositoryProvider);
      final sessionId = ref.read(sessionProvider);
      if (sessionId == null) {
        debugPrint('[UserManagement] No session ID found');
        return;
      }

      final data = await repo.get('auth/verify');
      debugPrint('[UserManagement] User data: $data');
      final isAdmin = data['is_admin'] ?? false;
      debugPrint('[UserManagement] Backend says admin: $isAdmin');
    } catch (e) {
      if (e is ApiException && e.statusCode == 401) return;
      debugPrint('[UserManagement] Session validation error: $e');
    }
  }

  Future<void> _toggleApproval(String userId, bool currentStatus) async {
    try {
      final l10n = AppLocalizations.of(context)!;
      final repo = ref.read(remoteRepositoryProvider);
      final sessionId = ref.read(sessionProvider);
      if (sessionId == null) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.sessionExpired)));
        }
        return;
      }

      await repo.patch(
        'admin/users/$userId/approve?approve=${!currentStatus}',
        {},
      );

      await _loadUsers();
    } catch (e) {
      if (e is ApiException && e.statusCode == 401) return;
      debugPrint('[UserManagement] Toggle error: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final managementState = ref.watch(userManagementProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.userManagement),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: AppButtons.icon(
              iconData: Icons.refresh,
              onPressed: _loadUsers,
              tooltip: 'Refresh',
            ),
          ),
        ],
      ),
      body: managementState.isLoading && managementState.users.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : managementState.error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.errorLoadingUsers,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      managementState.error ?? l10n.unknownError,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    AppButtons.primary(
                      onPressed: () async {
                        await ref.read(userProvider.notifier).fetchUser();
                        await _loadUsers();
                      },
                      label: l10n.retry,
                    ),
                    const SizedBox(height: 8),
                    AppButtons.text(
                      onPressed: () => Navigator.of(context).pop(),
                      label: l10n.goBack,
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              itemCount: managementState.users.length,
              itemBuilder: (context, index) {
                final user = managementState.users[index];
                final isApproved = user['is_approved'] == true;
                final email = user['email'] ?? 'No Email';
                final id = user['id'];
                final createdAt = user['created_at'];

                return ListTile(
                  title: Text(email),
                  subtitle: Text(l10n.userIdCreated(id, createdAt)),
                  trailing: NeumorphicSwitch(
                    value: isApproved,
                    onChanged: (val) => _toggleApproval(id, isApproved),
                  ),
                );
              },
            ),
    );
  }
}
