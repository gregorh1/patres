import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:patres/blocs/reader_bloc.dart';
import 'package:patres/blocs/reader_event.dart';
import 'package:patres/blocs/reader_state.dart';
import 'package:patres/l10n/generated/app_localizations.dart';
import 'package:patres/models/text_content.dart';
import 'package:patres/models/app_theme_mode.dart';
import 'package:patres/theme.dart';
import 'package:patres/widgets/chapter_list_sheet.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class _MockReaderBloc extends MockBloc<ReaderEvent, ReaderState>
    implements ReaderBloc {}

// ---------------------------------------------------------------------------
// Test data
// ---------------------------------------------------------------------------

const _testChapters = [
  Chapter(title: 'Rozdział I — Dwie drogi', content: 'Treść pierwsza.'),
  Chapter(title: 'Rozdział II — Przykazania', content: 'Treść druga.'),
  Chapter(title: 'Rozdział III — Unikanie zła', content: 'Treść trzecia.'),
];

// ---------------------------------------------------------------------------
// Test wrapper
// ---------------------------------------------------------------------------

Widget _testApp(
  Widget child, {
  required ReaderBloc readerBloc,
}) {
  return BlocProvider<ReaderBloc>.value(
    value: readerBloc,
    child: MaterialApp(
      theme: PatresTheme.themeFor(AppThemeMode.light),
      locale: const Locale('pl'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Scaffold(
        body: SizedBox(
          height: 600,
          child: child,
        ),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUpAll(() {
    registerFallbackValue(const ReaderChapterChanged(chapterIndex: 0));
    registerFallbackValue(const ReaderState());
  });

  group('ChapterListSheet', () {
    late _MockReaderBloc readerBloc;

    setUp(() {
      readerBloc = _MockReaderBloc();
      when(() => readerBloc.state).thenReturn(const ReaderState());
    });

    tearDown(() {
      readerBloc.close();
    });

    testWidgets('renders all chapter titles', (tester) async {
      await tester.pumpWidget(_testApp(
        const ChapterListSheet(
          chapters: _testChapters,
          currentChapter: 0,
          bookmarkedChapters: {},
        ),
        readerBloc: readerBloc,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Rozdział I — Dwie drogi'), findsOneWidget);
      expect(find.text('Rozdział II — Przykazania'), findsOneWidget);
      expect(find.text('Rozdział III — Unikanie zła'), findsOneWidget);
    });

    testWidgets('shows chapter numbers', (tester) async {
      await tester.pumpWidget(_testApp(
        const ChapterListSheet(
          chapters: _testChapters,
          currentChapter: 0,
          bookmarkedChapters: {},
        ),
        readerBloc: readerBloc,
      ));
      await tester.pumpAndSettle();

      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('shows chapter count header', (tester) async {
      await tester.pumpWidget(_testApp(
        const ChapterListSheet(
          chapters: _testChapters,
          currentChapter: 1,
          bookmarkedChapters: {},
        ),
        readerBloc: readerBloc,
      ));
      await tester.pumpAndSettle();

      // Polish l10n: "Rozdziały" header
      expect(find.textContaining('Rozdzia'), findsWidgets);
      // Chapter counter: "2 z 3"
      expect(find.textContaining('2 z 3'), findsOneWidget);
    });

    testWidgets('shows bookmark icon for bookmarked chapters',
        (tester) async {
      await tester.pumpWidget(_testApp(
        const ChapterListSheet(
          chapters: _testChapters,
          currentChapter: 0,
          bookmarkedChapters: {1},
        ),
        readerBloc: readerBloc,
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.bookmark_rounded), findsOneWidget);
    });

    testWidgets('does not show bookmark icon for non-bookmarked chapters',
        (tester) async {
      await tester.pumpWidget(_testApp(
        const ChapterListSheet(
          chapters: _testChapters,
          currentChapter: 0,
          bookmarkedChapters: {},
        ),
        readerBloc: readerBloc,
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.bookmark_rounded), findsNothing);
    });

    testWidgets('tapping chapter dispatches ReaderChapterChanged',
        (tester) async {
      await tester.pumpWidget(_testApp(
        const ChapterListSheet(
          chapters: _testChapters,
          currentChapter: 0,
          bookmarkedChapters: {},
        ),
        readerBloc: readerBloc,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Rozdział II — Przykazania'));
      await tester.pumpAndSettle();

      verify(
        () => readerBloc.add(const ReaderChapterChanged(chapterIndex: 1)),
      ).called(1);
    });

    testWidgets('renders with multiple bookmarked chapters', (tester) async {
      await tester.pumpWidget(_testApp(
        const ChapterListSheet(
          chapters: _testChapters,
          currentChapter: 0,
          bookmarkedChapters: {0, 2},
        ),
        readerBloc: readerBloc,
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.bookmark_rounded), findsNWidgets(2));
    });
  });
}
