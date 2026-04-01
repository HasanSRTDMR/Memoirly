import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memoirly/core/localization/app_localizations.dart';
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final items = <({IconData icon, String label, int index})>[
      (icon: Icons.home_rounded, label: l.home, index: 0),
      (icon: Icons.search_rounded, label: l.search, index: 1),
      (icon: Icons.calendar_today_rounded, label: l.calendar, index: 2),
      (icon: Icons.analytics_outlined, label: l.insights, index: 3),
      (icon: Icons.settings_outlined, label: l.settings, index: 4),
    ];

    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: Material(
        color: scheme.surface.withValues(alpha: 0.92),
        elevation: 0,
        child: SafeArea(
          top: false,
          child: LayoutBuilder(
            builder: (context, c) {
              final narrow = c.maxWidth < 400;
              final padH = narrow ? 4.0 : 8.0;
              final contentW = c.maxWidth - 2 * padH;
              final navChildren = items
                  .map(
                    (it) => _NavItem(
                      icon: it.icon,
                      label: it.label,
                      selected: navigationShell.currentIndex == it.index,
                      compact: narrow,
                      onTap: () => _goBranch(it.index),
                    ),
                  )
                  .toList();
              final bar = Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: navChildren,
              );
              return Padding(
                padding: EdgeInsets.fromLTRB(padH, 8, padH, 12),
                child: narrow
                    ? SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minWidth: contentW),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            mainAxisSize: MainAxisSize.min,
                            children: navChildren,
                          ),
                        ),
                      )
                    : bar,
              );
            },
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.compact,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fg = selected
        ? scheme.onSurface
        : scheme.onSurfaceVariant.withValues(alpha: 0.65);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 8 : 10,
          vertical: compact ? 6 : 8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: compact ? 20 : 22,
              color: fg,
            ),
            SizedBox(height: compact ? 2 : 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontSize: compact ? 8 : 9,
                    color: fg,
                    letterSpacing: compact ? 0.8 : 1.4,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
