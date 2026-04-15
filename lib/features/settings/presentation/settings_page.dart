import 'dart:convert';
import 'dart:ui' show PlatformDispatcher;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memoirly/core/di/providers.dart';
import 'package:memoirly/core/import_export/journal_txt_codec.dart';
import 'package:memoirly/core/localization/app_localizations.dart';
import 'package:memoirly/core/widgets/archive_app_bar.dart';
import 'package:memoirly/features/settings/presentation/pin_setup_sheet.dart';
import 'package:memoirly/features/settings/presentation/profile_edit_dialog.dart';
import 'package:share_plus/share_plus.dart';

Locale _settingsLocaleFallback() {
  final lang = PlatformDispatcher.instance.locale.languageCode;
  return lang == 'tr' ? const Locale('tr') : const Locale('en');
}

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final settings = ref.watch(settingsRepositoryProvider);
    final security = ref.watch(securityRepositoryProvider);

    return Scaffold(
      appBar: ArchiveAppBar(title: l.settings),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 120),
        children: [
          Text(
            l.settingsSubtitle,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  height: 1.35,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 32),
          _ProfileNameSection(),
          const SizedBox(height: 28),
          _SectionTitle(icon: Icons.security_rounded, title: l.security),
          const SizedBox(height: 12),
          StreamBuilder<bool>(
            stream: security.watchLockEnabled(),
            builder: (context, snap) {
              final on = snap.data ?? false;
              return _SettingsTile(
                title: l.passcodeLock,
                subtitle: l.passcodeLockDesc,
                trailing: Switch(
                  value: on,
                  onChanged: (v) async {
                    if (v) {
                      final pin = await showModalBottomSheet<String>(
                        context: context,
                        isScrollControlled: true,
                        builder: (ctx) => const PinSetupSheet(),
                      );
                      if (pin != null && pin.length >= 4) {
                        await security.setPin(pin);
                        await security.setLockEnabled(true);
                        security.setSessionUnlocked(true);
                      }
                    } else {
                      await security.setLockEnabled(false);
                      security.setSessionUnlocked(true);
                    }
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 28),
          _SectionTitle(icon: Icons.palette_outlined, title: l.appearance),
          const SizedBox(height: 12),
          StreamBuilder<ThemeMode>(
            stream: settings.watchThemeMode(),
            builder: (context, snap) {
              final mode = snap.data ?? ThemeMode.system;
              return Row(
                children: [
                  Expanded(
                    child: _ThemeChoice(
                      title: l.lightMode,
                      selected: mode == ThemeMode.light,
                      onTap: () => settings.setThemeMode(ThemeMode.light),
                      darkPreview: false,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ThemeChoice(
                      title: l.darkMode,
                      selected: mode == ThemeMode.dark,
                      onTap: () => settings.setThemeMode(ThemeMode.dark),
                      darkPreview: true,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 28),
          _SectionTitle(icon: Icons.language_rounded, title: l.language),
          const SizedBox(height: 12),
          StreamBuilder<Locale>(
            stream: settings.watchLocaleOverride(),
            builder: (context, snap) {
              final loc = snap.data ?? _settingsLocaleFallback();
              return Column(
                children: [
                  ListTile(
                    title: Text(l.languageEnglish),
                    trailing: loc.languageCode == 'en'
                        ? Icon(
                            Icons.check_rounded,
                            color: Theme.of(context).colorScheme.primary,
                          )
                        : null,
                    onTap: () =>
                        settings.setLocaleOverride(const Locale('en')),
                  ),
                  ListTile(
                    title: Text(l.languageTurkish),
                    trailing: loc.languageCode == 'tr'
                        ? Icon(
                            Icons.check_rounded,
                            color: Theme.of(context).colorScheme.primary,
                          )
                        : null,
                    onTap: () =>
                        settings.setLocaleOverride(const Locale('tr')),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 28),
          _SectionTitle(icon: Icons.storage_rounded, title: l.dataManagement),
          const SizedBox(height: 12),
          _SettingsNavTile(
            icon: Icons.description_outlined,
            title: l.exportTxt,
            onTap: () async {
              final entries =
                  await ref.read(journalRepositoryProvider).watchEntries().first;
              final txt = JournalTxtCodec.exportEntries(entries);
              await Share.share(txt, subject: l.appTitle);
            },
          ),
          _SettingsNavTile(
            icon: Icons.upload_file_outlined,
            title: l.importTxt,
            onTap: () async {
              final go = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(l.importTxt),
                  content: Text(l.importTxtHint),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: Text(l.cancel),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: Text(l.importTxtSelectFile),
                    ),
                  ],
                ),
              );
              if (go != true || !context.mounted) return;
              final result = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowedExtensions: ['txt'],
                withData: true,
              );
              if (!context.mounted) return;
              if (result == null || result.files.isEmpty) return;
              final bytes = result.files.single.bytes;
              if (bytes == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l.importTxtError)),
                );
                return;
              }
              final text = utf8.decode(bytes, allowMalformed: true);
              final uid = await ref.read(authRepositoryProvider).getCurrentUserId();
              if (uid == null || uid.isEmpty) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l.errorGeneric)),
                  );
                }
                return;
              }
              final parsed = JournalTxtCodec.parseForImport(text, uid);
              if (parsed.isEmpty) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l.importTxtEmpty)),
                  );
                }
                return;
              }
              for (final e in parsed) {
                await ref.read(journalRepositoryProvider).create(e);
              }
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l.importedEntriesCount(parsed.length)),
                  ),
                );
              }
            },
          ),
          _SettingsNavTile(
            icon: Icons.delete_forever_outlined,
            title: l.resetLocalData,
            onTap: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(l.resetLocalData),
                  content: Text(l.resetLocalDataConfirm),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: Text(l.cancel),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: Text(l.delete),
                    ),
                  ],
                ),
              );
              if (ok == true) {
                await ref.read(journalRepositoryProvider).clearAll();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l.loading)),
                  );
                }
              }
            },
          ),
          const SizedBox(height: 32),
          Center(
            child: Chip(
              avatar: Icon(
                Icons.verified_user_rounded,
                size: 18,
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
              label: Text(l.privacyFirst),
              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
              side: BorderSide.none,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l.privacyQuote,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            l.versionLabel('1.0.0'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}

class _ProfileNameSection extends ConsumerWidget {
  const _ProfileNameSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final async = ref.watch(userProfileStreamProvider);

    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator.adaptive()),
      ),
      error: (_, __) => Padding(
        padding: const EdgeInsets.all(16),
        child: Text(l.errorGeneric),
      ),
      data: (p) {
        final hasRealName = p.fullNameForGreeting.isNotEmpty;
        final displayLine = hasRealName
            ? p.fullNameForGreeting
            : l.defaultGreetingName;
        final email = p.email.trim();
        final phone = p.phone.trim();
        final initial = hasRealName
            ? p.fullNameForGreeting.trim().characters.first.toUpperCase()
            : '';
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle(
              icon: Icons.person_outline_rounded,
              title: l.profileSectionTitle,
            ),
            const SizedBox(height: 12),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => showProfileEditDialog(
                  context: context,
                  initial: p,
                ),
                borderRadius: BorderRadius.circular(24),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        scheme.surfaceContainerLow,
                        scheme.surfaceContainerHigh.withValues(alpha: 0.85),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: scheme.outlineVariant.withValues(alpha: 0.35),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: scheme.onSurface.withValues(alpha: 0.06),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 6, 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ProfileAvatar(
                          scheme: scheme,
                          hasRealName: hasRealName,
                          initial: initial,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  displayLine,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.newsreader(
                                    fontSize: 21,
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.w600,
                                    height: 1.2,
                                    color: scheme.onSurface,
                                  ),
                                ),
                                if (email.isNotEmpty || phone.isNotEmpty)
                                  const SizedBox(height: 6),
                                if (email.isNotEmpty)
                                  Text(
                                    email,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.manrope(
                                      fontSize: 12.5,
                                      height: 1.35,
                                      fontWeight: FontWeight.w500,
                                      color: scheme.onSurfaceVariant,
                                    ),
                                  ),
                                if (phone.isNotEmpty) ...[
                                  if (email.isNotEmpty) const SizedBox(height: 3),
                                  Text(
                                    phone,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.manrope(
                                      fontSize: 12.5,
                                      height: 1.35,
                                      fontWeight: FontWeight.w500,
                                      color: scheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        IconButton.filledTonal(
                          tooltip: l.profileEdit,
                          onPressed: () => showProfileEditDialog(
                            context: context,
                            initial: p,
                          ),
                          style: IconButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            padding: const EdgeInsets.all(10),
                          ),
                          icon: Icon(
                            Icons.edit_rounded,
                            size: 22,
                            color: scheme.onSecondaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({
    required this.scheme,
    required this.hasRealName,
    required this.initial,
  });

  final ColorScheme scheme;
  final bool hasRealName;
  final String initial;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.secondaryContainer,
            scheme.primaryContainer.withValues(alpha: 0.92),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.12),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: hasRealName
          ? Text(
              initial,
              style: GoogleFonts.newsreader(
                fontSize: 24,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w600,
                color: scheme.onSecondaryContainer,
              ),
            )
          : Icon(
              Icons.person_rounded,
              size: 28,
              color: scheme.onSecondaryContainer.withValues(alpha: 0.95),
            ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 22),
        const SizedBox(width: 10),
        Text(
          title.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(22),
      ),
      child: ListTile(
        title: Text(title, style: Theme.of(context).textTheme.titleMedium),
        subtitle: Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
                fontSize: 14,
              ),
        ),
        trailing: trailing,
      ),
    );
  }
}

class _SettingsNavTile extends StatelessWidget {
  const _SettingsNavTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(22),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: scheme.secondaryContainer,
          child: Icon(icon, size: 20, color: scheme.onSecondaryContainer),
        ),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}

class _ThemeChoice extends StatelessWidget {
  const _ThemeChoice({
    required this.title,
    required this.selected,
    required this.onTap,
    required this.darkPreview,
  });

  final String title;
  final bool selected;
  final VoidCallback onTap;
  final bool darkPreview;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? scheme.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: darkPreview ? const Color(0xFF1C1C1C) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: scheme.outlineVariant.withValues(alpha: 0.2),
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 48,
                    height: 4,
                    decoration: BoxDecoration(
                      color:  const Color(0xFF444444),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                if (selected)
                  Icon(Icons.check_circle_rounded, color: scheme.primary),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
