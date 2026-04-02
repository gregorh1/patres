import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patres/blocs/theme_bloc.dart';
import 'package:patres/l10n/generated/app_localizations.dart';
import 'package:patres/main.dart';
import 'package:patres/models/app_theme_mode.dart';
import 'package:patres/screens/settings_screen.dart';
import 'package:patres/theme.dart';

/// Wraps a widget with all providers and localizations needed for testing.
Widget testApp(Widget child, {ThemeBloc? themeBloc}) {
  final bloc = themeBloc ?? ThemeBloc();
  return BlocProvider<ThemeBloc>.value(
    value: bloc,
    child: BlocBuilder<ThemeBloc, ThemeState>(
      bloc: bloc,
      builder: (context, state) {
        return MaterialApp(
          theme: PatresTheme.themeFor(state.themeMode),
          locale: const Locale('pl'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: child,
        );
      },
    ),
  );
}

void main() {
  group('PatresApp', () {
    testWidgets('renders and shows home screen', (tester) async {
      await tester.pumpWidget(const PatresApp());
      await tester.pumpAndSettle();

      // Home screen greeting should be visible
      expect(find.text('Witaj w Patres'), findsOneWidget);
    });

    testWidgets('bottom navigation has three tabs', (tester) async {
      await tester.pumpWidget(const PatresApp());
      await tester.pumpAndSettle();

      expect(find.text('Główna'), findsOneWidget);
      expect(find.text('Biblioteka'), findsOneWidget);
      expect(find.text('Ustawienia'), findsOneWidget);
    });

    testWidgets('navigates to Library tab', (tester) async {
      await tester.pumpWidget(const PatresApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Biblioteka'));
      await tester.pumpAndSettle();

      expect(find.text('Ojcowie Kościoła'), findsOneWidget);
    });

    testWidgets('navigates to Settings tab', (tester) async {
      await tester.pumpWidget(const PatresApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Ustawienia'));
      await tester.pumpAndSettle();

      expect(find.text('Motyw'), findsOneWidget);
    });

    testWidgets('navigates back to Home from Settings', (tester) async {
      await tester.pumpWidget(const PatresApp());
      await tester.pumpAndSettle();

      // Navigate to Settings
      await tester.tap(find.text('Ustawienia').last);
      await tester.pumpAndSettle();

      // Navigate back to Home
      await tester.tap(find.text('Główna').last);
      await tester.pumpAndSettle();

      expect(find.text('Witaj w Patres'), findsOneWidget);
    });
  });

  group('Theme switching', () {
    testWidgets('Settings shows three theme options', (tester) async {
      await tester.pumpWidget(testApp(const SettingsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Jasny'), findsOneWidget);
      expect(find.text('Ciemny'), findsOneWidget);
      expect(find.text('Sepia'), findsOneWidget);
    });

    testWidgets('tapping Dark theme dispatches ThemeChanged event',
        (tester) async {
      final bloc = ThemeBloc();
      await tester.pumpWidget(testApp(const SettingsScreen(), themeBloc: bloc));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Ciemny'));
      await tester.pumpAndSettle();

      expect(bloc.state.themeMode, AppThemeMode.dark);
      bloc.close();
    });

    testWidgets('tapping Sepia theme dispatches ThemeChanged event',
        (tester) async {
      final bloc = ThemeBloc();
      await tester.pumpWidget(testApp(const SettingsScreen(), themeBloc: bloc));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sepia'));
      await tester.pumpAndSettle();

      expect(bloc.state.themeMode, AppThemeMode.sepia);
      bloc.close();
    });

    testWidgets('tapping Light theme after Dark restores light',
        (tester) async {
      final bloc = ThemeBloc();
      bloc.add(const ThemeChanged(AppThemeMode.dark));

      await tester.pumpWidget(testApp(const SettingsScreen(), themeBloc: bloc));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Jasny'));
      await tester.pumpAndSettle();

      expect(bloc.state.themeMode, AppThemeMode.light);
      bloc.close();
    });
  });

  group('ThemeBloc', () {
    test('initial state is light theme', () {
      final bloc = ThemeBloc();
      expect(bloc.state.themeMode, AppThemeMode.light);
      bloc.close();
    });

    test('emits dark theme state when ThemeChanged(dark) is added', () async {
      final bloc = ThemeBloc();
      bloc.add(const ThemeChanged(AppThemeMode.dark));
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.themeMode, AppThemeMode.dark);
      bloc.close();
    });

    test('emits sepia theme state when ThemeChanged(sepia) is added',
        () async {
      final bloc = ThemeBloc();
      bloc.add(const ThemeChanged(AppThemeMode.sepia));
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.themeMode, AppThemeMode.sepia);
      bloc.close();
    });
  });

  group('PatresTheme', () {
    test('light theme uses Material 3', () {
      final theme = PatresTheme.themeFor(AppThemeMode.light);
      expect(theme.useMaterial3, isTrue);
      expect(theme.brightness, Brightness.light);
    });

    test('dark theme uses Material 3 with dark brightness', () {
      final theme = PatresTheme.themeFor(AppThemeMode.dark);
      expect(theme.useMaterial3, isTrue);
      expect(theme.brightness, Brightness.dark);
    });

    test('sepia theme has warm parchment colors', () {
      final theme = PatresTheme.themeFor(AppThemeMode.sepia);
      expect(theme.useMaterial3, isTrue);
      // Sepia scaffold background should be the parchment color
      expect(theme.scaffoldBackgroundColor, const Color(0xFFF5ECD7));
    });

    test('all three themes produce distinct ThemeData instances', () {
      final light = PatresTheme.themeFor(AppThemeMode.light);
      final dark = PatresTheme.themeFor(AppThemeMode.dark);
      final sepia = PatresTheme.themeFor(AppThemeMode.sepia);

      expect(light.brightness, isNot(dark.brightness));
      expect(sepia.scaffoldBackgroundColor,
          isNot(equals(light.scaffoldBackgroundColor)));
    });
  });
}
