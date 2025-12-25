import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../state/ai_service_settings.dart';
import '../../state/session_state.dart';
import '../../state/user_state.dart';

class UserManagementScreen extends ConsumerStatefulWidget {
  const UserManagementScreen({super.key, this.client});
  final http.Client? client;

  @override
  ConsumerState<UserManagementScreen> createState() =>
      _UserManagementScreenState();
}

class _UserManagementScreenState extends ConsumerState<UserManagementScreen> {
  bool _loading = false;
  String? _error;
  List<dynamic> _users = [];
  late final http.Client _client;
  late final bool _disposeClient;

  @override
  void initState() {
    super.initState();
    _client = widget.client ?? http.Client();
    _disposeClient = widget.client == null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchUsers();
    });
  }

  @override
  void dispose() {
    if (_disposeClient) {
      _client.close();
    }
    super.dispose();
  }

  Future<void> _fetchUsers() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final sessionId = ref.read(sessionProvider);
      if (sessionId == null) throw Exception("Session expired");

      String baseUrl;
      try {
        baseUrl = ref.read(aiServiceProvider);
      } catch (_) {
        baseUrl = 'http://localhost:5600/';
      }

      final url = baseUrl.endsWith('/')
          ? '${baseUrl}admin/users'
          : '$baseUrl/admin/users';

      final res = await _client.get(
        Uri.parse(url),
        headers: {'X-Session-Id': sessionId},
      );

      if (res.statusCode != 200) {
        throw Exception("Failed to load users: ${res.statusCode}");
      }

      final data = jsonDecode(utf8.decode(res.bodyBytes));
      setState(() {
        _users = data['users'] as List<dynamic>;
      });
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggleApproval(String userId, bool currentStatus) async {
    try {
      final sessionId = ref.read(sessionProvider);
      if (sessionId == null) return;

      String baseUrl = ref.read(aiServiceProvider);
      if (!baseUrl.endsWith('/')) baseUrl += '/';

      final url =
          '${baseUrl}admin/users/$userId/approve?approve=${!currentStatus}';

      final res = await _client.patch(
        Uri.parse(url),
        headers: {'X-Session-Id': sessionId},
      );

      if (res.statusCode != 200) {
        throw Exception("Failed to update status");
      }

      // Refresh list
      await _fetchUsers();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if admin
    final userAsync = ref.watch(userProvider);
    final isadmin = userAsync.value?.isAdmin ?? false;

    if (!isadmin) {
      return Scaffold(
        appBar: AppBar(title: const Text("User Management")),
        body: const Center(child: Text("Access Denied")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("User Management"),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchUsers),
        ],
      ),
      body: _loading && _users.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text("Error: $_error"))
          : ListView.builder(
              itemCount: _users.length,
              itemBuilder: (context, index) {
                final user = _users[index];
                final isApproved = user['is_approved'] == true;
                final email = user['email'] ?? 'No Email';
                final id = user['id'];
                final createdAt = user['created_at'];

                return ListTile(
                  title: Text(email),
                  subtitle: Text("ID: $id\nCreated: $createdAt"),
                  trailing: Switch(
                    value: isApproved,
                    onChanged: (val) => _toggleApproval(id, isApproved),
                  ),
                );
              },
            ),
    );
  }
}
