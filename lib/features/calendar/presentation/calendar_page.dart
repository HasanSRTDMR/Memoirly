import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:memoirly/core/di/providers.dart';
import 'package:memoirly/core/error/journal_stream_error.dart';
import 'package:memoirly/core/localization/app_localizations.dart';
import 'package:memoirly/core/theme/app_colors.dart';
import 'package:memoirly/core/widgets/archive_app_bar.dart';
import 'package:memoirly/core/widgets/writing_fab.dart';
import 'package:memoirly/domain/entities/journal_entry.dart';

class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});

  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  late DateTime _focusedMonth;
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    final n = DateTime.now();
    _focusedMonth = DateTime(n.year, n.month);
    _selectedDay = DateTime(n.year, n.month, n.day);
  }

  Set<DateTime> _daysWithEntries(List<JournalEntry> entries) {
    return entries
        .map((e) =>
            DateTime(e.createdAt.year, e.createdAt.month, e.createdAt.day))
        .toSet();
  }

  List<JournalEntry> _entriesForDay(List<JournalEntry> all, DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    return all.where((e) {
      final ed = DateTime(e.createdAt.year, e.createdAt.month, e.createdAt.day);
      return ed == d;
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final entriesAsync = ref.watch(journalEntriesStreamProvider);
    final firstWeekday = MaterialLocalizations.of(context).firstDayOfWeekIndex;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: ArchiveAppBar(title: l.calendar),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: WritingFab(
        heroTag: 'memoirly_fab_calendar',
        onPressed: () => context.push('/write'),
      ),
      body: entriesAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator.adaptive()),
        error: (e, _) => JournalStreamErrorView(
          message: describeJournalStreamError(e, l),
        ),
        data: (entries) {
          final markers = _daysWithEntries(entries);
          final sel = _selectedDay ?? DateTime.now();
          final dayEntries = _entriesForDay(entries, sel);

          return LayoutBuilder(
            builder: (context, constraints) {
              final pad = constraints.maxWidth < 360 ? 16.0 : 24.0;
              return ListView(
                padding: EdgeInsets.fromLTRB(pad, 8, pad, 120),
                children: [
                  Text(
                    l.timelineView,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          DateFormat.yMMMM(locale).format(_focusedMonth),
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                      IconButton(
                        onPressed: () => setState(() {
                          _focusedMonth = DateTime(
                            _focusedMonth.year,
                            _focusedMonth.month - 1,
                          );
                        }),
                        icon: const Icon(Icons.chevron_left_rounded),
                      ),
                      IconButton(
                        onPressed: () => setState(() {
                          _focusedMonth = DateTime(
                            _focusedMonth.year,
                            _focusedMonth.month + 1,
                          );
                        }),
                        icon: const Icon(Icons.chevron_right_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.onSurface
                          : AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: _MonthGrid(
                        month: _focusedMonth,
                        firstWeekday: firstWeekday,
                        selectedDay: sel,
                        markers: markers,
                        isDark: isDark,
                        onSelect: (d) => setState(() => _selectedDay = d),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          DateFormat.yMMMMEEEEd(locale).format(sel),
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontFamily: 'Newsreader',
                                    fontStyle: FontStyle.italic,
                                    fontSize: 22,
                                  ),
                        ),
                      ),
                      Text(
                        l.entriesCount(dayEntries.length),
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (dayEntries.isEmpty)
                    Text(
                      l.noSearchResults,
                      style: Theme.of(context).textTheme.bodyMedium,
                    )
                  else
                    ...dayEntries.map(
                      (e) => _DayEntryTile(
                        entry: e,
                        locale: locale,
                        onTap: () => context.push('/entry/${e.id}'),
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.month,
    required this.firstWeekday,
    required this.selectedDay,
    required this.markers,
    required this.onSelect,
    required this.isDark,
  });

  final DateTime month;
  final int firstWeekday;
  final DateTime selectedDay;
  final Set<DateTime> markers;
  final ValueChanged<DateTime> onSelect;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    final first = DateTime(month.year, month.month);
    var leading = (first.weekday - firstWeekday + 7) % 7;
    final cells = <int?>[];

    for (var i = 0; i < leading; i++) {
      cells.add(null);
    }
    for (var d = 1; d <= daysInMonth; d++) {
      cells.add(d);
    }
    while (cells.length % 7 != 0) {
      cells.add(null);
    }

    return Column(
      children: [
        Row(
          children: List.generate(7, (i) {
            final loc = MaterialLocalizations.of(context);
            final labels = loc.narrowWeekdays;
            final idx = (firstWeekday + i) % 7;
            return Expanded(
              child: Center(
                child: Text(
                  labels[idx],
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontSize: 9,
                        color: isDark
                            ? AppColors.onSecondary.withValues(alpha: 0.5)
                            : AppColors.onSurfaceVariant.withValues(alpha: 0.5),
                      ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 8,
            crossAxisSpacing: 4,
            // Taller cells avoid RenderFlex overflow with day number + dot
            childAspectRatio: 0.82,
          ),
          itemCount: cells.length,
          itemBuilder: (context, i) {
            final dayNum = cells[i];
            if (dayNum == null) {
              return const SizedBox.shrink();
            }
            final date = DateTime(month.year, month.month, dayNum);
            final isSel = DateUtils.isSameDay(date, selectedDay);
            final has = markers.contains(date);
            return InkWell(
              onTap: () => onSelect(date),
              borderRadius: BorderRadius.circular(999),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSel
                            ? AppColors.primary
                            : (isDark
                                ? AppColors.onSurfaceVariant
                                    .withValues(alpha: 0.1)
                                : Colors.transparent),
                      ),
                      child: Text(
                        '$dayNum',
                        style: TextStyle(
                          fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                          fontSize: 13,
                          color: isSel
                              ? AppColors.onPrimary
                              : isDark
                                  ? AppColors.surface
                                  : AppColors.onSurface,
                        ),
                      ),
                    ),
                    if (has)
                      Container(
                        margin: const EdgeInsets.only(top: 2),
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.secondary,
                        ),
                      )
                    else
                      const SizedBox(height: 6),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _DayEntryTile extends StatelessWidget {
  const _DayEntryTile({
    required this.entry,
    required this.locale,
    required this.onTap,
  });

  final JournalEntry entry;
  final String locale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final time = DateFormat.jm(locale).format(entry.createdAt);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: InkWell(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.edit_note_rounded,
                size: 16,
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          entry.title.isNotEmpty ? entry.title : '…',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontFamily: 'Newsreader',
                                    fontStyle: FontStyle.italic,
                                    fontSize: 20,
                                  ),
                        ),
                      ),
                      Text(
                        time,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    entry.content,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
