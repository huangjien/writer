import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../l10n/app_localizations.dart';
import '../../../state/novel_providers.dart';
import '../../../state/progress_providers.dart';
import '../../../state/providers.dart';

class SupabaseSection extends ConsumerWidget {
  const SupabaseSection({super.key, required this.user});
  final User? user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final enabled = ref.watch(supabaseEnabledProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.supabaseSettings,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        if (!enabled) ...[
          ListTile(
            title: Text(l10n.supabaseNotEnabled),
            subtitle: Text(l10n.supabaseNotEnabledDescription),
          ),
          ListTile(
            leading: const Icon(Icons.library_books),
            title: Text(l10n.myNovels),
            onTap: () => context.goNamed('myNovels'),
          ),
        ] else ...[
          ListTile(
            leading: const Icon(Icons.cloud_download),
            title: Text(l10n.fetchFromSupabase),
            subtitle: Text(l10n.fetchFromSupabaseDescription),
            onTap: user == null
                ? null
                : () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(l10n.confirmFetch),
                        content: Text(l10n.confirmFetchDescription),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(l10n.cancel),
                          ),
                          TextButton(
                            onPressed: () {
                              ref.invalidate(novelsProvider);
                              Navigator.of(context).pop();
                            },
                            child: Text(l10n.fetch),
                          ),
                        ],
                      ),
                    );
                  },
          ),
          ListTile(
            leading: const Icon(Icons.library_books),
            title: Text(l10n.myNovels),
            onTap: () => context.goNamed('myNovels'),
          ),
          Consumer(
            builder: (context, ref, child) {
              final novels = ref.watch(novelsProvider);
              final progress = ref.watch(latestUserProgressProvider);
              return ListTile(
                title: Text(l10n.novelsAndProgress),
                subtitle: Text(
                  l10n.novelsAndProgressSummary(
                    novels.asData?.value.length ?? 0,
                    progress.asData?.value?.novelId ?? 'N/A',
                  ),
                ),
              );
            },
          ),
        ],
      ],
    );
  }
}
