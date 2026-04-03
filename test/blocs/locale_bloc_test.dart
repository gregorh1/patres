import 'dart:ui';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patres/blocs/locale_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('LocaleBloc', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('initial state defaults to Polish locale', () {
      final bloc = LocaleBloc();
      expect(bloc.state.locale, const Locale('pl'));
      bloc.close();
    });

    blocTest<LocaleBloc, LocaleState>(
      'emits English locale when LocaleChanged(en) is added',
      build: LocaleBloc.new,
      act: (bloc) => bloc.add(const LocaleChanged(Locale('en'))),
      expect: () => [const LocaleState(locale: Locale('en'))],
    );

    blocTest<LocaleBloc, LocaleState>(
      'emits Polish locale when LocaleChanged(pl) is added',
      build: LocaleBloc.new,
      act: (bloc) => bloc.add(const LocaleChanged(Locale('pl'))),
      expect: () => [const LocaleState(locale: Locale('pl'))],
    );

    blocTest<LocaleBloc, LocaleState>(
      'persists locale to SharedPreferences',
      setUp: () => SharedPreferences.setMockInitialValues({}),
      build: LocaleBloc.new,
      act: (bloc) => bloc.add(const LocaleChanged(Locale('en'))),
      verify: (_) async {
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString('app_locale'), 'en');
      },
    );

    blocTest<LocaleBloc, LocaleState>(
      'loads saved locale from SharedPreferences',
      setUp: () =>
          SharedPreferences.setMockInitialValues({'app_locale': 'en'}),
      build: LocaleBloc.new,
      act: (bloc) => bloc.add(const LocaleLoadRequested()),
      expect: () => [const LocaleState(locale: Locale('en'))],
    );

    blocTest<LocaleBloc, LocaleState>(
      'emits nothing when no saved locale exists',
      setUp: () => SharedPreferences.setMockInitialValues({}),
      build: LocaleBloc.new,
      act: (bloc) => bloc.add(const LocaleLoadRequested()),
      expect: () => <LocaleState>[],
    );

    blocTest<LocaleBloc, LocaleState>(
      'switching locale multiple times emits all states',
      build: LocaleBloc.new,
      act: (bloc) {
        bloc
          ..add(const LocaleChanged(Locale('en')))
          ..add(const LocaleChanged(Locale('pl')))
          ..add(const LocaleChanged(Locale('en')));
      },
      expect: () => [
        const LocaleState(locale: Locale('en')),
        const LocaleState(locale: Locale('pl')),
        const LocaleState(locale: Locale('en')),
      ],
    );
  });

  group('LocaleState', () {
    test('supports value equality', () {
      expect(
        const LocaleState(locale: Locale('en')),
        const LocaleState(locale: Locale('en')),
      );
    });

    test('different locales are not equal', () {
      expect(
        const LocaleState(locale: Locale('en')),
        isNot(const LocaleState(locale: Locale('pl'))),
      );
    });
  });

  group('LocaleEvent', () {
    test('LocaleChanged supports value equality', () {
      expect(
        const LocaleChanged(Locale('en')),
        const LocaleChanged(Locale('en')),
      );
    });

    test('LocaleLoadRequested supports value equality', () {
      expect(
        const LocaleLoadRequested(),
        const LocaleLoadRequested(),
      );
    });
  });
}
