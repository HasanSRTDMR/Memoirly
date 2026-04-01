import 'dart:convert';
import 'dart:ui' show PlatformDispatcher;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memoirly/core/di/providers.dart';
import 'package:memoirly/core/import_export/journal_txt_codec.dart';
import 'package:memoirly/core/localization/app_localizations.dart';
import 'package:memoirly/core/widgets/archive_app_bar.dart';
import 'package:memoirly/features/settings/presentation/pin_setup_sheet.dart';
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
      appBar: const ArchiveAppBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
        children: [
          Text(
            l.settingsTitle,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          Text(
            l.settingsSubtitle,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
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
                  color: darkPreview ? const Color(0xFF1C1C1C) : scheme.surface,
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
                      color: darkPreview
                          ? const Color(0xFF444444)
                          : scheme.primary.withValues(alpha: 0.12),
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
