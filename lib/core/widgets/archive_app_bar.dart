import 'package:flutter/material.dart';
import 'package:memoirly/core/localization/app_localizations.dart';
import 'package:memoirly/core/theme/app_colors.dart';

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
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AppBar(
      leading: showMenu
          ? IconButton(
              icon: const Icon(Icons.menu_rounded),
              onPressed: onMenu ?? () {},
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
          onPressed: () {},
        ),
      ],
      backgroundColor: AppColors.surface.withValues(alpha: 0.88),
    );
  }
}
