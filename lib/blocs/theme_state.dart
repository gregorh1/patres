part of 'theme_bloc.dart';

class ThemeState extends Equatable {
  const ThemeState({this.themeMode = AppThemeMode.light});
  final AppThemeMode themeMode;

  @override
  List<Object?> get props => [themeMode];
}
