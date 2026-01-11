import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../services/logger_service.dart';
import 'error_view.dart';

class ErrorBoundary extends StatefulWidget {
  const ErrorBoundary({super.key, required this.child});

  final Widget child;

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  late final ErrorWidgetBuilder _previousBuilder;
  Key _subtreeKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _previousBuilder = ErrorWidget.builder;
    ErrorWidget.builder = (details) {
      LoggerService().logError(details.exception, details.stack);
      return _GlobalErrorFallback(onRecover: _recover);
    };
  }

  @override
  void dispose() {
    ErrorWidget.builder = _previousBuilder;
    super.dispose();
  }

  void _recover() {
    if (!mounted) return;
    setState(() => _subtreeKey = UniqueKey());
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(key: _subtreeKey, child: widget.child);
  }
}

class _GlobalErrorFallback extends StatelessWidget {
  const _GlobalErrorFallback({required this.onRecover});

  final VoidCallback onRecover;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final message = l10n == null ? 'Something went wrong' : l10n.error;
    final retry = l10n?.retry;

    return Material(
      child: SafeArea(
        child: ErrorView(
          message: message,
          onRetry: retry == null ? null : onRecover,
        ),
      ),
    );
  }
}
