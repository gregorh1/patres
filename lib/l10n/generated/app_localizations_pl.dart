// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get appTitle => 'Patres';

  @override
  String get homeTab => 'Główna';

  @override
  String get libraryTab => 'Biblioteka';

  @override
  String get settingsTab => 'Ustawienia';

  @override
  String get homeGreeting => 'Witaj w Patres';

  @override
  String get homeSubtitle => 'Odkryj mądrość Ojców Kościoła';

  @override
  String get continueReading => 'Kontynuuj czytanie';

  @override
  String get recommended => 'Polecane';

  @override
  String get libraryTitle => 'Biblioteka';

  @override
  String get libraryEmpty => 'Twoja biblioteka jest pusta';

  @override
  String get libraryEmptyHint => 'Dodaj teksty z katalogu, aby rozpocząć';

  @override
  String get searchHint => 'Szukaj autorów, tytułów…';

  @override
  String get settingsTitle => 'Ustawienia';

  @override
  String get themeMode => 'Motyw';

  @override
  String get themeLight => 'Jasny';

  @override
  String get themeDark => 'Ciemny';

  @override
  String get themeSepia => 'Sepia';

  @override
  String get language => 'Język';

  @override
  String get readerTitle => 'Czytelnik';

  @override
  String get readerPlaceholder => 'Tutaj pojawi się tekst do czytania.';

  @override
  String get churchFathers => 'Ojcowie Kościoła';

  @override
  String get christianClassics => 'Klasycy chrześcijańscy';

  @override
  String get aboutApp => 'O aplikacji';

  @override
  String get aboutDescription =>
      'Patres — piękny czytnik tekstów patrystycznych i klasyki chrześcijańskiej, z planowaną obsługą audiobooków TTS.';

  @override
  String get version => 'Wersja';

  @override
  String get filterAll => 'Wszystkie';

  @override
  String get filterCategory => 'Kategoria';

  @override
  String get filterEra => 'Epoka';

  @override
  String get sortByTitle => 'Tytuł';

  @override
  String get sortByAuthor => 'Autor';

  @override
  String get sortByEra => 'Epoka';

  @override
  String get sortBy => 'Sortuj';

  @override
  String get categoryPatrystyka => 'Patrystyka';

  @override
  String get categoryDuchowosc => 'Duchowość';

  @override
  String get categoryMonastycyzm => 'Monastycyzm';

  @override
  String get categoryHymnografia => 'Hymnografia';

  @override
  String get categoryKaznodziejstwo => 'Kaznodziejstwo';

  @override
  String chaptersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'rozdziałów',
      few: 'rozdziały',
      one: 'rozdział',
    );
    return '$count $_temp0';
  }

  @override
  String get noResults => 'Brak wyników';

  @override
  String get noResultsHint => 'Spróbuj zmienić filtry lub wyszukiwanie';

  @override
  String get statusComplete => 'Pełny tekst';

  @override
  String get statusPartial => 'Częściowy';

  @override
  String get statusPlaceholder => 'Wkrótce';

  @override
  String get readerSettings => 'Ustawienia czytnika';

  @override
  String get fontSize => 'Rozmiar czcionki';

  @override
  String get fontFamily => 'Czcionka';

  @override
  String get chapters => 'Rozdziały';

  @override
  String chapterOf(int current, int total) {
    return 'Rozdział $current z $total';
  }

  @override
  String get addBookmark => 'Dodaj zakładkę';

  @override
  String get removeBookmark => 'Usuń zakładkę';

  @override
  String get bookmarkAdded => 'Zakładka dodana';

  @override
  String get bookmarkRemoved => 'Zakładka usunięta';

  @override
  String get bookmarkNoteHint => 'Dodaj notatkę (opcjonalnie)';

  @override
  String get previousChapter => 'Poprzedni rozdział';

  @override
  String get nextChapter => 'Następny rozdział';

  @override
  String get cancel => 'Anuluj';

  @override
  String get save => 'Zapisz';

  @override
  String get dailyReading => 'Czytanie na dziś';

  @override
  String get shareDailyReading => 'Udostępnij cytat';

  @override
  String dailyReadingShared(String author) {
    return '— $author, via Patres';
  }

  @override
  String get authorProfile => 'Profil autora';

  @override
  String get authorBio => 'Biografia';

  @override
  String get authorSignificance => 'Znaczenie';

  @override
  String get authorWorks => 'Dzieła w aplikacji';

  @override
  String get authorDates => 'Daty';

  @override
  String get authorEra => 'Epoka';

  @override
  String get authorOriginalName => 'Imię oryginalne';

  @override
  String get authorUnknown => 'Nieznany autor';
}
