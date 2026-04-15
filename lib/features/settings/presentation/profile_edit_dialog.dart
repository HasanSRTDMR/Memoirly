import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memoirly/core/di/providers.dart';
import 'package:memoirly/core/localization/app_localizations.dart';
import 'package:memoirly/domain/entities/user_profile.dart';

Future<void> showProfileEditDialog({
  required BuildContext context,
  required UserProfile initial,
}) async {
  await showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    builder: (ctx) => _ProfileEditDialog(initial: initial),
  );
}

class _ProfileEditDialog extends ConsumerStatefulWidget {
  const _ProfileEditDialog({required this.initial});

  final UserProfile initial;

  @override
  ConsumerState<_ProfileEditDialog> createState() =>
      _ProfileEditDialogState();
}

class _ProfileEditDialogState extends ConsumerState<_ProfileEditDialog> {
  late final TextEditingController _first;
  late final TextEditingController _last;
  late final TextEditingController _email;
  late final TextEditingController _phone;

  @override
  void initState() {
    super.initState();
    final i = widget.initial;
    _first = TextEditingController(text: i.firstName);
    _last = TextEditingController(text: i.lastName);
    _email = TextEditingController(text: i.email);
    _phone = TextEditingController(text: i.phone);
  }

  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    await ref.read(userProfileRepositoryProvider).saveProfile(
          UserProfile(
            firstName: _first.text,
            lastName: _last.text,
            email: _email.text,
            phone: _phone.text,
          ),
        );
    if (!mounted) return;
    Navigator.of(context).pop();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Text(l.profileNameSaved),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 28),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              scheme.surfaceContainerHigh,
              scheme.surfaceContainerLow,
            ],
          ),
          border: Border.all(
            color: scheme.outlineVariant.withValues(alpha: 0.45),
          ),
          boxShadow: [
            BoxShadow(
              color: scheme.onSurface.withValues(alpha: 0.12),
              blurRadius: 32,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: scheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: scheme.secondary.withValues(alpha: 0.12),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.edit_note_rounded,
                          size: 28,
                          color: scheme.onSecondaryContainer,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l.profileDialogTitle,
                              style: GoogleFonts.newsreader(
                                fontSize: 24,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w600,
                                height: 1.15,
                                color: scheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l.profileNameHint,
                              style: GoogleFonts.newsreader(
                                fontSize: 14,
                                height: 1.45,
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  TextField(
                    controller: _first,
                    textCapitalization: TextCapitalization.words,
                    style: theme.textTheme.bodyLarge,
                    decoration: InputDecoration(
                      labelText: l.profileFirstName,
                      prefixIcon: Icon(
                        Icons.badge_outlined,
                        color: scheme.primary.withValues(alpha: 0.85),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _last,
                    textCapitalization: TextCapitalization.words,
                    style: theme.textTheme.bodyLarge,
                    decoration: InputDecoration(
                      labelText: l.profileLastName,
                      prefixIcon: Icon(
                        Icons.assignment_ind_outlined,
                        color: scheme.primary.withValues(alpha: 0.85),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    child: Divider(
                      height: 1,
                      color: scheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  TextField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    style: theme.textTheme.bodyLarge,
                    decoration: InputDecoration(
                      labelText: l.profileEmail,
                      prefixIcon: Icon(
                        Icons.mail_outline_rounded,
                        color: scheme.tertiary.withValues(alpha: 0.9),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    style: theme.textTheme.bodyLarge,
                    decoration: InputDecoration(
                      labelText: l.profilePhone,
                      prefixIcon: Icon(
                        Icons.phone_outlined,
                        color: scheme.tertiary.withValues(alpha: 0.9),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            side: BorderSide(
                              color: scheme.outline.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Text(
                            l.cancel,
                            style: theme.textTheme.labelLarge?.copyWith(
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: _save,
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            l.save,
                            style: theme.textTheme.labelLarge?.copyWith(
                              letterSpacing: 0.8,
                              color: scheme.onPrimary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
