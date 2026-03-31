import 'package:flutter/material.dart';
import 'package:memoirly/core/theme/app_colors.dart';

class WritingFab extends StatelessWidget {
  const WritingFab({
    super.key,
    required this.heroTag,
    required this.onPressed,
  });

  /// Must be unique per route — [StatefulShellRoute] keeps all tabs alive, so
  /// default FAB hero tags collide ("multiple heroes that share the same tag").
  final Object heroTag;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: 72 + bottomInset, right: 8),
      child: FloatingActionButton(
        heroTag: heroTag,
        onPressed: onPressed,
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.onSecondary,
        elevation: 6,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}
