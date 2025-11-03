import 'package:equatable/equatable.dart';

/// Base class for all Search events
abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

/// Event to initiate a search
class SearchQuerySubmitted extends SearchEvent {
  final String query;

  const SearchQuerySubmitted({required this.query});

  @override
  List<Object?> get props => [query];
}

/// Event to load more search results (pagination)
class SearchLoadMoreRequested extends SearchEvent {
  const SearchLoadMoreRequested();
}

/// Event to clear search results
class SearchCleared extends SearchEvent {
  const SearchCleared();
}
