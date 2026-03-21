import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'admin_logs_utils.dart';
import 'widgets/admin_log_detail_dialog.dart';
import 'widgets/admin_logs_controls.dart';
import 'widgets/admin_logs_level_filters.dart';
import 'widgets/admin_logs_list.dart';
import 'package:writer/repositories/remote_repository.dart';
import 'package:writer/shared/api_exception.dart';
import 'package:writer/l10n/app_localizations.dart';

class AdminLogsScreen extends ConsumerStatefulWidget {
  const AdminLogsScreen({super.key});

  @override
  ConsumerState<AdminLogsScreen> createState() => _AdminLogsScreenState();
}

class _AdminLogsScreenState extends ConsumerState<AdminLogsScreen> {
  List<Map<String, dynamic>> _logs = [];
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic> _metadata = const {};
  int _maxSizeKb = 50;
  int _selectedFileIndex = 0;
  List<Map<String, dynamic>> _availableFiles = [];

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _loggerController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _selectedLevel;
  final List<String> _logLevels = [
    'DEBUG',
    'INFO',
    'WARNING',
    'ERROR',
    'CRITICAL',
  ];

  static final RegExp _datePattern = RegExp(r'^\d{4}-\d{2}-\d{2}$');

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _loggerController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadLogs() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final startDate = _startDateController.text.trim();
      final endDate = _endDateController.text.trim();
      if (!_isValidDateInput(startDate) || !_isValidDateInput(endDate)) {
        setState(() {
          _errorMessage = 'Invalid date format. Use YYYY-MM-DD.';
          _logs = [];
          _metadata = const {};
          _isLoading = false;
        });
        return;
      }
      if (startDate.isNotEmpty &&
          endDate.isNotEmpty &&
          DateTime.parse(startDate).isAfter(DateTime.parse(endDate))) {
        setState(() {
          _errorMessage = 'Start Date must be on or before End Date.';
          _logs = [];
          _metadata = const {};
          _isLoading = false;
        });
        return;
      }
      final remote = ref.read(remoteRepositoryProvider);
      final result = await remote.getAdminLogsEnhanced(
        maxSizeKb: _maxSizeKb,
        fileIndex: _selectedFileIndex,
        level: _selectedLevel,
        searchText: _searchController.text.isNotEmpty
            ? _searchController.text
            : null,
        logger: _loggerController.text.isNotEmpty
            ? _loggerController.text
            : null,
        startDate: startDate.isNotEmpty ? startDate : null,
        endDate: endDate.isNotEmpty ? endDate : null,
      );

      if (result != null) {
        final logsString = result['logs'] as String?;
        final availableFiles = result['available_files'] as List<dynamic>?;
        final metadata = result['metadata'] as Map<String, dynamic>?;

        setState(() {
          if (logsString != null && logsString.isNotEmpty) {
            final parsedLogs = parseAdminLogs(logsString);
            _logs = parsedLogs.reversed.toList();
          } else {
            _logs = [];
          }

          if (availableFiles != null) {
            _availableFiles = availableFiles
                .map<Map<String, dynamic>>(
                  (e) => Map<String, dynamic>.from(e as Map),
                )
                .toList();
          }
          _metadata = metadata ?? const {};

          _isLoading = false;
        });
      } else {
        setState(() {
          _logs = [];
          _metadata = const {};
          _isLoading = false;
        });
      }
    } catch (e) {
      if (e is ApiException && e.statusCode == 401) {
        setState(() {
          _errorMessage = null;
          _logs = [];
          _metadata = const {};
          _isLoading = false;
        });
        return;
      }
      setState(() {
        if (e is ApiException) {
          _errorMessage = '${e.statusCode}: ${e.rawMessage}';
        } else {
          _errorMessage = '$e';
        }
        _logs = [];
        _metadata = const {};
        _isLoading = false;
      });
    }
  }

  bool _isValidDateInput(String value) {
    if (value.isEmpty) return true;
    if (!_datePattern.hasMatch(value)) return false;
    try {
      final parsed = DateTime.parse(value);
      final normalized =
          '${parsed.year.toString().padLeft(4, '0')}-'
          '${parsed.month.toString().padLeft(2, '0')}-'
          '${parsed.day.toString().padLeft(2, '0')}';
      return normalized == value;
    } catch (_) {
      return false;
    }
  }

  Future<void> _downloadLogs() async {
    try {
      final logsText = _logs
          .map((log) {
            if (log.containsKey('raw')) return log['raw'] as String;
            return jsonEncode(log);
          })
          .join('\n');

      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final file = File('${directory.path}/admin_logs_$timestamp.log');
      await file.writeAsString(logsText);

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.adminLogsSavedTo(file.path)),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: l10n.adminLogsCopy,
              textColor: Colors.blue,
              onPressed: () {
                Clipboard.setData(ClipboardData(text: file.path));
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.adminLogsFailedToDownload(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
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
            icon: const Icon(Icons.download),
            tooltip: 'Download Logs',
            onPressed: _isLoading || _logs.isEmpty ? null : _downloadLogs,
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
          AdminLogsControls(
            searchController: _searchController,
            loggerController: _loggerController,
            startDateController: _startDateController,
            endDateController: _endDateController,
            isLoading: _isLoading,
            availableFiles: _availableFiles,
            selectedFileIndex: _selectedFileIndex,
            onFileChanged: (value) {
              setState(() {
                _selectedFileIndex = value;
              });
              _loadLogs();
            },
            maxSizeKb: _maxSizeKb,
            onMaxSizeChanged: (value) {
              setState(() {
                _maxSizeKb = value;
              });
              _loadLogs();
            },
            onSearch: _loadLogs,
            onClearSearch: () {
              _searchController.clear();
              _loadLogs();
            },
            onClearLogger: () {
              _loggerController.clear();
              _loadLogs();
            },
            onClearStartDate: () {
              _startDateController.clear();
              _loadLogs();
            },
            onClearEndDate: () {
              _endDateController.clear();
              _loadLogs();
            },
          ),
          AdminLogsLevelFilters(
            logLevels: _logLevels,
            selectedLevel: _selectedLevel,
            onSelectedLevelChanged: (level) {
              setState(() {
                _selectedLevel = level;
              });
              _loadLogs();
            },
          ),
          if (_metadata.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Wrap(
                spacing: 12,
                runSpacing: 4,
                children: [
                  if (_metadata['file'] != null)
                    Text('File: ${_metadata['file']}'),
                  if (_metadata['total_lines'] != null)
                    Text('Total: ${_metadata['total_lines']}'),
                  if (_metadata['filtered_lines'] != null)
                    Text('Filtered: ${_metadata['filtered_lines']}'),
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
                : AdminLogsList(
                    logs: _logs,
                    scrollController: _scrollController,
                    onTapLog:
                        (
                          logContext,
                          log,
                          level,
                          timestamp,
                          logger,
                          requestId,
                          message,
                        ) {
                          showAdminLogDetailDialog(
                            logContext,
                            log: log,
                            level: level,
                            timestamp: timestamp,
                            logger: logger,
                            requestId: requestId,
                            message: message,
                          );
                        },
                  ),
          ),
        ],
      ),
    );
  }
}
