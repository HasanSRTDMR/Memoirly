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
          return WriteEntryPage(entryId: id, initialMoodKey: mood);
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
