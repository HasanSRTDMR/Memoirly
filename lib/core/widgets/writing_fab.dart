import 'package:flutter/material.dart';
import 'package:memoirly/core/theme/app_colors.dart';

class WritingFab extends StatelessWidget {
  const WritingFab({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 88, right: 8),
      child: FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.onSecondary,
        elevation: 6,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}
