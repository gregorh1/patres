import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patres/blocs/theme_bloc.dart';
import 'package:patres/models/app_theme_mode.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ThemeBloc', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('initial state defaults to system theme', () {
      final bloc = ThemeBloc();
      expect(bloc.state.themeMode, AppThemeMode.system);
      bloc.close();
    });

    blocTest<ThemeBloc, ThemeState>(
      'emits dark theme when ThemeChanged(dark) is added',
      build: ThemeBloc.new,
      act: (bloc) => bloc.add(const ThemeChanged(AppThemeMode.dark)),
      expect: () => [const ThemeState(themeMode: AppThemeMode.dark)],
    );

    blocTest<ThemeBloc, ThemeState>(
      'emits light theme when ThemeChanged(light) is added',
      build: ThemeBloc.new,
      act: (bloc) => bloc.add(const ThemeChanged(AppThemeMode.light)),
      expect: () => [const ThemeState(themeMode: AppThemeMode.light)],
    );

    blocTest<ThemeBloc, ThemeState>(
      'emits sepia theme when ThemeChanged(sepia) is added',
      build: ThemeBloc.new,
      act: (bloc) => bloc.add(const ThemeChanged(AppThemeMode.sepia)),
      expect: () => [const ThemeState(themeMode: AppThemeMode.sepia)],
    );

    blocTest<ThemeBloc, ThemeState>(
      'emits system theme when ThemeChanged(system) is added',
      build: ThemeBloc.new,
      act: (bloc) => bloc.add(const ThemeChanged(AppThemeMode.system)),
      expect: () => [const ThemeState(themeMode: AppThemeMode.system)],
    );

    blocTest<ThemeBloc, ThemeState>(
      'persists theme to SharedPreferences',
      setUp: () => SharedPreferences.setMockInitialValues({}),
      build: ThemeBloc.new,
      act: (bloc) => bloc.add(const ThemeChanged(AppThemeMode.dark)),
      verify: (_) async {
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString('app_theme'), 'dark');
      },
    );

    blocTest<ThemeBloc, ThemeState>(
      'loads saved theme from SharedPreferences',
      setUp: () =>
          SharedPreferences.setMockInitialValues({'app_theme': 'dark'}),
      build: ThemeBloc.new,
      act: (bloc) => bloc.add(const ThemeLoadRequested()),
      expect: () => [const ThemeState(themeMode: AppThemeMode.dark)],
    );

    blocTest<ThemeBloc, ThemeState>(
      'loads system theme from SharedPreferences',
      setUp: () =>
          SharedPreferences.setMockInitialValues({'app_theme': 'system'}),
      build: ThemeBloc.new,
      act: (bloc) => bloc.add(const ThemeLoadRequested()),
      expect: () => [const ThemeState(themeMode: AppThemeMode.system)],
    );

    blocTest<ThemeBloc, ThemeState>(
      'emits nothing when no saved theme exists',
      setUp: () => SharedPreferences.setMockInitialValues({}),
      build: ThemeBloc.new,
      act: (bloc) => bloc.add(const ThemeLoadRequested()),
      expect: () => <ThemeState>[],
    );

    blocTest<ThemeBloc, ThemeState>(
      'ignores invalid saved theme value',
      setUp: () =>
          SharedPreferences.setMockInitialValues({'app_theme': 'invalid'}),
      build: ThemeBloc.new,
      act: (bloc) => bloc.add(const ThemeLoadRequested()),
      expect: () => <ThemeState>[],
    );

    blocTest<ThemeBloc, ThemeState>(
      'switching theme multiple times emits all states',
      build: ThemeBloc.new,
      act: (bloc) {
        bloc
          ..add(const ThemeChanged(AppThemeMode.dark))
          ..add(const ThemeChanged(AppThemeMode.sepia))
          ..add(const ThemeChanged(AppThemeMode.system));
      },
      expect: () => [
        const ThemeState(themeMode: AppThemeMode.dark),
        const ThemeState(themeMode: AppThemeMode.sepia),
        const ThemeState(themeMode: AppThemeMode.system),
      ],
    );
  });

  group('ThemeState', () {
    test('supports value equality', () {
      expect(
        const ThemeState(themeMode: AppThemeMode.dark),
        const ThemeState(themeMode: AppThemeMode.dark),
      );
    });

    test('different modes are not equal', () {
      expect(
        const ThemeState(themeMode: AppThemeMode.dark),
        isNot(const ThemeState(themeMode: AppThemeMode.light)),
      );
    });
  });

  group('ThemeEvent', () {
    test('ThemeChanged supports value equality', () {
      expect(
        const ThemeChanged(AppThemeMode.dark),
        const ThemeChanged(AppThemeMode.dark),
      );
    });

    test('ThemeLoadRequested supports value equality', () {
      expect(
        const ThemeLoadRequested(),
        const ThemeLoadRequested(),
      );
    });
  });
}
