import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:patres/blocs/library_bloc.dart';
import 'package:patres/blocs/locale_bloc.dart';
import 'package:patres/blocs/plan_bloc.dart';
import 'package:patres/blocs/theme_bloc.dart';
import 'package:patres/l10n/generated/app_localizations.dart';
import 'package:patres/models/reading_plan.dart';
import 'package:patres/screens/plan_detail_screen.dart';
import 'package:patres/services/text_service.dart';
import 'package:patres/theme.dart';

// ---------------------------------------------------------------------------
// Fakes & mocks
// ---------------------------------------------------------------------------

class _MockPlanBloc extends MockBloc<PlanEvent, PlanState>
    implements PlanBloc {}

class _FakePlanEvent extends Fake implements PlanEvent {}
class _FakePlanState extends Fake implements PlanState {}

const _testManifestJson = '''
{
  "version": "1.0.0",
  "texts": []
}
''';

const _testDailyReadingsJson = '[]';

class _FakeAssetBundle extends CachingAssetBundle {
  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    if (key == 'assets/texts/manifest.json') return _testManifestJson;
    if (key == 'assets/daily_readings.json') return _testDailyReadingsJson;
    throw FlutterError('Asset not found: $key');
  }

  @override
  Future<ByteData> load(String key) async {
    final str = await loadString(key);
    return ByteData.view(Uint8List.fromList(utf8.encode(str)).buffer);
  }
}

TextService _fakeTextService() => TextService(assetBundle: _FakeAssetBundle());

// ---------------------------------------------------------------------------
// Test wrapper
// ---------------------------------------------------------------------------

Widget _testApp(
  Widget child, {
  required PlanBloc planBloc,
  ThemeBloc? themeBloc,
  LibraryBloc? libraryBloc,
  LocaleBloc? localeBloc,
}) {
  final tBloc = themeBloc ?? ThemeBloc();
  final lBloc = libraryBloc ?? LibraryBloc(textService: _fakeTextService());
  final lcBloc = localeBloc ?? LocaleBloc();
  return MultiBlocProvider(
    providers: [
      BlocProvider<ThemeBloc>.value(value: tBloc),
      BlocProvider<LibraryBloc>.value(value: lBloc),
      BlocProvider<LocaleBloc>.value(value: lcBloc),
      BlocProvider<PlanBloc>.value(value: planBloc),
    ],
    child: BlocBuilder<ThemeBloc, ThemeState>(
      bloc: tBloc,
      builder: (context, themeState) {
        return BlocBuilder<LocaleBloc, LocaleState>(
          bloc: lcBloc,
          builder: (context, localeState) {
            return MaterialApp(
              theme: PatresTheme.themeFor(themeState.themeMode),
              locale: localeState.locale,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              home: Scaffold(body: child),
            );
          },
        );
      },
    ),
  );
}

// ---------------------------------------------------------------------------
// Test data
// ---------------------------------------------------------------------------

const _testPlan = ReadingPlan(
  id: 'beginners',
  title: 'Wprowadzenie do Ojc\u00f3w',
  description: 'Kr\u00f3tki plan dla pocz\u0105tkuj\u0105cych czytelnik\u00f3w patrystyki.',
  totalDays: 5,
  icon: 'school',
  days: [
    PlanDay(
      day: 1,
      title: 'Dwie drogi',
      textId: 'didache',
      chapterIndex: 0,
      description: 'Wst\u0119p do Didache',
    ),
    PlanDay(
      day: 2,
      title: 'Przykazania',
      textId: 'didache',
      chapterIndex: 1,
    ),
    PlanDay(
      day: 3,
      title: 'Unikanie z\u0142a',
      textId: 'didache',
      chapterIndex: 2,
    ),
    PlanDay(
      day: 4,
      title: 'Chrzest i post',
      textId: 'didache',
      chapterIndex: 3,
    ),
    PlanDay(
      day: 5,
      title: 'Eucharystia',
      textId: 'didache',
      chapterIndex: 4,
    ),
  ],
);

