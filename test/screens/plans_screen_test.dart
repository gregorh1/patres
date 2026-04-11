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
import 'package:patres/screens/plans_screen.dart';
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

final _samplePlans = [
  const ReadingPlan(
    id: 'beginners',
    title: 'Wprowadzenie do Ojców',
    description: 'Krótki plan dla początkujących czytelników patrystyki.',
    totalDays: 7,
    icon: 'school',
    days: [
      PlanDay(day: 1, title: 'Dzień 1', textId: 'didache', chapterIndex: 0),
      PlanDay(day: 2, title: 'Dzień 2', textId: 'didache', chapterIndex: 1),
    ],
  ),
  const ReadingPlan(
    id: 'desert-fathers',
    title: 'Ojcowie Pustyni',
    description: 'Duchowość pustyni w tradycji chrześcijańskiej.',
    totalDays: 14,
    icon: 'terrain',
    days: [
      PlanDay(
        day: 1,
        title: 'Dzień 1',
        textId: 'augustyn-wyznania',
        chapterIndex: 0,
      ),
    ],
  ),
];

final _startedProgress = PlanProgress(
  planId: 'beginners',
  startedAt: DateTime(2026, 4, 1),
  completedDays: const {1, 2, 3},
  currentStreak: 3,
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

  group('PlansScreen', () {
    late _MockPlanBloc planBloc;

    setUp(() {
      planBloc = _MockPlanBloc();
    });

    tearDown(() {
      planBloc.close();
    });

    testWidgets('shows loading indicator initially', (tester) async {
      when(() => planBloc.state).thenReturn(const PlanState());

      await tester.pumpWidget(
        _testApp(const PlansScreen(), planBloc: planBloc),
      );
      await tester.pump();

      // Initial status shows CircularProgressIndicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows plan cards when loaded', (tester) async {
      when(() => planBloc.state).thenReturn(
        PlanState(
          status: PlanStatus.loaded,
          plans: _samplePlans,
          progressMap: {
            'beginners': const PlanProgress(planId: 'beginners'),
            'desert-fathers': const PlanProgress(planId: 'desert-fathers'),
          },
        ),
      );

      await tester.pumpWidget(
        _testApp(const PlansScreen(), planBloc: planBloc),
      );
      await tester.pumpAndSettle();

      // App bar title — Polish: "Plany" (SliverAppBar.large renders title twice)
      expect(find.text('Plany'), findsAtLeastNWidgets(1));

      // Plan titles
      expect(find.text('Wprowadzenie do Ojców'), findsOneWidget);
      expect(find.text('Ojcowie Pustyni'), findsOneWidget);

      // Plan descriptions
      expect(
        find.text('Krótki plan dla początkujących czytelników patrystyki.'),
        findsOneWidget,
      );
      expect(
        find.text('Duchowość pustyni w tradycji chrześcijańskiej.'),
        findsOneWidget,
      );

      // Day counts — Polish: "7 dni", "14 dni"
      expect(find.text('7 dni'), findsOneWidget);
      expect(find.text('14 dni'), findsOneWidget);

      // No progress bar when plans are not started
      expect(find.byType(LinearProgressIndicator), findsNothing);
    });

    testWidgets('shows progress on started plans', (tester) async {
      when(() => planBloc.state).thenReturn(
        PlanState(
          status: PlanStatus.loaded,
          plans: _samplePlans,
          progressMap: {
            'beginners': _startedProgress,
            'desert-fathers': const PlanProgress(planId: 'desert-fathers'),
          },
        ),
      );

      await tester.pumpWidget(
        _testApp(const PlansScreen(), planBloc: planBloc),
      );
      await tester.pumpAndSettle();

      // Started plan shows a LinearProgressIndicator
      expect(find.byType(LinearProgressIndicator), findsOneWidget);

      // Progress percentage: 3 of 7 days = 43%
      expect(find.text('43%'), findsOneWidget);

      // "W trakcie" badge for the started plan
      expect(find.text('W trakcie'), findsOneWidget);
    });

    testWidgets('shows error state', (tester) async {
      when(() => planBloc.state).thenReturn(
        const PlanState(status: PlanStatus.error),
      );

      await tester.pumpWidget(
        _testApp(const PlansScreen(), planBloc: planBloc),
      );
      await tester.pumpAndSettle();

      // Polish error: "Nie udało się załadować planów"
      expect(
        find.text('Nie udało się załadować planów'),
        findsOneWidget,
      );
    });
  });
}
