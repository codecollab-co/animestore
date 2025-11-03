import 'package:equatable/equatable.dart';

/// Base class for all Genre events
abstract class GenreEvent extends Equatable {
  const GenreEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load anime by genre
class GenreAnimeLoadRequested extends GenreEvent {
  final String genre;

  const GenreAnimeLoadRequested({required this.genre});

  @override
  List<Object?> get props => [genre];
}

/// Event to load more anime in the genre list (pagination)
class GenreAnimeLoadMoreRequested extends GenreEvent {
  const GenreAnimeLoadMoreRequested();
}
