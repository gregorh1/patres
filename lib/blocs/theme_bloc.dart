import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:patres/models/app_theme_mode.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_event.dart';
part 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(const ThemeState()) {
    on<ThemeChanged>(_onThemeChanged);
    on<ThemeLoadRequested>(_onLoadRequested);
  }

  static const _key = 'app_theme';

  Future<void> _onLoadRequested(
    ThemeLoadRequested event,
    Emitter<ThemeState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_key);
    if (name != null) {
      final mode = AppThemeMode.values.where((m) => m.name == name).firstOrNull;
      if (mode != null) {
        emit(ThemeState(themeMode: mode));
      }
    }
  }

  Future<void> _onThemeChanged(
    ThemeChanged event,
    Emitter<ThemeState> emit,
  ) async {
    emit(ThemeState(themeMode: event.themeMode));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, event.themeMode.name);
  }
}
