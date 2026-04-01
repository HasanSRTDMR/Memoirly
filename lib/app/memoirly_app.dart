import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memoirly/core/di/providers.dart';
import 'package:memoirly/core/localization/app_localizations.dart';
import 'package:memoirly/core/theme/app_theme.dart';
import 'package:memoirly/features/security/presentation/pin_unlock_overlay.dart';

Locale _memoirlyLocaleFallback() {
  final lang = PlatformDispatcher.instance.locale.languageCode;
  return lang == 'tr' ? const Locale('tr') : const Locale('en');
}

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
        return StreamBuilder<Locale>(
          stream: settings.watchLocaleOverride(),
          builder: (context, localeSnap) {
            final mode = themeSnap.data ?? ThemeMode.system;
            return MaterialApp.router(
              debugShowCheckedModeBanner: false,
              routerConfig: router,
              locale: localeSnap.data ?? _memoirlyLocaleFallback(),
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
                final theme = Theme.of(context);
                final brightness = theme.brightness;
                final lightContent =
                    brightness == Brightness.dark ? Brightness.light : Brightness.dark;
                final navScrim = theme.colorScheme.surface;
                SystemChrome.setSystemUIOverlayStyle(
                  SystemUiOverlayStyle(
                    statusBarColor: Colors.transparent,
                    systemNavigationBarColor: navScrim,
                    systemNavigationBarContrastEnforced: false,
                    statusBarIconBrightness: lightContent,
                    systemNavigationBarIconBrightness: lightContent,
                  ),
                );
                return ColoredBox(
                  color: navScrim,
                  child: PinUnlockOverlay(
                    child: child ?? const SizedBox.shrink(),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
