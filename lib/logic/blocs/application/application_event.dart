import 'package:anime_app/models/anime_model.dart';
import 'package:equatable/equatable.dart';

/// Base class for all Application events
abstract class ApplicationEvent extends Equatable {
  const ApplicationEvent();

  @override
  List<Object?> get props => [];
}

/// Event to initialize the application
class AppInitializeRequested extends ApplicationEvent {
  const AppInitializeRequested();
}

/// Event to retry initialization after error
class AppRetryRequested extends ApplicationEvent {
  const AppRetryRequested();
}

/// Event to load more anime in the main feed list
class AnimeListLoadRequested extends ApplicationEvent {
  const AnimeListLoadRequested();
}

/// Event to load home page data (carousel, trending, recent episodes)
class HomePageInfoLoadRequested extends ApplicationEvent {
  const HomePageInfoLoadRequested();
}

/// Event to refresh home page data
class HomePageRefreshRequested extends ApplicationEvent {
  const HomePageRefreshRequested();
}

/// Event to load available genres
class GenresLoadRequested extends ApplicationEvent {
  const GenresLoadRequested();
}

/// Event to add anime to user's list
class MyAnimeAdded extends ApplicationEvent {
  final String animeId;
  final AnimeModel anime;

  const MyAnimeAdded({
    required this.animeId,
    required this.anime,
  });

  @override
  List<Object?> get props => [animeId, anime];
}

/// Event to remove anime from user's list
class MyAnimeRemoved extends ApplicationEvent {
  final String animeId;

  const MyAnimeRemoved({required this.animeId});

  @override
  List<Object?> get props => [animeId];
}

/// Event to clear all anime from user's list
class MyAnimeListCleared extends ApplicationEvent {
  const MyAnimeListCleared();
}

/// Event to mark an episode as watched
class EpisodeWatched extends ApplicationEvent {
  final String episodeId;
  final String? episodeTitle;
  final int? viewedAt;

  const EpisodeWatched({
    required this.episodeId,
    this.episodeTitle,
    this.viewedAt,
  });

  @override
  List<Object?> get props => [episodeId, episodeTitle, viewedAt];
}

/// Event to remove an episode from watched list
class EpisodeUnwatched extends ApplicationEvent {
  final String episodeId;

  const EpisodeUnwatched({required this.episodeId});

  @override
  List<Object?> get props => [episodeId];
}

/// Event to clear all watched episodes
class WatchedEpisodesCleared extends ApplicationEvent {
  const WatchedEpisodesCleared();
}