final _startedProgress = PlanProgress(
  planId: 'beginners',
  startedAt: DateTime(2026, 4, 1),
  completedDays: const {1, 3},
  currentStreak: 2,
  longestStreak: 3,
);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUpAll(() {
    registerFallbackValue(_FakePlanEvent());
    registerFallbackValue(_FakePlanState());
  });

  group('PlanDetailScreen', () {
    late _MockPlanBloc planBloc;

    setUp(() {
      planBloc = _MockPlanBloc();
    });

    tearDown(() {
      planBloc.close();
    });

    testWidgets('shows loading when plan not found', (tester) async {
      // State with no plans — the plan lookup returns null
      when(() => planBloc.state).thenReturn(const PlanState(
        status: PlanStatus.loaded,
        plans: [],
      ));

      await tester.pumpWidget(
        _testApp(
          const PlanDetailScreen(planId: 'beginners'),
          planBloc: planBloc,
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows plan description and start prompt when not started',
        (tester) async {
      when(() => planBloc.state).thenReturn(
        PlanState(
          status: PlanStatus.loaded,
          plans: [_testPlan],
          progressMap: const {
            'beginners': PlanProgress(planId: 'beginners'),
          },
        ),
      );

      await tester.pumpWidget(
        _testApp(
          const PlanDetailScreen(planId: 'beginners'),
          planBloc: planBloc,
        ),
      );
      await tester.pumpAndSettle();

      // Plan title in AppBar
      expect(find.text('Wprowadzenie do Ojc\u00f3w'), findsOneWidget);

      // Plan description
      expect(
        find.text(
          'Kr\u00f3tki plan dla pocz\u0105tkuj\u0105cych czytelnik\u00f3w patrystyki.',
        ),
        findsOneWidget,
      );

      // Start prompt — Polish: "Rozpocznij plan, aby śledzić postępy"
      expect(
        find.text('Rozpocznij plan, aby \u015bledzi\u0107 post\u0119py'),
        findsOneWidget,
      );

      // Start button — Polish: "Rozpocznij plan"
      expect(find.text('Rozpocznij plan'), findsOneWidget);

      // Auto-stories icon in the prompt area
      expect(find.byIcon(Icons.auto_stories_rounded), findsOneWidget);
    });

    testWidgets('shows progress stats when plan is started', (tester) async {
      when(() => planBloc.state).thenReturn(
        PlanState(
          status: PlanStatus.loaded,
          plans: [_testPlan],
          progressMap: {
            'beginners': _startedProgress,
          },
        ),
      );

      await tester.pumpWidget(
        _testApp(
          const PlanDetailScreen(planId: 'beginners'),
          planBloc: planBloc,
        ),
      );
      await tester.pumpAndSettle();

      // Stats chips: completed/total — "2/5"
      expect(find.text('2/5'), findsOneWidget);

      // Current streak — "2" (also appears as day 2 badge number)
      expect(find.text('2'), findsAtLeastNWidgets(1));

      // Longest streak — "3"
      expect(find.text('3'), findsOneWidget);

      // Polish stat labels
      expect(find.text('uko\u0144czono'), findsOneWidget); // planCompleted
      expect(find.text('seria'), findsOneWidget); // planStreak
      expect(find.text('rekord'), findsOneWidget); // planLongestStreak

      // Progress bar should be visible
      expect(find.byType(LinearProgressIndicator), findsOneWidget);

      // No start prompt when plan is started
      expect(
        find.text('Rozpocznij plan, aby \u015bledzi\u0107 post\u0119py'),
        findsNothing,
      );
    });

    testWidgets('shows day tiles with completion state', (tester) async {
      when(() => planBloc.state).thenReturn(
        PlanState(
          status: PlanStatus.loaded,
          plans: [_testPlan],
          progressMap: {
            'beginners': _startedProgress,
          },
        ),
      );

      await tester.pumpWidget(
        _testApp(
          const PlanDetailScreen(planId: 'beginners'),
          planBloc: planBloc,
        ),
      );
      await tester.pumpAndSettle();

      // Day titles should be visible
      expect(find.text('Dwie drogi'), findsOneWidget);
      expect(find.text('Przykazania'), findsOneWidget);
      expect(find.text('Unikanie z\u0142a'), findsOneWidget);

      // Day description for day 1
      expect(find.text('Wst\u0119p do Didache'), findsOneWidget);

      // Uncompleted day toggle icons (days 2, 4, 5 are not completed;
      // some may be scrolled off screen)
      expect(
        find.byIcon(Icons.radio_button_unchecked_rounded),
        findsAtLeastNWidgets(2),
      );

      // Completed day toggle icons (days 1, 3 are completed)
      expect(
        find.byIcon(Icons.check_circle_rounded),
        findsAtLeastNWidgets(2),
      );
    });

    testWidgets('shows completed check icon for completed days',
        (tester) async {
      when(() => planBloc.state).thenReturn(
        PlanState(
          status: PlanStatus.loaded,
          plans: [_testPlan],
          progressMap: {
            'beginners': _startedProgress,
          },
        ),
      );

      await tester.pumpWidget(
        _testApp(
          const PlanDetailScreen(planId: 'beginners'),
          planBloc: planBloc,
        ),
      );
      await tester.pumpAndSettle();

      // Completed days (1 and 3) show a check_rounded icon in the day badge
      expect(find.byIcon(Icons.check_rounded), findsAtLeastNWidgets(2));

      // Uncompleted day numbers should be displayed as text
      // Day 2 (may also appear in stats)
      expect(find.text('2'), findsAtLeastNWidgets(1));
      // Day 4
      expect(find.text('4'), findsOneWidget);
    });
  });
}
