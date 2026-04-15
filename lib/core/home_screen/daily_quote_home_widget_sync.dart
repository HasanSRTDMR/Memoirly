import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'package:memoirly/core/di/providers.dart';
import 'package:memoirly/domain/entities/daily_quote.dart';

/// Pushes the daily quote into the Android home screen widget (see
/// [DailyQuoteWidgetProvider]) whenever the quote or app locale changes.
class DailyQuoteHomeWidgetSync extends ConsumerStatefulWidget {
  const DailyQuoteHomeWidgetSync({super.key});

  @override
  ConsumerState<DailyQuoteHomeWidgetSync> createState() =>
      _DailyQuoteHomeWidgetSyncState();
}

class _DailyQuoteHomeWidgetSyncState
    extends ConsumerState<DailyQuoteHomeWidgetSync> {
  Locale? _locale;
  String? _lastSyncedKey;

  static String _syncKey(DailyQuote q, Locale locale) =>
      '${q.textEn}|${q.textTr}|${q.author}|${locale.languageCode}';

  Future<void> _push(DailyQuote quote, Locale locale) async {
    if (kIsWeb) return;
    if (!Platform.isAndroid) return;

    final key = _syncKey(quote, locale);
    if (_lastSyncedKey == key) return;

    try {
      final text = quote.textForLocale(locale);
      await HomeWidget.saveWidgetData<String>('daily_quote_text', text);
      await HomeWidget.saveWidgetData<String>(
        'daily_quote_author',
        quote.author ?? '',
      );
      await HomeWidget.updateWidget(androidName: 'DailyQuoteWidgetProvider');
      if (mounted) {
        _lastSyncedKey = key;
      }
    } catch (e, st) {
      debugPrint('DailyQuoteHomeWidgetSync: $e\n$st');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final next = Localizations.localeOf(context);
    if (_locale != next) {
      _locale = next;
      final q = ref.read(dailyQuoteProvider).valueOrNull;
      if (q != null) {
        unawaited(_push(q, next));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<DailyQuote>>(dailyQuoteProvider, (prev, next) {
      next.whenData((q) {
        unawaited(_push(q, Localizations.localeOf(context)));
      });
    });
    ref.watch(dailyQuoteProvider);
    return const SizedBox.shrink();
  }
}
