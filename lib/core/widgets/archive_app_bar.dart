import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memoirly/core/localization/app_localizations.dart';
import 'package:memoirly/core/widgets/archive_sheets.dart';

class ArchiveAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ArchiveAppBar({
    super.key,
    this.showMenu = true,
    this.onMenu,
    this.title,
    this.actions,
  });

  final bool showMenu;
  final VoidCallback? onMenu;
  final String? title;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final l = AppLocalizations.of(context);
        return AppBar(
          leading: showMenu
              ? IconButton(
                  icon: const Icon(Icons.menu_rounded),
                  tooltip: l.menu,
                  onPressed: onMenu ?? () => ArchiveSheets.showQuickNav(context),
                )
              : null,
          title: Text(
            title ?? l.archiveTitle,
            style: Theme.of(context).appBarTheme.titleTextStyle,
          ),
          actions: [
            ...?actions,
            IconButton(
              icon: const Icon(Icons.account_circle_outlined),
              tooltip: l.account,
              onPressed: () => ArchiveSheets.showAccount(context, ref),
            ),
          ],
          backgroundColor:
              Theme.of(context).colorScheme.surface.withValues(alpha: 0.88),
        );
      },
    );
  }
}
