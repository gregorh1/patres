part of 'theme_bloc.dart';

abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object?> get props => [];
}

class ThemeChanged extends ThemeEvent {
  const ThemeChanged(this.themeMode);
  final AppThemeMode themeMode;

  @override
  List<Object?> get props => [themeMode];
}

class ThemeLoadRequested extends ThemeEvent {
  const ThemeLoadRequested();
}
