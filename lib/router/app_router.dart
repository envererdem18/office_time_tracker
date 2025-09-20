import 'package:go_router/go_router.dart';

import '../models/check_in_out.dart';
import '../pages/demo_page.dart';
import '../pages/edit_record_page.dart';
import '../pages/history_page.dart';
import '../pages/home_page.dart';
import '../pages/shell_page.dart';
import '../pages/statistics_page.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/home',
    routes: [
      ShellRoute(
        builder: (context, state, child) => ShellPage(child: child),
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            pageBuilder: (context, state) => const NoTransitionPage(child: HomePage()),
            routes: [
              GoRoute(
                path: 'demo',
                name: 'demo',
                builder: (context, state) => DemoPage(),
              ),
            ],
          ),
          GoRoute(
            path: '/history',
            name: 'history',
            pageBuilder: (context, state) => const NoTransitionPage(child: HistoryPage()),
            routes: [
              GoRoute(
                path: 'edit',
                name: 'edit-record',
                builder: (context, state) {
                  final record = state.extra as CheckInOut;
                  return EditRecordPage(record: record);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/statistics',
            name: 'statistics',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: StatisticsPage()),
          ),
        ],
      ),
    ],
  );
}
