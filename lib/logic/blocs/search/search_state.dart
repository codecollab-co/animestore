import 'package:anime_app/models/anime_model.dart';
import 'package:equatable/equatable.dart';

/// Base class for all Search states
abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any search
class SearchInitial extends SearchState {
  const SearchInitial();
}

/// State when search is in progress
class SearchInProgress extends SearchState {
  const SearchInProgress();
}

/// State when search completed successfully
class SearchSuccess extends SearchState {
  final List<AnimeModel> results;
  final String currentQuery;
  final int pageNumber;
  final int maxPageNumber;
  final bool isLoadingMore;

  const SearchSuccess({
    required this.results,
    required this.currentQuery,
    required this.pageNumber,
    required this.maxPageNumber,
    this.isLoadingMore = false,
  });

  @override
  List<Object?> get props => [
        results,
        currentQuery,
        pageNumber,
        maxPageNumber,
        isLoadingMore,
      ];

  SearchSuccess copyWith({
    List<AnimeModel>? results,
    String? currentQuery,
    int? pageNumber,
    int? maxPageNumber,
    bool? isLoadingMore,
  }) {
    return SearchSuccess(
      results: results ?? this.results,
      currentQuery: currentQuery ?? this.currentQuery,
      pageNumber: pageNumber ?? this.pageNumber,
      maxPageNumber: maxPageNumber ?? this.maxPageNumber,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

/// State when search resulted in an error
class SearchError extends SearchState {
  final String message;

  const SearchError({required this.message});

  @override
  List<Object?> get props => [message];
}
