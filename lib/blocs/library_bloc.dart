import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:patres/models/text_entry.dart';
import 'package:patres/services/text_service.dart';

part 'library_event.dart';
part 'library_state.dart';

class LibraryBloc extends Bloc<LibraryEvent, LibraryState> {
  LibraryBloc({required this.textService}) : super(const LibraryState()) {
    on<LibraryLoadRequested>(_onLoadRequested);
    on<LibrarySearchChanged>(_onSearchChanged);
    on<LibraryCategoryFilterChanged>(_onCategoryFilterChanged);
    on<LibraryEraFilterChanged>(_onEraFilterChanged);
    on<LibrarySortChanged>(_onSortChanged);
    on<LibraryViewModeToggled>(_onViewModeToggled);
  }

  final TextService textService;

  Future<void> _onLoadRequested(
    LibraryLoadRequested event,
    Emitter<LibraryState> emit,
  ) async {
    emit(state.copyWith(status: LibraryStatus.loading));
    try {
      final texts = await textService.loadManifest();
      final categories = texts.map((t) => t.category).toSet().toList()..sort();
      final eras = texts.map((t) => t.era).toSet().toList()
        ..sort((a, b) {
          final aKey = _eraSortKey(a);
          final bKey = _eraSortKey(b);
          return aKey.compareTo(bKey);
        });
      emit(state.copyWith(
        status: LibraryStatus.loaded,
        allTexts: texts,
        filteredTexts: _applyFilters(texts, state),
        availableCategories: categories,
        availableEras: eras,
      ));
    } catch (e) {
      emit(state.copyWith(status: LibraryStatus.error));
    }
  }

  void _onSearchChanged(
    LibrarySearchChanged event,
    Emitter<LibraryState> emit,
  ) {
    final updated = state.copyWith(searchQuery: event.query);
    emit(updated.copyWith(filteredTexts: _applyFilters(state.allTexts, updated)));
  }

  void _onCategoryFilterChanged(
    LibraryCategoryFilterChanged event,
    Emitter<LibraryState> emit,
  ) {
    final updated = state.copyWith(selectedCategory: event.category);
    emit(updated.copyWith(filteredTexts: _applyFilters(state.allTexts, updated)));
  }

  void _onEraFilterChanged(
    LibraryEraFilterChanged event,
    Emitter<LibraryState> emit,
  ) {
    final updated = state.copyWith(selectedEra: event.era);
    emit(updated.copyWith(filteredTexts: _applyFilters(state.allTexts, updated)));
  }

  void _onSortChanged(
    LibrarySortChanged event,
    Emitter<LibraryState> emit,
  ) {
    final updated = state.copyWith(sortMode: event.sortMode);
    emit(updated.copyWith(filteredTexts: _applyFilters(state.allTexts, updated)));
  }

  void _onViewModeToggled(
    LibraryViewModeToggled event,
    Emitter<LibraryState> emit,
  ) {
    emit(state.copyWith(
      viewMode: state.viewMode == LibraryViewMode.grid
          ? LibraryViewMode.list
          : LibraryViewMode.grid,
    ));
  }

  List<TextEntry> _applyFilters(List<TextEntry> texts, LibraryState s) {
    var result = texts.toList();

    // Search
    if (s.searchQuery.isNotEmpty) {
      final q = s.searchQuery.toLowerCase();
      result = result.where((t) {
        return t.title.toLowerCase().contains(q) ||
            t.author.toLowerCase().contains(q) ||
            t.titleOriginal.toLowerCase().contains(q);
      }).toList();
    }

    // Category filter
    if (s.selectedCategory != null) {
      result = result.where((t) => t.category == s.selectedCategory).toList();
    }

    // Era filter
    if (s.selectedEra != null) {
      result = result.where((t) => t.era == s.selectedEra).toList();
    }

    // Sort
    switch (s.sortMode) {
      case LibrarySortMode.title:
        result.sort((a, b) => a.title.compareTo(b.title));
      case LibrarySortMode.author:
        result.sort((a, b) => a.author.compareTo(b.author));
      case LibrarySortMode.era:
        result.sort((a, b) => a.eraSortKey.compareTo(b.eraSortKey));
    }

    return result;
  }

  int _eraSortKey(String era) {
    final match = RegExp(r'([IVXLCDM]+)').firstMatch(era);
    if (match == null) return 99;
    return TextEntry.romanToInt(match.group(1)!);
  }
}
