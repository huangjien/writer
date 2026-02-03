import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import '../../repositories/remote_repository.dart';
import '../../shared/api_exception.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/app_buttons.dart';

class AdminLogsScreen extends ConsumerStatefulWidget {
  const AdminLogsScreen({super.key});

  @override
  ConsumerState<AdminLogsScreen> createState() => _AdminLogsScreenState();
}

class _AdminLogsScreenState extends ConsumerState<AdminLogsScreen> {
  List<Map<String, dynamic>> _logs = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _maxSizeKb = 50;
  int _selectedFileIndex = 0;
  List<Map<String, dynamic>> _availableFiles = [];

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _selectedLevel;
  final List<String> _logLevels = [
    'DEBUG',
    'INFO',
    'WARNING',
    'ERROR',
    'CRITICAL',
  ];

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  @override
  void dispose() {
    _searchController.dispose();
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
      final result = await remote.getAdminLogsEnhanced(
        maxSizeKb: _maxSizeKb,
        fileIndex: _selectedFileIndex,
        level: _selectedLevel,
        searchText: _searchController.text.isNotEmpty
            ? _searchController.text
            : null,
      );

      if (result != null) {
        final logsString = result['logs'] as String?;
        final availableFiles = result['available_files'] as List<dynamic>?;

        setState(() {
          if (logsString != null && logsString.isNotEmpty) {
            final parsedLogs = _parseLogs(logsString);
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

          _isLoading = false;
        });
      } else {
        setState(() {
          _logs = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (e is ApiException && e.statusCode == 401) return;
      setState(() {
        _errorMessage = '$e';
        _logs = [];
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _parseLogs(String logsString) {
    final lines = logsString.split('\n');
    final parsedLogs = <Map<String, dynamic>>[];

    for (final line in lines) {
      if (line.trim().isEmpty) continue;

      try {
        final json = jsonDecode(line) as Map<String, dynamic>;
        parsedLogs.add(json);
      } catch (_) {
        parsedLogs.add({'raw': line, 'level': 'INFO', 'message': line});
      }
    }

    return parsedLogs;
  }

  Color _getLevelColor(BuildContext context, String level) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    switch (level.toUpperCase()) {
      case 'ERROR':
      case 'CRITICAL':
        return isDark ? const Color(0xFFFFB4AB) : theme.colorScheme.error;
      case 'WARNING':
        return isDark ? const Color(0xFFFFD8A8) : const Color(0xFF9A5200);
      case 'INFO':
        return isDark ? const Color(0xFF9CB9FF) : theme.colorScheme.primary;
      case 'DEBUG':
        return isDark
            ? const Color(0xFFCAC4D0)
            : theme.colorScheme.onSurfaceVariant;
      default:
        return theme.colorScheme.onSurface;
    }
  }

  Color _getLevelBackgroundColor(BuildContext context, String level) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    switch (level.toUpperCase()) {
      case 'ERROR':
      case 'CRITICAL':
        return isDark
            ? const Color(0xFF5C1D1D).withValues(alpha: 0.3)
            : theme.colorScheme.errorContainer;
      case 'WARNING':
        return isDark
            ? const Color(0xFF5C3800).withValues(alpha: 0.3)
            : const Color(0xFFFFE8CC);
      case 'INFO':
        return isDark
            ? const Color(0xFF1A2F5C).withValues(alpha: 0.3)
            : theme.colorScheme.primaryContainer;
      case 'DEBUG':
        return isDark
            ? const Color(0xFF3F3F46).withValues(alpha: 0.3)
            : theme.colorScheme.surfaceContainerHighest;
      default:
        return theme.colorScheme.surface;
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logs saved to: ${file.path}'),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Copy Path',
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to download logs: $e'),
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
    final theme = Theme.of(context);

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
          _buildControls(context, l10n, theme),
          _buildLevelFilters(context, theme),
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
                : _buildLogsList(context, theme),
          ),
        ],
      ),
    );
  }

  Widget _buildControls(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: theme.colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Search logs',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _loadLogs();
                            },
                          )
                        : null,
                  ),
                  onSubmitted: (_) => _loadLogs(),
                ),
              ),
              const SizedBox(width: 16),
              AppButtons.primary(
                onPressed: _isLoading ? () {} : _loadLogs,
                label: l10n.searchLabel,
                isLoading: _isLoading,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  initialValue: _selectedFileIndex,
                  decoration: const InputDecoration(
                    labelText: 'Log File',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: _availableFiles.map((file) {
                    final index = file['index'] as int;
                    final name = file['name'] as String;
                    final sizeKb = file['size_kb'] as double;
                    return DropdownMenuItem<int>(
                      value: index,
                      child: Text('$name (${sizeKb.toStringAsFixed(1)} KB)'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedFileIndex = value;
                      });
                      _loadLogs();
                    }
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<int>(
                  initialValue: _maxSizeKb,
                  decoration: const InputDecoration(
                    labelText: 'Max Size (KB)',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem<int>(value: 10, child: Text('10 KB')),
                    DropdownMenuItem<int>(value: 50, child: Text('50 KB')),
                    DropdownMenuItem<int>(value: 100, child: Text('100 KB')),
                    DropdownMenuItem<int>(value: 500, child: Text('500 KB')),
                    DropdownMenuItem<int>(value: 1000, child: Text('1 MB')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _maxSizeKb = value;
                      });
                      _loadLogs();
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLevelFilters(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      color: theme.colorScheme.surface,
      child: Wrap(
        spacing: 8.0,
        children: [
          FilterChip(
            label: const Text('ALL'),
            selected: _selectedLevel == null,
            onSelected: (selected) {
              setState(() {
                _selectedLevel = selected ? null : 'INFO';
              });
              _loadLogs();
            },
          ),
          ..._logLevels.map((level) {
            final isSelected = _selectedLevel == level;
            return FilterChip(
              label: Text(level),
              selected: isSelected,
              selectedColor: _getLevelColor(context, level),
              onSelected: (selected) {
                setState(() {
                  _selectedLevel = selected ? level : null;
                });
                _loadLogs();
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLogsList(BuildContext context, ThemeData theme) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: _logs.length,
      itemBuilder: (listContext, index) {
        final log = _logs[index];
        final level = (log['level'] as String?)?.toUpperCase() ?? 'INFO';
        final bgColor = _getLevelBackgroundColor(listContext, level);
        final message =
            log['message'] as String? ?? log['raw'] as String? ?? '';
        final timestamp = log['timestamp'] as String? ?? '';
        final logger = log['logger'] as String? ?? '';
        final requestId = log['request_id'] as String?;

        return Container(
          color: bgColor,
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: InkWell(
            onTap: () {
              _showLogDetailDialog(
                listContext,
                log,
                level,
                timestamp,
                logger,
                requestId,
                message,
                theme,
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 90,
                    child: Text(
                      timestamp.isNotEmpty ? timestamp.split(',')[0] : '',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _buildLevelBadge(level, listContext),
                            const SizedBox(width: 10),
                            if (logger.isNotEmpty)
                              Expanded(
                                child: Text(
                                  logger,
                                  style: TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 11,
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.7),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        SelectionArea(
                          child: Text(
                            message,
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 13,
                              color: theme.colorScheme.onSurface,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLevelBadge(String level, BuildContext context) {
    final badgeColor = _getLevelColor(context, level);
    final badgeBgColor = _getLevelBackgroundColor(context, level);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeBgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: badgeColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Text(
        level,
        style: TextStyle(
          color: badgeColor,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  void _showLogDetailDialog(
    BuildContext context,
    Map<String, dynamic> log,
    String level,
    String timestamp,
    String logger,
    String? requestId,
    String message,
    ThemeData theme,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            _buildLevelBadge(level, dialogContext),
            const SizedBox(width: 12),
            const Text('Log Entry'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: SelectionArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (timestamp.isNotEmpty)
                    _buildDetailRow('Timestamp', timestamp, theme),
                  if (logger.isNotEmpty)
                    _buildDetailRow('Logger', logger, theme),
                  if (requestId != null)
                    _buildDetailRow('Request ID', requestId, theme),
                  const SizedBox(height: 16),
                  Text(
                    'Message:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SelectableText(
                      message,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13,
                        color: theme.colorScheme.onSurface,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Full Data:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SelectableText(
                      const JsonEncoder.withIndent('  ').convert(log),
                      style:
                          const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                            height: 1.4,
                          ).copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.7,
                            ),
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: jsonEncode(log)));
              ScaffoldMessenger.of(dialogContext).showSnackBar(
                const SnackBar(
                  content: Text('Copied to clipboard'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            icon: const Icon(Icons.copy, size: 18),
            label: const Text('Copy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: TextStyle(
                fontFamily: 'monospace',
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
