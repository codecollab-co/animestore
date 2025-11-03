import 'package:anime_app/data/repositories/search_repository.dart';
import 'package:anime_app/logic/blocs/search/search_event.dart';
import 'package:anime_app/logic/blocs/search/search_state.dart';
import 'package:anime_app/models/anime_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// SearchBloc manages search functionality
/// Handles search queries and pagination of results
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchRepository _searchRepository;

  static const int pageLoadNumber = 2;

  SearchBloc({
    required SearchRepository searchRepository,
  })  : _searchRepository = searchRepository,
        super(const SearchInitial()) {
    on<SearchQuerySubmitted>(_onSearchQuerySubmitted);
    on<SearchLoadMoreRequested>(_onSearchLoadMoreRequested);
    on<SearchCleared>(_onSearchCleared);
  }

  /// Handle search query submission
  Future<void> _onSearchQuerySubmitted(
    SearchQuerySubmitted event,
    Emitter<SearchState> emit,
  ) async {
    if (state is SearchInProgress) return;

    emit(const SearchInProgress());

    try {
      final results = <AnimeModel>[];
      int pageNumberToLoad = 1;
      int maxPageNumber = 100; // Jikan has many pages

      // Load first page
      final searchResult = await _searchRepository.search(
        event.query,
        page: pageNumberToLoad,
      );

      results.addAll(searchResult.results);
      pageNumberToLoad++;

      // Load additional pages if available and hasNextPage is true
      if (searchResult.hasNextPage && (pageNumberToLoad <= pageLoadNumber + 1)) {
        for (var i = 0; i < pageLoadNumber; i++) {
          try {
            final pageData = await _searchRepository.search(
              event.query,
              page: pageNumberToLoad,
            );
            results.addAll(pageData.results);
            pageNumberToLoad++;
            if (!pageData.hasNextPage) break;
          } catch (e) {
            print('SearchBloc: Error loading page $pageNumberToLoad: $e');
            pageNumberToLoad++;
          }
        }
      }

      emit(SearchSuccess(
        results: results,
        currentQuery: event.query,
        pageNumber: pageNumberToLoad,
        maxPageNumber: maxPageNumber,
      ));
    } catch (e) {
      print('SearchBloc::_onSearchQuerySubmitted Error: $e');
      emit(SearchError(message: e.toString()));
    }
  }

  /// Handle load more request (pagination)
  Future<void> _onSearchLoadMoreRequested(
    SearchLoadMoreRequested event,
    Emitter<SearchState> emit,
  ) async {
    if (state is! SearchSuccess) return;

    final currentState = state as SearchSuccess;

    if (currentState.isLoadingMore) return;
    if (currentState.pageNumber > currentState.maxPageNumber) return;

    emit(currentState.copyWith(isLoadingMore: true));

    try {
      final results = <AnimeModel>[];
      var pageNumberToLoad = currentState.pageNumber;

      // Load 2 more pages
      for (var i = 0; i < 2; i++) {
        if (pageNumberToLoad <= currentState.maxPageNumber) {
          try {
            final searchResult = await _searchRepository.search(
              currentState.currentQuery,
              page: pageNumberToLoad,
            );
            results.addAll(searchResult.results);
            pageNumberToLoad++;
            if (!searchResult.hasNextPage) break;
          } catch (e) {
            print('SearchBloc: Error loading more page $pageNumberToLoad: $e');
            pageNumberToLoad++;
          }
        }
      }

      emit(currentState.copyWith(
        results: [...currentState.results, ...results],
        pageNumber: pageNumberToLoad,
        isLoadingMore: false,
      ));
    } catch (e) {
      print('SearchBloc::_onSearchLoadMoreRequested Error: $e');
      emit(currentState.copyWith(isLoadingMore: false));
    }
  }

  /// Handle clear search request
  void _onSearchCleared(
    SearchCleared event,
    Emitter<SearchState> emit,
  ) {
    emit(const SearchInitial());
  }
}
