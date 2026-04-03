part of 'library_bloc.dart';

enum LibraryStatus { initial, loading, loaded, error }

enum LibrarySortMode { title, author, era }

enum LibraryViewMode { grid, list }

class LibraryState extends Equatable {
  const LibraryState({
    this.status = LibraryStatus.initial,
    this.allTexts = const [],
    this.filteredTexts = const [],
    this.availableCategories = const [],
    this.availableEras = const [],
    this.searchQuery = '',
    this.selectedCategory,
    this.selectedEra,
    this.selectedLanguage,
    this.sortMode = LibrarySortMode.title,
    this.viewMode = LibraryViewMode.grid,
  });

  final LibraryStatus status;
  final List<TextEntry> allTexts;
  final List<TextEntry> filteredTexts;
  final List<String> availableCategories;
  final List<String> availableEras;
  final String searchQuery;
  final String? selectedCategory;
  final String? selectedEra;
  final String? selectedLanguage;
  final LibrarySortMode sortMode;
  final LibraryViewMode viewMode;

  LibraryState copyWith({
    LibraryStatus? status,
    List<TextEntry>? allTexts,
    List<TextEntry>? filteredTexts,
    List<String>? availableCategories,
    List<String>? availableEras,
    String? searchQuery,
    String? selectedCategory,
    String? selectedEra,
    String? selectedLanguage,
    LibrarySortMode? sortMode,
    LibraryViewMode? viewMode,
  }) {
    return LibraryState(
      status: status ?? this.status,
      allTexts: allTexts ?? this.allTexts,
      filteredTexts: filteredTexts ?? this.filteredTexts,
      availableCategories: availableCategories ?? this.availableCategories,
      availableEras: availableEras ?? this.availableEras,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory,
      selectedEra: selectedEra,
      selectedLanguage: selectedLanguage,
      sortMode: sortMode ?? this.sortMode,
      viewMode: viewMode ?? this.viewMode,
    );
  }

  @override
  List<Object?> get props => [
        status,
        allTexts,
        filteredTexts,
        availableCategories,
        availableEras,
        searchQuery,
        selectedCategory,
        selectedEra,
        selectedLanguage,
        sortMode,
        viewMode,
      ];
}
