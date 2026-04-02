import 'package:flutter/material.dart';
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
    final scheme = Theme.of(context).colorScheme;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: 72 + bottomInset, right: 8),
      child: FloatingActionButton(
        heroTag: heroTag,
        onPressed: onPressed,
        backgroundColor: scheme.secondary,
        foregroundColor: scheme.onSecondary,
        elevation: 6,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}
