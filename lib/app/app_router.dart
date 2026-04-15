import 'package:go_router/go_router.dart';
import 'package:memoirly/core/navigation/root_navigator_key.dart';
import 'package:memoirly/features/calendar/presentation/calendar_page.dart';
import 'package:memoirly/features/home/presentation/home_page.dart';
import 'package:memoirly/features/insights/presentation/insights_page.dart';
import 'package:memoirly/features/journal/presentation/entry_detail_page.dart';
import 'package:memoirly/features/journal/presentation/write_entry_page.dart';
import 'package:memoirly/features/onboarding/presentation/onboarding_page.dart';
import 'package:memoirly/features/search/presentation/search_page.dart';
import 'package:memoirly/features/settings/presentation/settings_page.dart';
import 'package:memoirly/features/shell/main_shell.dart';

/// `YYYY-MM-DD` → o gün, şu anki saat (yerel). Geçersizse null.
DateTime? _parseInitialEntryDate(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  final parts = raw.split('-');
  if (parts.length != 3) return null;
  final y = int.tryParse(parts[0]);
  final m = int.tryParse(parts[1]);
  final d = int.tryParse(parts[2]);
  if (y == null || m == null || d == null) return null;
  if (m < 1 || m > 12 || d < 1 || d > 31) return null;
  final now = DateTime.now();
  return DateTime(
    y,
    m,
    d,
    now.hour,
    now.minute,
    now.second,
    now.millisecond,
    now.microsecond,
  );
}

GoRouter createAppRouter({required String initialLocation}) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/onboarding',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const OnboardingPage(),
      ),
      StatefulShellRoute.indexedStack(
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/search',
                builder: (context, state) => const SearchPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/calendar',
                builder: (context, state) => const CalendarPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/insights',
                builder: (context, state) => const InsightsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsPage(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/write',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final id = state.uri.queryParameters['id'];
          final mood = state.uri.queryParameters['mood'];
          final initialCreatedAt = _parseInitialEntryDate(
            state.uri.queryParameters['date'],
          );
          return WriteEntryPage(
            entryId: id,
            initialMoodKey: mood,
            initialCreatedAt: initialCreatedAt,
          );
        },
      ),
      GoRoute(
        path: '/entry/:id',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return EntryDetailPage(entryId: id);
        },
      ),
    ],
  );
}
