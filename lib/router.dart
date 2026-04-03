import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:patres/blocs/reader_bloc.dart';
import 'package:patres/blocs/reader_event.dart';
import 'package:patres/screens/home_screen.dart';
import 'package:patres/screens/library_screen.dart';
import 'package:patres/screens/reader_screen.dart';
import 'package:patres/screens/settings_screen.dart';
import 'package:patres/screens/splash_screen.dart';
import 'package:patres/services/reader_storage_service.dart';
import 'package:patres/services/text_service.dart';
import 'package:patres/widgets/shell_scaffold.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      parentNavigatorKey: rootNavigatorKey,
      pageBuilder: (context, state) => CustomTransitionPage(
        child: const SplashScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    ),
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
      builder: (context, state) {
        final textId = state.pathParameters['id'] ?? '';
        return BlocProvider(
          create: (_) => ReaderBloc(
            textService: const TextService(),
            storageService: ReaderStorageService(),
          )..add(ReaderLoadRequested(textId: textId)),
          child: ReaderScreen(textId: textId),
        );
      },
    ),
  ],
);
