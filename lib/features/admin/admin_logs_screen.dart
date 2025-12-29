import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../repositories/remote_repository.dart';

class AdminLogsScreen extends ConsumerStatefulWidget {
  const AdminLogsScreen({super.key});

  @override
  ConsumerState<AdminLogsScreen> createState() => _AdminLogsScreenState();
}

class _AdminLogsScreenState extends ConsumerState<AdminLogsScreen> {
  String _logs = '';
  bool _isLoading = false;
  String? _errorMessage;
  int _lines = 1000;
  final TextEditingController _linesController = TextEditingController(
    text: '1000',
  );
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  @override
  void dispose() {
    _linesController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadLogs() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final remote = ref.read(remoteRepositoryProvider);
      final logs = await remote.getAdminLogs(lines: _lines);

      setState(() {
        _logs = logs ?? 'No logs available.';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load logs: $e';
        _isLoading = false;
      });
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Logs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _isLoading ? null : _loadLogs,
          ),
          IconButton(
            icon: const Icon(Icons.arrow_downward),
            tooltip: 'Scroll to bottom',
            onPressed: _scrollToBottom,
          ),
          IconButton(
            icon: const Icon(Icons.arrow_upward),
            tooltip: 'Scroll to top',
            onPressed: _scrollToTop,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _linesController,
                    decoration: const InputDecoration(
                      labelText: 'Number of lines',
                      border: OutlineInputBorder(),
                      suffixText: 'lines',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final parsed = int.tryParse(value);
                      if (parsed != null && parsed > 0) {
                        _lines = parsed;
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _isLoading ? null : _loadLogs,
                  child: const Text('Load'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : Container(
                    color: Colors.black87,
                    padding: const EdgeInsets.all(8.0),
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      child: SelectableText(
                        _logs,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
