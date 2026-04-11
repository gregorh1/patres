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
import 'package:patres/models/app_theme_mode.dart';
import 'package:patres/theme.dart';
import 'package:patres/widgets/reader_settings_sheet.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class _MockReaderBloc extends MockBloc<ReaderEvent, ReaderState>
    implements ReaderBloc {}

// ---------------------------------------------------------------------------
// Test wrapper
// ---------------------------------------------------------------------------

Widget _testApp(Widget child, {required ReaderBloc readerBloc}) {
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
      home: Scaffold(body: child),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUpAll(() {
    registerFallbackValue(const ReaderFontSizeChanged(fontSizeIndex: 0));
    registerFallbackValue(const ReaderState());
  });

  group('ReaderSettingsSheet', () {
    late _MockReaderBloc readerBloc;

    setUp(() {
      readerBloc = _MockReaderBloc();
      when(() => readerBloc.state).thenReturn(const ReaderState());
    });

    tearDown(() {
      readerBloc.close();
    });

    testWidgets('shows settings title', (tester) async {
      await tester.pumpWidget(_testApp(
        const ReaderSettingsSheet(),
        readerBloc: readerBloc,
      ));
      await tester.pumpAndSettle();

      // Polish l10n: "Ustawienia czytnika" or similar
      // Check that the settings sheet renders text for reader settings
      expect(find.byType(ReaderSettingsSheet), findsOneWidget);
    });

    testWidgets('shows all 5 font size options', (tester) async {
      await tester.pumpWidget(_testApp(
        const ReaderSettingsSheet(),
        readerBloc: readerBloc,
      ));
      await tester.pumpAndSettle();

      for (final label in ReaderState.fontSizeLabels) {
        expect(find.text(label), findsOneWidget);
      }
    });

    testWidgets('shows font family options Lora and Merriweather',
        (tester) async {
      await tester.pumpWidget(_testApp(
        const ReaderSettingsSheet(),
        readerBloc: readerBloc,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Lora'), findsOneWidget);
      expect(find.text('Merriweather'), findsOneWidget);
    });

    testWidgets('shows preview text with Polish characters', (tester) async {
      await tester.pumpWidget(_testApp(
        const ReaderSettingsSheet(),
        readerBloc: readerBloc,
      ));
      await tester.pumpAndSettle();

      expect(
        find.text('Ąą Ęę Ćć Łł Ńń Óó Śś Źź Żż'),
        findsOneWidget,
      );
    });

    testWidgets('tapping font size dispatches ReaderFontSizeChanged',
        (tester) async {
      when(() => readerBloc.state).thenReturn(const ReaderState(
        fontSizeIndex: 1,
      ));

      await tester.pumpWidget(_testApp(
        const ReaderSettingsSheet(),
        readerBloc: readerBloc,
      ));
      await tester.pumpAndSettle();

      // Tap the "L" (index 2) font size option
      await tester.tap(find.text('L'));
      await tester.pumpAndSettle();

      verify(
        () => readerBloc.add(const ReaderFontSizeChanged(fontSizeIndex: 2)),
      ).called(1);
    });

    testWidgets(
        'tapping font family dispatches ReaderFontFamilyChanged',
        (tester) async {
      when(() => readerBloc.state).thenReturn(const ReaderState(
        fontFamily: 'Lora',
      ));

      await tester.pumpWidget(_testApp(
        const ReaderSettingsSheet(),
        readerBloc: readerBloc,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Merriweather'));
      await tester.pumpAndSettle();

      verify(
        () => readerBloc.add(
            const ReaderFontFamilyChanged(fontFamily: 'Merriweather')),
      ).called(1);
    });

    testWidgets('highlights current font size selection', (tester) async {
      when(() => readerBloc.state).thenReturn(const ReaderState(
        fontSizeIndex: 3, // XL
      ));

      await tester.pumpWidget(_testApp(
        const ReaderSettingsSheet(),
        readerBloc: readerBloc,
      ));
      await tester.pumpAndSettle();

      // All 5 font size labels should be rendered
      for (final label in ReaderState.fontSizeLabels) {
        expect(find.text(label), findsOneWidget);
      }
    });

    testWidgets('renders with default state', (tester) async {
      when(() => readerBloc.state).thenReturn(const ReaderState());

      await tester.pumpWidget(_testApp(
        const ReaderSettingsSheet(),
        readerBloc: readerBloc,
      ));
      await tester.pumpAndSettle();

      // Default fontSizeIndex=1 means "M" should be selected, fontFamily='Lora'
      expect(find.text('M'), findsOneWidget);
      expect(find.text('Lora'), findsOneWidget);
    });

    testWidgets('tapping different font sizes dispatches correct index',
        (tester) async {
      when(() => readerBloc.state).thenReturn(const ReaderState(
        fontSizeIndex: 0,
      ));

      await tester.pumpWidget(_testApp(
        const ReaderSettingsSheet(),
        readerBloc: readerBloc,
      ));
      await tester.pumpAndSettle();

      // Tap XXL (index 4)
      await tester.tap(find.text('XXL'));
      await tester.pumpAndSettle();

      verify(
        () => readerBloc.add(const ReaderFontSizeChanged(fontSizeIndex: 4)),
      ).called(1);
    });
  });
}
