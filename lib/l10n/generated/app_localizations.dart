import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pl.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pl'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In pl, this message translates to:
  /// **'Patres'**
  String get appTitle;

  /// No description provided for @homeTab.
  ///
  /// In pl, this message translates to:
  /// **'Główna'**
  String get homeTab;

  /// No description provided for @libraryTab.
  ///
  /// In pl, this message translates to:
  /// **'Biblioteka'**
  String get libraryTab;

  /// No description provided for @settingsTab.
  ///
  /// In pl, this message translates to:
  /// **'Ustawienia'**
  String get settingsTab;

  /// No description provided for @homeGreeting.
  ///
  /// In pl, this message translates to:
  /// **'Witaj w Patres'**
  String get homeGreeting;

  /// No description provided for @homeSubtitle.
  ///
  /// In pl, this message translates to:
  /// **'Odkryj mądrość Ojców Kościoła'**
  String get homeSubtitle;

  /// No description provided for @continueReading.
  ///
  /// In pl, this message translates to:
  /// **'Kontynuuj czytanie'**
  String get continueReading;

  /// No description provided for @recommended.
  ///
  /// In pl, this message translates to:
  /// **'Polecane'**
  String get recommended;

  /// No description provided for @libraryTitle.
  ///
  /// In pl, this message translates to:
  /// **'Biblioteka'**
  String get libraryTitle;

  /// No description provided for @libraryEmpty.
  ///
  /// In pl, this message translates to:
  /// **'Twoja biblioteka jest pusta'**
  String get libraryEmpty;

  /// No description provided for @libraryEmptyHint.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj teksty z katalogu, aby rozpocząć'**
  String get libraryEmptyHint;

  /// No description provided for @searchHint.
  ///
  /// In pl, this message translates to:
  /// **'Szukaj autorów, tytułów…'**
  String get searchHint;

  /// No description provided for @settingsTitle.
  ///
  /// In pl, this message translates to:
  /// **'Ustawienia'**
  String get settingsTitle;

  /// No description provided for @themeMode.
  ///
  /// In pl, this message translates to:
  /// **'Motyw'**
  String get themeMode;

  /// No description provided for @themeLight.
  ///
  /// In pl, this message translates to:
  /// **'Jasny'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In pl, this message translates to:
  /// **'Ciemny'**
  String get themeDark;

  /// No description provided for @themeSepia.
  ///
  /// In pl, this message translates to:
  /// **'Sepia'**
  String get themeSepia;

  /// No description provided for @language.
  ///
  /// In pl, this message translates to:
  /// **'Język'**
  String get language;

  /// No description provided for @readerTitle.
  ///
  /// In pl, this message translates to:
  /// **'Czytelnik'**
  String get readerTitle;

  /// No description provided for @readerPlaceholder.
  ///
  /// In pl, this message translates to:
  /// **'Tutaj pojawi się tekst do czytania.'**
  String get readerPlaceholder;

  /// No description provided for @churchFathers.
  ///
  /// In pl, this message translates to:
  /// **'Ojcowie Kościoła'**
  String get churchFathers;

  /// No description provided for @christianClassics.
  ///
  /// In pl, this message translates to:
  /// **'Klasycy chrześcijańscy'**
  String get christianClassics;

  /// No description provided for @aboutApp.
  ///
  /// In pl, this message translates to:
  /// **'O aplikacji'**
  String get aboutApp;

  /// No description provided for @aboutDescription.
  ///
  /// In pl, this message translates to:
  /// **'Patres — piękny czytnik tekstów patrystycznych i klasyki chrześcijańskiej, z planowaną obsługą audiobooków TTS.'**
  String get aboutDescription;

  /// No description provided for @version.
  ///
  /// In pl, this message translates to:
  /// **'Wersja'**
  String get version;

  /// No description provided for @filterAll.
  ///
  /// In pl, this message translates to:
  /// **'Wszystkie'**
  String get filterAll;

  /// No description provided for @filterCategory.
  ///
  /// In pl, this message translates to:
  /// **'Kategoria'**
  String get filterCategory;

  /// No description provided for @filterEra.
  ///
  /// In pl, this message translates to:
  /// **'Epoka'**
  String get filterEra;

  /// No description provided for @sortByTitle.
  ///
  /// In pl, this message translates to:
  /// **'Tytuł'**
  String get sortByTitle;

  /// No description provided for @sortByAuthor.
  ///
  /// In pl, this message translates to:
  /// **'Autor'**
  String get sortByAuthor;

  /// No description provided for @sortByEra.
  ///
  /// In pl, this message translates to:
  /// **'Epoka'**
  String get sortByEra;

  /// No description provided for @sortBy.
  ///
  /// In pl, this message translates to:
  /// **'Sortuj'**
  String get sortBy;

  /// No description provided for @categoryPatrystyka.
  ///
  /// In pl, this message translates to:
  /// **'Patrystyka'**
  String get categoryPatrystyka;

  /// No description provided for @categoryDuchowosc.
  ///
  /// In pl, this message translates to:
  /// **'Duchowość'**
  String get categoryDuchowosc;

  /// No description provided for @categoryMonastycyzm.
  ///
  /// In pl, this message translates to:
  /// **'Monastycyzm'**
  String get categoryMonastycyzm;

  /// No description provided for @categoryHymnografia.
  ///
  /// In pl, this message translates to:
  /// **'Hymnografia'**
  String get categoryHymnografia;

  /// No description provided for @categoryKaznodziejstwo.
  ///
  /// In pl, this message translates to:
  /// **'Kaznodziejstwo'**
  String get categoryKaznodziejstwo;

  /// No description provided for @chaptersCount.
  ///
  /// In pl, this message translates to:
  /// **'{count} {count, plural, one{rozdział} few{rozdziały} other{rozdziałów}}'**
  String chaptersCount(int count);

  /// No description provided for @noResults.
  ///
  /// In pl, this message translates to:
  /// **'Brak wyników'**
  String get noResults;

  /// No description provided for @noResultsHint.
  ///
  /// In pl, this message translates to:
  /// **'Spróbuj zmienić filtry lub wyszukiwanie'**
  String get noResultsHint;

  /// No description provided for @statusComplete.
  ///
  /// In pl, this message translates to:
  /// **'Pełny tekst'**
  String get statusComplete;

  /// No description provided for @statusPartial.
  ///
  /// In pl, this message translates to:
  /// **'Częściowy'**
  String get statusPartial;

  /// No description provided for @statusPlaceholder.
  ///
  /// In pl, this message translates to:
  /// **'Wkrótce'**
  String get statusPlaceholder;

  /// No description provided for @readerSettings.
  ///
  /// In pl, this message translates to:
  /// **'Ustawienia czytnika'**
  String get readerSettings;

  /// No description provided for @fontSize.
  ///
  /// In pl, this message translates to:
  /// **'Rozmiar czcionki'**
  String get fontSize;

  /// No description provided for @fontFamily.
  ///
  /// In pl, this message translates to:
  /// **'Czcionka'**
  String get fontFamily;

  /// No description provided for @chapters.
  ///
  /// In pl, this message translates to:
  /// **'Rozdziały'**
  String get chapters;

  /// No description provided for @chapterOf.
  ///
  /// In pl, this message translates to:
  /// **'Rozdział {current} z {total}'**
  String chapterOf(int current, int total);

  /// No description provided for @addBookmark.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj zakładkę'**
  String get addBookmark;

  /// No description provided for @removeBookmark.
  ///
  /// In pl, this message translates to:
  /// **'Usuń zakładkę'**
  String get removeBookmark;

  /// No description provided for @bookmarkAdded.
  ///
  /// In pl, this message translates to:
  /// **'Zakładka dodana'**
  String get bookmarkAdded;

  /// No description provided for @bookmarkRemoved.
  ///
  /// In pl, this message translates to:
  /// **'Zakładka usunięta'**
  String get bookmarkRemoved;

  /// No description provided for @bookmarkNoteHint.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj notatkę (opcjonalnie)'**
  String get bookmarkNoteHint;

  /// No description provided for @previousChapter.
  ///
  /// In pl, this message translates to:
  /// **'Poprzedni rozdział'**
  String get previousChapter;

  /// No description provided for @nextChapter.
  ///
  /// In pl, this message translates to:
  /// **'Następny rozdział'**
  String get nextChapter;

  /// No description provided for @cancel.
  ///
  /// In pl, this message translates to:
  /// **'Anuluj'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In pl, this message translates to:
  /// **'Zapisz'**
  String get save;

  /// No description provided for @dailyReading.
  ///
  /// In pl, this message translates to:
  /// **'Czytanie na dziś'**
  String get dailyReading;

  /// No description provided for @shareDailyReading.
  ///
  /// In pl, this message translates to:
  /// **'Udostępnij cytat'**
  String get shareDailyReading;

  /// No description provided for @dailyReadingShared.
  ///
  /// In pl, this message translates to:
  /// **'— {author}, via Patres'**
  String dailyReadingShared(String author);

  /// No description provided for @authorProfile.
  ///
  /// In pl, this message translates to:
  /// **'Profil autora'**
  String get authorProfile;

  /// No description provided for @authorBio.
  ///
  /// In pl, this message translates to:
  /// **'Biografia'**
  String get authorBio;

  /// No description provided for @authorSignificance.
  ///
  /// In pl, this message translates to:
  /// **'Znaczenie'**
  String get authorSignificance;

  /// No description provided for @authorWorks.
  ///
  /// In pl, this message translates to:
  /// **'Dzieła w aplikacji'**
  String get authorWorks;

  /// No description provided for @authorDates.
  ///
  /// In pl, this message translates to:
  /// **'Daty'**
  String get authorDates;

  /// No description provided for @authorEra.
  ///
  /// In pl, this message translates to:
  /// **'Epoka'**
  String get authorEra;

  /// No description provided for @authorOriginalName.
  ///
  /// In pl, this message translates to:
  /// **'Imię oryginalne'**
  String get authorOriginalName;

  /// No description provided for @authorUnknown.
  ///
  /// In pl, this message translates to:
  /// **'Nieznany autor'**
  String get authorUnknown;

  /// No description provided for @searchFullText.
  ///
  /// In pl, this message translates to:
  /// **'Szukaj w tekstach'**
  String get searchFullText;

  /// No description provided for @searchFullTextHint.
  ///
  /// In pl, this message translates to:
  /// **'Szukaj słów i fraz w tekstach…'**
  String get searchFullTextHint;

  /// No description provided for @searchIndexing.
  ///
  /// In pl, this message translates to:
  /// **'Indeksowanie tekstów…'**
  String get searchIndexing;

  /// No description provided for @searchPrompt.
  ///
  /// In pl, this message translates to:
  /// **'Wpisz co najmniej 2 znaki, aby wyszukać w całej bibliotece'**
  String get searchPrompt;

  /// No description provided for @searchError.
  ///
  /// In pl, this message translates to:
  /// **'Błąd wyszukiwania'**
  String get searchError;

  /// No description provided for @searchResultsCount.
  ///
  /// In pl, this message translates to:
  /// **'{count} {count, plural, one{wynik} few{wyniki} other{wyników}}'**
  String searchResultsCount(int count);

  /// No description provided for @plansTab.
  ///
  /// In pl, this message translates to:
  /// **'Plany'**
  String get plansTab;

  /// No description provided for @plansTitle.
  ///
  /// In pl, this message translates to:
  /// **'Plany czytania'**
  String get plansTitle;

  /// No description provided for @plansError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się załadować planów'**
  String get plansError;

  /// No description provided for @planDaysCount.
  ///
  /// In pl, this message translates to:
  /// **'{count} {count, plural, one{dzień} few{dni} other{dni}}'**
  String planDaysCount(int count);

  /// No description provided for @planStart.
  ///
  /// In pl, this message translates to:
  /// **'Rozpocznij plan'**
  String get planStart;

  /// No description provided for @planCompleted.
  ///
  /// In pl, this message translates to:
  /// **'ukończono'**
  String get planCompleted;

  /// No description provided for @planStreak.
  ///
  /// In pl, this message translates to:
  /// **'seria'**
  String get planStreak;

  /// No description provided for @planLongestStreak.
  ///
  /// In pl, this message translates to:
  /// **'rekord'**
  String get planLongestStreak;

  /// No description provided for @planMarkComplete.
  ///
  /// In pl, this message translates to:
  /// **'Oznacz jako ukończone'**
  String get planMarkComplete;

  /// No description provided for @planMarkIncomplete.
  ///
  /// In pl, this message translates to:
  /// **'Cofnij ukończenie'**
  String get planMarkIncomplete;

  /// No description provided for @streakDays.
  ///
  /// In pl, this message translates to:
  /// **'{count} {count, plural, one{dzień} few{dni} other{dni}} z rzędu'**
  String streakDays(int count);

  /// No description provided for @planInProgress.
  ///
  /// In pl, this message translates to:
  /// **'W trakcie'**
  String get planInProgress;

  /// No description provided for @planCompletedStatus.
  ///
  /// In pl, this message translates to:
  /// **'Ukończony'**
  String get planCompletedStatus;

  /// No description provided for @planStartPrompt.
  ///
  /// In pl, this message translates to:
  /// **'Rozpocznij plan, aby śledzić postępy'**
  String get planStartPrompt;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pl':
      return AppLocalizationsPl();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
