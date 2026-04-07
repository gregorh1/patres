// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Patres';

  @override
  String get homeTab => 'Home';

  @override
  String get libraryTab => 'Library';

  @override
  String get settingsTab => 'Settings';

  @override
  String get homeGreeting => 'Welcome to Patres';

  @override
  String get homeSubtitle => 'Discover the wisdom of the Church Fathers';

  @override
  String get continueReading => 'Continue reading';

  @override
  String get recommended => 'Recommended';

  @override
  String get libraryTitle => 'Library';

  @override
  String get libraryEmpty => 'Your library is empty';

  @override
  String get libraryEmptyHint => 'Add texts from the catalog to get started';

  @override
  String get searchHint => 'Search authors, titles…';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get themeMode => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSepia => 'Sepia';

  @override
  String get language => 'Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languagePolish => 'Polski';

  @override
  String get readerTitle => 'Reader';

  @override
  String get readerPlaceholder => 'Reading content will appear here.';

  @override
  String get churchFathers => 'Church Fathers';

  @override
  String get christianClassics => 'Christian Classics';

  @override
  String get aboutApp => 'About';

  @override
  String get aboutDescription =>
      'Patres — a beautiful reader for patristic texts and Christian classics, with planned TTS audiobook support.';

  @override
  String get version => 'Version';

  @override
  String get filterAll => 'All';

  @override
  String get filterCategory => 'Category';

  @override
  String get filterEra => 'Era';

  @override
  String get sortByTitle => 'Title';

  @override
  String get sortByAuthor => 'Author';

  @override
  String get sortByEra => 'Era';

  @override
  String get sortBy => 'Sort';

  @override
  String get categoryPatrystyka => 'Patristics';

  @override
  String get categoryDuchowosc => 'Spirituality';

  @override
  String get categoryMonastycyzm => 'Monasticism';

  @override
  String get categoryHymnografia => 'Hymnography';

  @override
  String get categoryKaznodziejstwo => 'Preaching';

  @override
  String chaptersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'chapters',
      one: 'chapter',
    );
    return '$count $_temp0';
  }

  @override
  String get noResults => 'No results';

  @override
  String get noResultsHint => 'Try changing your filters or search';

  @override
  String get statusComplete => 'Full text';

  @override
  String get statusPartial => 'Partial';

  @override
  String get statusPlaceholder => 'Coming soon';

  @override
  String get readerSettings => 'Reader settings';

  @override
  String get fontSize => 'Font size';

  @override
  String get fontFamily => 'Font';

  @override
  String get chapters => 'Chapters';

  @override
  String chapterOf(int current, int total) {
    return 'Chapter $current of $total';
  }

  @override
  String get addBookmark => 'Add bookmark';

  @override
  String get removeBookmark => 'Remove bookmark';

  @override
  String get bookmarkAdded => 'Bookmark added';

  @override
  String get bookmarkRemoved => 'Bookmark removed';

  @override
  String get bookmarkNoteHint => 'Add a note (optional)';

  @override
  String get previousChapter => 'Previous chapter';

  @override
  String get nextChapter => 'Next chapter';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get dailyReading => 'Daily reading';

  @override
  String get shareDailyReading => 'Share quote';

  @override
  String dailyReadingShared(String author) {
    return '— $author, via Patres';
  }

  @override
  String get authorProfile => 'Author profile';

  @override
  String get authorBio => 'Biography';

  @override
  String get authorSignificance => 'Significance';

  @override
  String get authorWorks => 'Works in the app';

  @override
  String get authorDates => 'Dates';

  @override
  String get authorEra => 'Era';

  @override
  String get authorOriginalName => 'Original name';

  @override
  String get authorUnknown => 'Unknown author';

  @override
  String get searchFullText => 'Search texts';

  @override
  String get searchFullTextHint => 'Search words and phrases in texts…';

  @override
  String get searchIndexing => 'Indexing texts…';

  @override
  String get searchPrompt =>
      'Type at least 2 characters to search the entire library';

  @override
  String get searchError => 'Search error';

  @override
  String searchResultsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'results',
      one: 'result',
    );
    return '$count $_temp0';
  }

  @override
  String get plansTab => 'Plans';

  @override
  String get plansTitle => 'Reading plans';

  @override
  String get plansError => 'Failed to load plans';

  @override
  String planDaysCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'days',
      one: 'day',
    );
    return '$count $_temp0';
  }

  @override
  String get planStart => 'Start plan';

  @override
  String get planCompleted => 'completed';

  @override
  String get planStreak => 'streak';

  @override
  String get planLongestStreak => 'best';

  @override
  String get planMarkComplete => 'Mark as complete';

  @override
  String get planMarkIncomplete => 'Mark as incomplete';

  @override
  String streakDays(int count) {
    return '$count-day streak';
  }

  @override
  String get planInProgress => 'In Progress';

  @override
  String get planCompletedStatus => 'Completed';

  @override
  String get planStartPrompt => 'Start this plan to track your progress';

  @override
  String get audioListen => 'Listen';

  @override
  String get audioDownloads => 'Audiobooks';

  @override
  String get audioDownloadsDescription => 'Manage downloaded audiobooks';

  @override
  String get audioDownload => 'Download audio';

  @override
  String get audioDeleteDownload => 'Delete audio';

  @override
  String get audioDeleteConfirm =>
      'Are you sure you want to delete the downloaded audio?';

  @override
  String get audioDelete => 'Delete';

  @override
  String get audioStorageUsed => 'Storage used';

  @override
  String get audioGenerating => 'Generating audio…';

  @override
  String get audioGeneratingChapter => 'Generating chapter audio…';

  @override
  String get audioGenerationError => 'Audio generation error';

  @override
  String audioChapterProgress(int completed, int total) {
    return 'Chapter $completed of $total';
  }

  @override
  String get audioSpeed => 'Playback speed';

  @override
  String get audioSleepTimer => 'Sleep timer';

  @override
  String get audioSleepTimerActive => 'Timer active';

  @override
  String get audioSleepTimerCancel => 'Cancel timer';

  @override
  String get audioSleepTimer15 => '15 minutes';

  @override
  String get audioSleepTimer30 => '30 minutes';

  @override
  String get audioSleepTimer45 => '45 minutes';

  @override
  String get audioSleepTimer60 => '1 hour';

  @override
  String get audioSkipForward => 'Skip forward';

  @override
  String get audioSkipBackward => 'Skip backward';

  @override
  String get switchLanguage => 'Switch language';
}
