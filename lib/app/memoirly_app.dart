import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memoirly/core/di/providers.dart';
import 'package:memoirly/core/localization/app_localizations.dart';
import 'package:memoirly/core/theme/app_theme.dart';
import 'package:memoirly/features/security/presentation/pin_unlock_overlay.dart';

class MemoirlyApp extends ConsumerWidget {
  const MemoirlyApp({super.key, required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsRepositoryProvider);

    return StreamBuilder<ThemeMode>(
      stream: settings.watchThemeMode(),
      initialData: ThemeMode.system,
      builder: (context, themeSnap) {
        return StreamBuilder<Locale?>(
          stream: settings.watchLocaleOverride(),
          initialData: null,
          builder: (context, localeSnap) {
            final mode = themeSnap.data ?? ThemeMode.system;
            return MaterialApp.router(
              debugShowCheckedModeBanner: false,
              routerConfig: router,
              locale: localeSnap.data,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              theme: buildAppTheme(Brightness.light),
              darkTheme: buildAppTheme(Brightness.dark),
              themeMode: mode,
              builder: (context, child) {
                return PinUnlockOverlay(
                  child: child ?? const SizedBox.shrink(),
                );
              },
            );
          },
        );
      },
    );
  }
}
