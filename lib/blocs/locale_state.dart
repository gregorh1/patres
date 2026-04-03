part of 'locale_bloc.dart';

class LocaleState extends Equatable {
  const LocaleState({this.locale = const Locale('pl')});
  final Locale locale;

  @override
  List<Object?> get props => [locale];
}
