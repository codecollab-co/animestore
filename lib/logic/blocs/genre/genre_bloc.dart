import 'package:anime_app/data/repositories/genre_repository.dart';
import 'package:anime_app/logic/blocs/genre/genre_event.dart';
import 'package:anime_app/logic/blocs/genre/genre_state.dart';
import 'package:anime_app/models/anime_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// GenreBloc manages genre-filtered anime lists
/// Handles loading anime by genre with pagination
class GenreBloc extends Bloc<GenreEvent, GenreState> {
  final GenreRepository _genreRepository;

  static const int pageLoadNumber = 2;

  GenreBloc({
    required GenreRepository genreRepository,
  })  : _genreRepository = genreRepository,
        super(const GenreInitial()) {
    on<GenreAnimeLoadRequested>(_onGenreAnimeLoadRequested);
    on<GenreAnimeLoadMoreRequested>(_onGenreAnimeLoadMoreRequested);
  }

  /// Load anime by genre
  Future<void> _onGenreAnimeLoadRequested(
    GenreAnimeLoadRequested event,
    Emitter<GenreState> emit,
  ) async {
    emit(GenreLoading(genre: event.genre));

    try {
      final results = <AnimeModel>[];
      int currentPageNumber = 1;
      int maxPageNumber = 100; // Jikan has many pages

      // Parse genre as integer ID
      final genreId = int.tryParse(event.genre) ?? 1;

      // Load first page
      final animeList = await _genreRepository.getAnimeByGenre(
        genreId,
        page: currentPageNumber,
      );

      results.addAll(animeList);
      currentPageNumber++;

      // Load additional pages if available
      if (animeList.isNotEmpty && currentPageNumber <= (1 + pageLoadNumber)) {
        for (var i = 0; i < pageLoadNumber; i++) {
          try {
            final pageData = await _genreRepository.getAnimeByGenre(
              genreId,
              page: currentPageNumber,
            );
            if (pageData.isEmpty) break;
            results.addAll(pageData);
            currentPageNumber++;
          } catch (e) {
            print('GenreBloc: Error loading page $currentPageNumber: $e');
            currentPageNumber++;
          }
        }
      }

      emit(GenreLoaded(
        genre: event.genre,
        animeItems: results,
        currentPageNumber: currentPageNumber,
        maxPageNumber: maxPageNumber,
      ));
    } catch (e) {
      print('GenreBloc::_onGenreAnimeLoadRequested Error: $e');
      emit(GenreError(
        genre: event.genre,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Load more anime in genre list (pagination)
  Future<void> _onGenreAnimeLoadMoreRequested(
    GenreAnimeLoadMoreRequested event,
    Emitter<GenreState> emit,
  ) async {
    if (state is! GenreLoaded) return;

    final currentState = state as GenreLoaded;

    if (currentState.isLoadingMore) return;
    if (currentState.currentPageNumber > currentState.maxPageNumber) return;

    emit(currentState.copyWith(isLoadingMore: true));

    try {
      final results = <AnimeModel>[];
      var currentPageNumber = currentState.currentPageNumber;

      // Parse genre as integer ID
      final genreId = int.tryParse(currentState.genre) ?? 1;

      // Load 2 more pages
      for (var i = 0; i < pageLoadNumber; i++) {
        if (currentPageNumber <= currentState.maxPageNumber) {
          try {
            final pageData = await _genreRepository.getAnimeByGenre(
              genreId,
              page: currentPageNumber,
            );
            if (pageData.isEmpty) break;
            results.addAll(pageData);
            currentPageNumber++;
          } catch (e) {
            print('GenreBloc: Error loading more page $currentPageNumber: $e');
            currentPageNumber++;
          }
        }
      }

      emit(currentState.copyWith(
        animeItems: [...currentState.animeItems, ...results],
        currentPageNumber: currentPageNumber,
        isLoadingMore: false,
      ));
    } catch (e) {
      print('GenreBloc::_onGenreAnimeLoadMoreRequested Error: $e');
      emit(currentState.copyWith(isLoadingMore: false));
    }
  }
}
