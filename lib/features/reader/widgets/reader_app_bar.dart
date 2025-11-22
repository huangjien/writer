import 'package:flutter/material.dart';

class ReaderAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ReaderAppBar({super.key, required this.title, required this.onBack});

  final String title;
  final VoidCallback onBack;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      leading: Tooltip(
        message: MaterialLocalizations.of(context).backButtonTooltip,
        child: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack,
        ),
      ),
      actions: [
        Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_open),
            onPressed: () => Scaffold.of(context).openEndDrawer(),
            tooltip: 'Menu',
          ),
        ),
      ],
    );
  }
}
