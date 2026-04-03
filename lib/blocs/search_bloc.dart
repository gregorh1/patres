import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:patres/models/search_result.dart';
import 'package:patres/services/database_service.dart';
import 'package:patres/services/search_service.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc({required this.searchService}) : super(const SearchState()) {
    on<SearchIndexRequested>(_onIndexRequested);
    on<SearchQueryChanged>(_onQueryChanged);
  }

  final SearchService searchService;
  Timer? _debounce;

  Future<void> _onIndexRequested(
    SearchIndexRequested event,
    Emitter<SearchState> emit,
  ) async {
    emit(state.copyWith(status: SearchStatus.indexing));
    try {
      await searchService.ensureIndexed();
      emit(state.copyWith(status: SearchStatus.ready));
    } on SearchUnavailableException {
      emit(state.copyWith(
        status: SearchStatus.error,
        errorMessage: 'Wyszukiwanie jest niedostępne na tym urządzeniu',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SearchStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    final query = event.query;
    emit(state.copyWith(query: query));

    if (query.trim().length < 2) {
      emit(state.copyWith(
        status: SearchStatus.ready,
        results: [],
      ));
      return;
    }

    emit(state.copyWith(status: SearchStatus.searching));

    // Debounce via a completer pattern inside the handler
    await Future<void>.delayed(const Duration(milliseconds: 300));

    // If query changed during debounce, skip
    if (state.query != query) return;

    try {
      final results = await searchService.search(query);
      // Re-check query hasn't changed
      if (state.query != query) return;
      emit(state.copyWith(
        status: SearchStatus.loaded,
        results: results,
      ));
    } on SearchUnavailableException {
      if (state.query != query) return;
      emit(state.copyWith(
        status: SearchStatus.error,
        errorMessage: 'Wyszukiwanie jest niedostępne na tym urządzeniu',
      ));
    } catch (e) {
      if (state.query != query) return;
      emit(state.copyWith(
        status: SearchStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
