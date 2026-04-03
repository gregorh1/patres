part of 'library_bloc.dart';

abstract class LibraryEvent extends Equatable {
  const LibraryEvent();

  @override
  List<Object?> get props => [];
}

class LibraryLoadRequested extends LibraryEvent {
  const LibraryLoadRequested();
}

class LibrarySearchChanged extends LibraryEvent {
  const LibrarySearchChanged(this.query);
  final String query;

  @override
  List<Object?> get props => [query];
}

class LibraryCategoryFilterChanged extends LibraryEvent {
  const LibraryCategoryFilterChanged(this.category);

  /// Null clears the filter.
  final String? category;

  @override
  List<Object?> get props => [category];
}

class LibraryEraFilterChanged extends LibraryEvent {
  const LibraryEraFilterChanged(this.era);

  /// Null clears the filter.
  final String? era;

  @override
  List<Object?> get props => [era];
}

class LibrarySortChanged extends LibraryEvent {
  const LibrarySortChanged(this.sortMode);
  final LibrarySortMode sortMode;

  @override
  List<Object?> get props => [sortMode];
}

class LibraryViewModeToggled extends LibraryEvent {
  const LibraryViewModeToggled();
}
