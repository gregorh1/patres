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
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSepia => 'Sepia';

  @override
  String get language => 'Language';

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
}
