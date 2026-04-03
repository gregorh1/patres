import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:patres/screens/home_screen.dart';
import 'package:patres/screens/library_screen.dart';
import 'package:patres/screens/reader_screen.dart';
import 'package:patres/screens/settings_screen.dart';
import 'package:patres/widgets/shell_scaffold.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/home',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => ShellScaffold(child: child),
      routes: [
        GoRoute(
          path: '/home',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: HomeScreen(),
          ),
        ),
        GoRoute(
          path: '/library',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: LibraryScreen(),
          ),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: SettingsScreen(),
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/reader/:id',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => ReaderScreen(
        textId: state.pathParameters['id'] ?? '',
      ),
    ),
  ],
);
