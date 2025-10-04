import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/check_in_out.dart';
import '../pages/demo_page.dart';
import '../pages/edit_record_page.dart';
import '../pages/history_page.dart';
import '../pages/home_page.dart';
import '../pages/statistics_page.dart';
import 'route_shell_screen.dart';

enum AppRoute {
  // home
  home,
  demo,
  // history
  history,
  edit,
  // statistics
  statistics;

  String get path => "/$name";
  String get absolutePath => name;
}

final _homeNavigatorKey = GlobalKey<NavigatorState>();
final _historyNavigatorKey = GlobalKey<NavigatorState>();
final _statisticsNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/${AppRoute.home.name}',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            RouteShellScreen(path: state.fullPath, shell: navigationShell),
        branches: [
          StatefulShellBranch(
            navigatorKey: _homeNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoute.home.path,
                name: AppRoute.home.name,
                builder: (context, state) => HomePage(),
                routes: [
                  GoRoute(
                    path: AppRoute.demo.absolutePath,
                    name: AppRoute.demo.name,
                    builder: (context, state) => DemoPage(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _historyNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoute.history.path,
                name: AppRoute.history.name,
                builder: (context, state) => HistoryPage(),
                routes: [
                  GoRoute(
                    path: AppRoute.edit.absolutePath,
                    name: AppRoute.edit.name,
                    builder: (context, state) =>
                        EditRecordPage(record: state.extra as CheckInOut),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _statisticsNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoute.statistics.path,
                name: AppRoute.statistics.name,
                builder: (context, state) => StatisticsPage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
