import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:writer/l10n/app_localizations.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.blue),
            child: Text(
              AppLocalizations.of(context)!.tools,
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.text_snippet),
            title: Text(AppLocalizations.of(context)!.prompts),
            onTap: () {
              Navigator.pop(context);
              context.go('/prompts');
            },
          ),
        ],
      ),
    );
  }
}
