import 'package:anime_app/logic/blocs/anime_details/anime_details_event.dart';
import 'package:anime_app/models/anime_model.dart';
import 'package:anime_app/models/episode_model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Loading status enum
enum LoadingStatus { none, loading, done, error }

/// Base class for all AnimeDetails states
abstract class AnimeDetailsState extends Equatable {
  final LoadingStatus loadingStatus;
  final AnimeModel currentAnime;
  final Color backgroundColor;
  final TabChoice tabChoice;
  final List<String> visualizedEpisodes;
  final List<EpisodeModel>? episodes;
  final List<AnimeModel>? relatedAnimes;

  const AnimeDetailsState({
    required this.loadingStatus,
    required this.currentAnime,
    required this.backgroundColor,
    required this.tabChoice,
    required this.visualizedEpisodes,
    this.episodes,
    this.relatedAnimes,
  });

  @override
  List<Object?> get props => [
        loadingStatus,
        currentAnime,
        backgroundColor,
        tabChoice,
        visualizedEpisodes,
        episodes,
        relatedAnimes,
      ];
}

/// Initial state before loading
class AnimeDetailsInitial extends AnimeDetailsState {
  AnimeDetailsInitial({
    required AnimeModel anime,
    Color? backgroundColor,
  }) : super(
          loadingStatus: LoadingStatus.none,
          currentAnime: anime,
          backgroundColor: backgroundColor ?? Colors.grey[200]!,
          tabChoice: TabChoice.episodes,
          visualizedEpisodes: const [],
        );
}

/// State when anime details are being loaded
class AnimeDetailsLoading extends AnimeDetailsState {
  const AnimeDetailsLoading({
    required AnimeModel currentAnime,
    required Color backgroundColor,
    required TabChoice tabChoice,
    required List<String> visualizedEpisodes,
  }) : super(
          loadingStatus: LoadingStatus.loading,
          currentAnime: currentAnime,
          backgroundColor: backgroundColor,
          tabChoice: tabChoice,
          visualizedEpisodes: visualizedEpisodes,
        );
}

/// State when anime details loaded successfully
class AnimeDetailsLoaded extends AnimeDetailsState {
  const AnimeDetailsLoaded({
    required AnimeModel currentAnime,
    required Color backgroundColor,
    required TabChoice tabChoice,
    required List<String> visualizedEpisodes,
    required List<EpisodeModel> episodes,
    List<AnimeModel>? relatedAnimes,
  }) : super(
          loadingStatus: LoadingStatus.done,
          currentAnime: currentAnime,
          backgroundColor: backgroundColor,
          tabChoice: tabChoice,
          visualizedEpisodes: visualizedEpisodes,
          episodes: episodes,
          relatedAnimes: relatedAnimes,
        );

  AnimeDetailsLoaded copyWith({
    AnimeModel? currentAnime,
    Color? backgroundColor,
    TabChoice? tabChoice,
    List<String>? visualizedEpisodes,
    List<EpisodeModel>? episodes,
    List<AnimeModel>? relatedAnimes,
  }) {
    return AnimeDetailsLoaded(
      currentAnime: currentAnime ?? this.currentAnime,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      tabChoice: tabChoice ?? this.tabChoice,
      visualizedEpisodes: visualizedEpisodes ?? this.visualizedEpisodes,
      episodes: episodes ?? this.episodes!,
      relatedAnimes: relatedAnimes ?? this.relatedAnimes,
    );
  }
}

/// State when loading failed
class AnimeDetailsError extends AnimeDetailsState {
  final String errorMessage;

  const AnimeDetailsError({
    required AnimeModel currentAnime,
    required Color backgroundColor,
    required TabChoice tabChoice,
    required List<String> visualizedEpisodes,
    required this.errorMessage,
  }) : super(
          loadingStatus: LoadingStatus.error,
          currentAnime: currentAnime,
          backgroundColor: backgroundColor,
          tabChoice: tabChoice,
          visualizedEpisodes: visualizedEpisodes,
        );

  @override
  List<Object?> get props => [...super.props, errorMessage];
}
