import 'package:flutter/material.dart';
import 'package:memoirly/core/localization/app_localizations.dart';
import 'package:memoirly/core/theme/app_colors.dart';

/// Maps Firestore / network errors to user-visible text (see logcat).
String describeJournalStreamError(Object error, AppLocalizations l) {
  final s = error.toString();
  if (s.contains('Cloud Firestore API has not been used') ||
      s.contains('firestore.googleapis.com/overview') ||
      (s.contains('PERMISSION_DENIED') && s.contains('it is disabled'))) {
    return '${l.firestoreApiDisabled}\n\n${l.firestoreRulesHint}';
  }
  if (s.contains('PERMISSION_DENIED')) {
    return '${l.errorGeneric}\n\n${l.firestoreRulesHint}';
  }
  return l.errorGeneric;
}

class JournalStreamErrorView extends StatelessWidget {
  const JournalStreamErrorView({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 56,
              color: AppColors.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
