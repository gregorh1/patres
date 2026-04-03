import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'locale_event.dart';
part 'locale_state.dart';

class LocaleBloc extends Bloc<LocaleEvent, LocaleState> {
  LocaleBloc() : super(const LocaleState()) {
    on<LocaleChanged>(_onLocaleChanged);
    on<LocaleLoadRequested>(_onLoadRequested);
  }

  static const _key = 'app_locale';

  Future<void> _onLoadRequested(
    LocaleLoadRequested event,
    Emitter<LocaleState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key);
    if (code != null) {
      emit(LocaleState(locale: Locale(code)));
    }
  }

  Future<void> _onLocaleChanged(
    LocaleChanged event,
    Emitter<LocaleState> emit,
  ) async {
    emit(LocaleState(locale: event.locale));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, event.locale.languageCode);
  }
}
