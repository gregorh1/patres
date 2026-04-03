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
  String get languageEnglish => 'English';

  @override
  String get languagePolish => 'Polski';

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

  @override
  String get searchFullText => 'Szukaj w tekstach';

  @override
  String get searchFullTextHint => 'Szukaj słów i fraz w tekstach…';

  @override
  String get searchIndexing => 'Indeksowanie tekstów…';

  @override
  String get searchPrompt =>
      'Wpisz co najmniej 2 znaki, aby wyszukać w całej bibliotece';

  @override
  String get searchError => 'Błąd wyszukiwania';

  @override
  String searchResultsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'wyników',
      few: 'wyniki',
      one: 'wynik',
    );
    return '$count $_temp0';
  }

  @override
  String get plansTab => 'Plany';

  @override
  String get plansTitle => 'Plany czytania';

  @override
  String get plansError => 'Nie udało się załadować planów';

  @override
  String planDaysCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'dni',
      few: 'dni',
      one: 'dzień',
    );
    return '$count $_temp0';
  }

  @override
  String get planStart => 'Rozpocznij plan';

  @override
  String get planCompleted => 'ukończono';

  @override
  String get planStreak => 'seria';

  @override
  String get planLongestStreak => 'rekord';

  @override
  String get planMarkComplete => 'Oznacz jako ukończone';

  @override
  String get planMarkIncomplete => 'Cofnij ukończenie';

  @override
  String streakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'dni',
      few: 'dni',
      one: 'dzień',
    );
    return '$count $_temp0 z rzędu';
  }

  @override
  String get planInProgress => 'W trakcie';

  @override
  String get planCompletedStatus => 'Ukończony';

  @override
  String get planStartPrompt => 'Rozpocznij plan, aby śledzić postępy';

  @override
  String get audioListen => 'Słuchaj';

  @override
  String get audioDownloads => 'Audiobooki';

  @override
  String get audioDownloadsDescription => 'Zarządzaj pobranymi audiobookami';

  @override
  String get audioDownload => 'Pobierz audio';

  @override
  String get audioDeleteDownload => 'Usuń audio';

  @override
  String get audioDeleteConfirm => 'Czy na pewno chcesz usunąć pobrane audio?';

  @override
  String get audioDelete => 'Usuń';

  @override
  String get audioStorageUsed => 'Zajęte miejsce';

  @override
  String get audioGenerating => 'Generowanie audio…';

  @override
  String get audioGeneratingChapter => 'Generowanie audio rozdziału…';

  @override
  String get audioGenerationError => 'Błąd generowania audio';

  @override
  String audioChapterProgress(int completed, int total) {
    return 'Rozdział $completed z $total';
  }

  @override
  String get audioSpeed => 'Prędkość odtwarzania';

  @override
  String get audioSleepTimer => 'Wyłącznik czasowy';

  @override
  String get audioSleepTimerActive => 'Wyłącznik aktywny';

  @override
  String get audioSleepTimerCancel => 'Anuluj wyłącznik';

  @override
  String get audioSleepTimer15 => '15 minut';

  @override
  String get audioSleepTimer30 => '30 minut';

  @override
  String get audioSleepTimer45 => '45 minut';

  @override
  String get audioSleepTimer60 => '1 godzina';

  @override
  String get audioSkipForward => 'Przewiń do przodu';

  @override
  String get audioSkipBackward => 'Przewiń do tyłu';
}
