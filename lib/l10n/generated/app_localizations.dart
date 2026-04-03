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
