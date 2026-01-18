import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../repositories/remote_repository.dart';
import '../../shared/api_exception.dart';
import '../../l10n/app_localizations.dart';

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
        _logs = logs ?? '';
        _isLoading = false;
      });
    } catch (e) {
      if (e is ApiException && e.statusCode == 401) return;
      setState(() {
        _errorMessage = '$e';
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
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.adminLogs),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: l10n.refresh,
            onPressed: _isLoading ? null : _loadLogs,
          ),
          IconButton(
            icon: const Icon(Icons.arrow_downward),
            tooltip: l10n.scrollToBottom,
            onPressed: _scrollToBottom,
          ),
          IconButton(
            icon: const Icon(Icons.arrow_upward),
            tooltip: l10n.scrollToTop,
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
                    decoration: InputDecoration(
                      labelText: l10n.numberOfLines,
                      border: const OutlineInputBorder(),
                      suffixText: l10n.lines,
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
                  child: Text(l10n.load),
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
                        '${l10n.failedToLoadLogs}: $_errorMessage',
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : _logs.isEmpty
                ? Center(child: Text(l10n.noLogsAvailable))
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
