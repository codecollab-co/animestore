import 'package:anime_app/models/anime_model.dart';
import 'package:equatable/equatable.dart';

/// Loading status enum
enum GenreLoadingStatus { none, loading, done, error }

/// Base class for all Genre states
abstract class GenreState extends Equatable {
  const GenreState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class GenreInitial extends GenreState {
  const GenreInitial();
}

/// State when genre anime are being loaded
class GenreLoading extends GenreState {
  final String genre;

  const GenreLoading({required this.genre});

  @override
  List<Object?> get props => [genre];
}

/// State when genre anime loaded successfully
class GenreLoaded extends GenreState {
  final String genre;
  final List<AnimeModel> animeItems;
  final int currentPageNumber;
  final int maxPageNumber;
  final bool isLoadingMore;
  final GenreLoadingStatus loadingStatus;

  const GenreLoaded({
    required this.genre,
    required this.animeItems,
    required this.currentPageNumber,
    required this.maxPageNumber,
    this.isLoadingMore = false,
    this.loadingStatus = GenreLoadingStatus.done,
  });

  @override
  List<Object?> get props => [
        genre,
        animeItems,
        currentPageNumber,
        maxPageNumber,
        isLoadingMore,
        loadingStatus,
      ];

  GenreLoaded copyWith({
    String? genre,
    List<AnimeModel>? animeItems,
    int? currentPageNumber,
    int? maxPageNumber,
    bool? isLoadingMore,
    GenreLoadingStatus? loadingStatus,
  }) {
    return GenreLoaded(
      genre: genre ?? this.genre,
      animeItems: animeItems ?? this.animeItems,
      currentPageNumber: currentPageNumber ?? this.currentPageNumber,
      maxPageNumber: maxPageNumber ?? this.maxPageNumber,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadingStatus: loadingStatus ?? this.loadingStatus,
    );
  }
}

/// State when loading failed
class GenreError extends GenreState {
  final String genre;
  final String errorMessage;

  const GenreError({
    required this.genre,
    required this.errorMessage,
  });

  @override
  List<Object?> get props => [genre, errorMessage];
}
