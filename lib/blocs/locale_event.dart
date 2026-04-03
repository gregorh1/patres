part of 'locale_bloc.dart';

abstract class LocaleEvent extends Equatable {
  const LocaleEvent();

  @override
  List<Object?> get props => [];
}

class LocaleChanged extends LocaleEvent {
  const LocaleChanged(this.locale);
  final Locale locale;

  @override
  List<Object?> get props => [locale];
}

class LocaleLoadRequested extends LocaleEvent {
  const LocaleLoadRequested();
}
