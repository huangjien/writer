import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:writer/l10n/app_localizations.dart';

Future<bool> openUrl(
  BuildContext context,
  String url, {
  Future<bool> Function(Uri uri)? launcher,
}) async {
  final uri = Uri.tryParse(url);
  final isValid =
      uri != null &&
      (uri.scheme == 'http' || uri.scheme == 'https') &&
      uri.host.isNotEmpty;
  if (!isValid) {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n?.invalidLink ?? 'Invalid link')),
    );
    return false;
  }

  bool ok;
  try {
    ok =
        await (launcher ??
            (uri) => launchUrl(uri, mode: LaunchMode.externalApplication))(uri);
  } catch (_) {
    ok = false;
  }
  if (!ok && context.mounted) {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n?.unableToOpenLink ?? 'Unable to open link')),
    );
  }
  return ok;
}
