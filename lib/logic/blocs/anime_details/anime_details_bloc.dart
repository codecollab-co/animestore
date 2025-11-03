import 'dart:math';
import 'package:anime_app/data/repositories/anime_repository.dart';
import 'package:anime_app/data/repositories/search_repository.dart';
import 'package:anime_app/logic/blocs/anime_details/anime_details_event.dart';
import 'package:anime_app/logic/blocs/anime_details/anime_details_state.dart';
import 'package:anime_app/models/anime_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// AnimeDetailsBloc manages anime detail screen state
/// Handles loading anime details, related anime suggestions, and tab navigation
class AnimeDetailsBloc extends Bloc<AnimeDetailsEvent, AnimeDetailsState> {
  final AnimeRepository _animeRepository;
  final SearchRepository _searchRepository;

  AnimeDetailsBloc({
    required AnimeRepository animeRepository,
    required SearchRepository searchRepository,
    required AnimeModel anime,
    Color? initialBackgroundColor,
  })  : _animeRepository = animeRepository,
        _searchRepository = searchRepository,
        super(AnimeDetailsInitial(
          anime: anime,
          backgroundColor: initialBackgroundColor,
        )) {
    on<AnimeDetailsLoadRequested>(_onAnimeDetailsLoadRequested);
    on<AnimeRelatedLoadRequested>(_onAnimeRelatedLoadRequested);
    on<AnimeDetailsTabChanged>(_onAnimeDetailsTabChanged);
    on<AnimeBackgroundColorExtracted>(_onAnimeBackgroundColorExtracted);
    on<EpisodeVisualized>(_onEpisodeVisualized);
  }

  /// Load anime details
  Future<void> _onAnimeDetailsLoadRequested(
    AnimeDetailsLoadRequested event,
    Emitter<AnimeDetailsState> emit,
  ) async {
    if (state.loadingStatus == LoadingStatus.loading) return;

    emit(AnimeDetailsLoading(
      currentAnime: event.anime,
      backgroundColor: state.backgroundColor,
      tabChoice: state.tabChoice,
      visualizedEpisodes: state.visualizedEpisodes,
    ));

    try {
      // Get anime details with episodes
      final animeWithDetails = await _animeRepository.getAnimeDetails(
        event.anime.id,
      );

      // Get episodes
      final episodes = await _animeRepository.getAnimeEpisodes(
        event.anime.id,
      );

      emit(AnimeDetailsLoaded(
        currentAnime: animeWithDetails,
        backgroundColor: state.backgroundColor,
        tabChoice: state.tabChoice,
        visualizedEpisodes: state.visualizedEpisodes,
        episodes: episodes,
      ));

      // Load suggestions if requested
      if (event.shouldLoadSuggestions) {
        add(const AnimeRelatedLoadRequested());
      }
    } catch (e) {
      print('AnimeDetailsBloc::_onAnimeDetailsLoadRequested Error: $e');
      emit(AnimeDetailsError(
        currentAnime: event.anime,
        backgroundColor: state.backgroundColor,
        tabChoice: state.tabChoice,
        visualizedEpisodes: state.visualizedEpisodes,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Load related anime suggestions based on genres
  Future<void> _onAnimeRelatedLoadRequested(
    AnimeRelatedLoadRequested event,
    Emitter<AnimeDetailsState> emit,
  ) async {
    if (state is! AnimeDetailsLoaded) return;

    final currentState = state as AnimeDetailsLoaded;

    try {
      // Get recommendations from Jikan if MAL ID is available
      final malId = int.tryParse(currentState.currentAnime.sourceIds.malId ?? '');
      if (malId != null) {
        final recommendations = await _animeRepository.getRecommendations(malId);
        emit(currentState.copyWith(relatedAnimes: recommendations));
        return;
      }

      // Fallback: search by genre
      if (currentState.currentAnime.genres.isNotEmpty) {
        final query = currentState.currentAnime.genres.first;
        final searchResults = await _searchRepository.search(query, page: 1);

        // Filter out the current anime from suggestions
        final relatedAnimes = searchResults.results
            .where((item) => item.id != currentState.currentAnime.id)
            .take(10)
            .toList();

        emit(currentState.copyWith(relatedAnimes: relatedAnimes));
      }
    } catch (e) {
      print('AnimeDetailsBloc::_onAnimeRelatedLoadRequested Error: $e');
      // Don't emit error, just keep state without related animes
      emit(currentState.copyWith(relatedAnimes: []));
    }
  }

  /// Change tab selection
  void _onAnimeDetailsTabChanged(
    AnimeDetailsTabChanged event,
    Emitter<AnimeDetailsState> emit,
  ) {
    if (state is AnimeDetailsLoaded) {
      final currentState = state as AnimeDetailsLoaded;
      emit(currentState.copyWith(tabChoice: event.tab));
    }
  }

  /// Update background color
  void _onAnimeBackgroundColorExtracted(
    AnimeBackgroundColorExtracted event,
    Emitter<AnimeDetailsState> emit,
  ) {
    if (state is AnimeDetailsLoaded) {
      final currentState = state as AnimeDetailsLoaded;
      emit(currentState.copyWith(backgroundColor: event.color));
    }
  }

  /// Mark an episode as visualized
  void _onEpisodeVisualized(
    EpisodeVisualized event,
    Emitter<AnimeDetailsState> emit,
  ) {
    if (state is AnimeDetailsLoaded) {
      final currentState = state as AnimeDetailsLoaded;
      if (!currentState.visualizedEpisodes.contains(event.episodeId)) {
        emit(currentState.copyWith(
          visualizedEpisodes: [...currentState.visualizedEpisodes, event.episodeId],
        ));
      }
    }
  }

  /// Generate a random query from genre list
  String _generateQuery(List<String> data) {
    final generator = Random();
    var totalIndexes = generator.nextInt(data.length + 1);
    String query = '';

    for (var i = 0; i < totalIndexes; i++) {
      if (data.isEmpty) break;
      var index = generator.nextInt(data.length);
      query += data[index];
      data.removeAt(index);
    }

    return query;
  }
}
