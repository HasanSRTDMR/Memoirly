import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memoirly/core/config/app_backend.dart';
import 'package:memoirly/core/di/providers.dart';
import 'package:memoirly/core/localization/app_localizations.dart';
import 'package:memoirly/core/theme/app_colors.dart';

class ArchiveSheets {
  static Future<void> showQuickNav(BuildContext context) async {
    final l = AppLocalizations.of(context);
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: AppColors.surfaceContainerLow,
      builder: (ctx) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                  child: Text(
                    l.quickNavTitle,
                    style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                _navTile(ctx, context, Icons.home_rounded, l.home, '/home'),
                _navTile(ctx, context, Icons.search_rounded, l.search, '/search'),
                _navTile(
                  ctx,
                  context,
                  Icons.calendar_today_rounded,
                  l.calendar,
                  '/calendar',
                ),
                _navTile(
                  ctx,
                  context,
                  Icons.analytics_outlined,
                  l.insights,
                  '/insights',
                ),
                _navTile(
                  ctx,
                  context,
                  Icons.settings_outlined,
                  l.settings,
                  '/settings',
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget _navTile(
    BuildContext sheetCtx,
    BuildContext parentCtx,
    IconData icon,
    String title,
    String path,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      onTap: () {
        Navigator.pop(sheetCtx);
        if (parentCtx.mounted) parentCtx.go(path);
      },
    );
  }

  static Future<void> showAccount(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final backend = ref.read(appBackendProvider);
    final auth = ref.read(authRepositoryProvider);
    final uid = await auth.getCurrentUserId();

    if (!context.mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: AppColors.surfaceContainerLow,
      builder: (ctx) {
        final idPreview = uid == null
            ? '—'
            : (uid.length > 12 ? '${uid.substring(0, 6)}…${uid.substring(uid.length - 4)}' : uid);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l.accountSheetTitle,
                  style: Theme.of(ctx).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Text(
                  backend == AppBackend.firebase
                      ? l.anonymousSessionCloud
                      : l.anonymousSessionLocal,
                  style: Theme.of(ctx).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                SelectableText(
                  '${l.userIdLabel}: $idPreview',
                  style: Theme.of(ctx).textTheme.labelSmall,
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    if (context.mounted) context.go('/settings');
                  },
                  child: Text(l.settings),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(l.close),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
