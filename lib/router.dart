import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:patres/blocs/audio_bloc.dart';
import 'package:patres/blocs/reader_bloc.dart';
import 'package:patres/blocs/reader_event.dart';
import 'package:patres/blocs/search_bloc.dart';
import 'package:patres/blocs/tts_generation_bloc.dart';
import 'package:patres/blocs/tts_generation_event.dart';
import 'package:patres/screens/audio_downloads_screen.dart';
import 'package:patres/screens/home_screen.dart';
import 'package:patres/screens/library_screen.dart';
import 'package:patres/screens/plan_detail_screen.dart';
import 'package:patres/screens/plans_screen.dart';
import 'package:patres/screens/reader_screen.dart';
import 'package:patres/screens/search_screen.dart';
import 'package:patres/screens/settings_screen.dart';
import 'package:patres/screens/author_profile_screen.dart';
import 'package:patres/screens/splash_screen.dart';
import 'package:patres/services/audio_service.dart';
import 'package:patres/services/database_service.dart';
import 'package:patres/services/reader_storage_service.dart';
import 'package:patres/services/search_service.dart';
import 'package:patres/services/text_service.dart';
import 'package:patres/widgets/shell_scaffold.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createRouter({
  DatabaseService? databaseService,
  SearchService? searchService,
  TtsAudioService? ttsAudioService,
  AudioBloc? audioBloc,
  TtsGenerationBloc? ttsGenerationBloc,
}) {
  final dbService = databaseService ?? DatabaseService();
  final ttsService = ttsAudioService ?? TtsAudioService();

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const SplashScreen(),
          transitionsBuilder:
              (context, animation, secondaryAnimation, child) =>
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
            path: '/plans',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: PlansScreen(),
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
        path: '/plans/:id',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final planId = state.pathParameters['id'] ?? '';
          return PlanDetailScreen(planId: planId);
        },
      ),
      GoRoute(
        path: '/author/:id',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final authorId = state.pathParameters['id'] ?? '';
          return AuthorProfileScreen(authorId: authorId);
        },
      ),
      GoRoute(
        path: '/reader/:id',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final textId = state.pathParameters['id'] ?? '';
          final chapterParam = state.uri.queryParameters['chapter'];
          final initialChapter =
              chapterParam != null ? int.tryParse(chapterParam) : null;
          return MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (_) => ReaderBloc(
                  textService: const TextService(),
                  storageService: ReaderStorageService(
                    databaseService: dbService,
                  ),
                )..add(ReaderLoadRequested(
                    textId: textId, initialChapter: initialChapter)),
              ),
              BlocProvider(
                create: (_) =>
                    audioBloc ?? AudioBloc(),
              ),
              BlocProvider(
                create: (_) =>
                    ttsGenerationBloc ??
                    TtsGenerationBloc(audioService: ttsService),
              ),
            ],
            child: ReaderScreen(textId: textId),
          );
        },
      ),
      GoRoute(
        path: '/search',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final svc = searchService ??
              SearchService(
                databaseService: dbService,
                textService: const TextService(),
              );
          return BlocProvider(
            create: (_) =>
                SearchBloc(searchService: svc)
                  ..add(const SearchIndexRequested()),
            child: const SearchScreen(),
          );
        },
      ),
      GoRoute(
        path: '/audio-downloads',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          return BlocProvider(
            create: (_) =>
                ttsGenerationBloc ??
                TtsGenerationBloc(audioService: ttsService)
                  ..add(const TtsLoadCacheStatus()),
            child: const AudioDownloadsScreen(),
          );
        },
      ),
    ],
  );
}

// Default router instance for the app.
final router = createRouter();
