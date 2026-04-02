import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:memoirly/core/di/providers.dart';
import 'package:memoirly/core/localization/app_localizations.dart';
import 'package:memoirly/core/localization/mood_localizations.dart';
import 'package:share_plus/share_plus.dart';

class EntryDetailPage extends ConsumerWidget {
  const EntryDetailPage({super.key, required this.entryId});

  final String entryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final async = ref.watch(entryByIdProvider(entryId));

    return async.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator.adaptive()),
      ),
      error: (_, __) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(child: Text(l.errorGeneric)),
      ),
      data: (entry) {
        if (entry == null) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => context.pop(),
              ),
            ),
            body: Center(child: Text(l.errorGeneric)),
          );
        }
        final scheme = Theme.of(context).colorScheme;
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final date = DateFormat.yMMMMd(locale).format(entry.createdAt);
        final time = DateFormat.jm(locale).format(entry.createdAt);
        final weekday = DateFormat.EEEE(locale).format(entry.createdAt);
        final mood = entry.mood;
        final imagePathsExisting = entry.imagePaths
            .where((path) => File(path).existsSync())
            .toList();

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => context.pop(),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(date, style: Theme.of(context).appBarTheme.titleTextStyle),
                Text(
                  '$weekday · $time',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
            actions: [
              if (mood != null && mood.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Chip(
                    avatar: const Icon(Icons.mood, size: 18),
                    label: Text(
                      moodLabel(l, mood),
                      style: const TextStyle(fontSize: 11),
                    ),
                    backgroundColor: scheme.secondaryContainer,
                    side: BorderSide.none,
                  ),
                ),
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => context.push('/write?id=${entry.id}'),
              ),
              IconButton(
                icon: Icon(Icons.delete_outline_rounded, color: scheme.error),
                onPressed: () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text(l.deleteConfirmTitle),
                      content: Text(l.deleteConfirmBody),
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
                  if (ok == true && context.mounted) {
                    await ref.read(deleteEntryUseCaseProvider).call(entry.id);
                    ref.invalidate(entryByIdProvider(entry.id));
                    if (context.mounted) context.pop();
                  }
                },
              ),
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: isDark
                      ? scheme.surfaceContainerHigh.withValues(alpha: 0.92)
                      : Colors.white.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.35)
                          : Colors.black.withValues(alpha: 0.08),
                      blurRadius: 40,
                    ),
                  ],
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FilledButton.icon(
                        onPressed: () {
                          final text =
                              '${entry.title}\n\n${entry.content}\n\n${entry.tags.map((t) => '#$t').join(' ')}';
                          Share.share(text, subject: entry.title);
                        },
                        icon: const Icon(Icons.ios_share_rounded, size: 20),
                        label: Text(l.shareEntry),
                        style: FilledButton.styleFrom(
                          backgroundColor: scheme.primary,
                          foregroundColor: scheme.onPrimary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
            children: [
              Text(
                entry.title.isNotEmpty ? entry.title : l.newEntry,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontSize: 36,
                    ),
              ),
              const SizedBox(height: 16),
              if (imagePathsExisting.isNotEmpty) ...[
                SizedBox(
                  height: 120,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: imagePathsExisting.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, i) {
                      final file = File(imagePathsExisting[i]);
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: Image.file(
                            file,
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ],
              Text(
                entry.content,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: entry.contentColorArgb != null
                          ? Color(entry.contentColorArgb!)
                          : null,
                    ),
              ),
              if (entry.tags.isNotEmpty) ...[
                const SizedBox(height: 28),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: entry.tags
                      .map(
                        (t) => Chip(
                          label: Text('#$t'),
                          backgroundColor: scheme.surfaceContainerLow,
                          side: BorderSide.none,
                        ),
                      )
                      .toList(),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
