import 'package:flutter/material.dart';
import '../../../theme/design_tokens.dart';
import '../../../l10n/app_localizations.dart';

class LibrarySearchBar extends StatelessWidget {
  const LibrarySearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    this.matchCount,
  });
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final int? matchCount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: l10n.searchByTitle,
        prefixIcon: const Icon(Icons.search),
        suffixText: matchCount != null ? '$matchCount' : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radii.s),
        ),
      ),
      onChanged: onChanged,
    );
  }
}
