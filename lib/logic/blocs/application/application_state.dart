import 'package:anime_app/model/AppInfo.dart';
import 'package:anime_app/model/EpisodeWatched.dart';
import 'package:anime_app/models/anime_model.dart';
import 'package:anime_app/models/episode_model.dart';
import 'package:equatable/equatable.dart';

/// Enum for app initialization status
enum AppInitStatus { initializing, initialized, initError }

/// Enum for loading status
enum LoadingStatus { none, loading, done, error }

/// Base class for all Application states
abstract class ApplicationState extends Equatable {
  final AppInitStatus initStatus;
  final LoadingStatus animeListLoadingStatus;
  final List<AnimeModel> feedAnimeList;
  final List<AnimeModel> mostRecentAnimeList;
  final List<AnimeModel> topAnimeList;
  final List<AnimeModel> dayReleaseList;
  final List<String> genreList;
  final Map<String, AnimeModel> myAnimeMap;
  final Map<String, EpisodeWatched> watchedEpisodeMap;
  final List<EpisodeModel> latestEpisodes;
  final int mainAnimesPageCounter;
  final int maxMainAnimesPageNumber;
  final AppInfo? appInfo;

  const ApplicationState({
    required this.initStatus,
    required this.animeListLoadingStatus,
    required this.feedAnimeList,
    required this.mostRecentAnimeList,
    required this.topAnimeList,
    required this.dayReleaseList,
    required this.genreList,
    required this.myAnimeMap,
    required this.watchedEpisodeMap,
    required this.latestEpisodes,
    required this.mainAnimesPageCounter,
    required this.maxMainAnimesPageNumber,
    this.appInfo,
  });

  /// Check if an episode has been watched
  bool isEpisodeWatched(String episodeId) =>
      watchedEpisodeMap.containsKey(episodeId);

  @override
  List<Object?> get props => [
        initStatus,
        animeListLoadingStatus,
        feedAnimeList,
        mostRecentAnimeList,
        topAnimeList,
        dayReleaseList,
        genreList,
        myAnimeMap,
        watchedEpisodeMap,
        latestEpisodes,
        mainAnimesPageCounter,
        maxMainAnimesPageNumber,
        appInfo,
      ];

  /// Create a copy with updated fields
  ApplicationState copyWith({
    AppInitStatus? initStatus,
    LoadingStatus? animeListLoadingStatus,
    List<AnimeModel>? feedAnimeList,
    List<AnimeModel>? mostRecentAnimeList,
    List<AnimeModel>? topAnimeList,
    List<AnimeModel>? dayReleaseList,
    List<String>? genreList,
    Map<String, AnimeModel>? myAnimeMap,
    Map<String, EpisodeWatched>? watchedEpisodeMap,
    List<EpisodeModel>? latestEpisodes,
    int? mainAnimesPageCounter,
    int? maxMainAnimesPageNumber,
    AppInfo? appInfo,
  });
}

/// Initial state before app initialization
class ApplicationInitial extends ApplicationState {
  const ApplicationInitial()
      : super(
          initStatus: AppInitStatus.initializing,
          animeListLoadingStatus: LoadingStatus.none,
          feedAnimeList: const [],
          mostRecentAnimeList: const [],
          topAnimeList: const [],
          dayReleaseList: const [],
          genreList: const [],
          myAnimeMap: const {},
          watchedEpisodeMap: const {},
          latestEpisodes: const [],
          mainAnimesPageCounter: 1,
          maxMainAnimesPageNumber: 1,
        );

  @override
  ApplicationState copyWith({
    AppInitStatus? initStatus,
    LoadingStatus? animeListLoadingStatus,
    List<AnimeModel>? feedAnimeList,
    List<AnimeModel>? mostRecentAnimeList,
    List<AnimeModel>? topAnimeList,
    List<AnimeModel>? dayReleaseList,
    List<String>? genreList,
    Map<String, AnimeModel>? myAnimeMap,
    Map<String, EpisodeWatched>? watchedEpisodeMap,
    List<EpisodeModel>? latestEpisodes,
    int? mainAnimesPageCounter,
    int? maxMainAnimesPageNumber,
    AppInfo? appInfo,
  }) {
    return ApplicationLoaded(
      initStatus: initStatus ?? this.initStatus,
      animeListLoadingStatus: animeListLoadingStatus ?? this.animeListLoadingStatus,
      feedAnimeList: feedAnimeList ?? this.feedAnimeList,
      mostRecentAnimeList: mostRecentAnimeList ?? this.mostRecentAnimeList,
      topAnimeList: topAnimeList ?? this.topAnimeList,
      dayReleaseList: dayReleaseList ?? this.dayReleaseList,
      genreList: genreList ?? this.genreList,
      myAnimeMap: myAnimeMap ?? this.myAnimeMap,
      watchedEpisodeMap: watchedEpisodeMap ?? this.watchedEpisodeMap,
      latestEpisodes: latestEpisodes ?? this.latestEpisodes,
      mainAnimesPageCounter: mainAnimesPageCounter ?? this.mainAnimesPageCounter,
      maxMainAnimesPageNumber: maxMainAnimesPageNumber ?? this.maxMainAnimesPageNumber,
      appInfo: appInfo ?? this.appInfo,
    );
  }
}

/// State when app is initializing
class ApplicationInitializing extends ApplicationState {
  const ApplicationInitializing()
      : super(
          initStatus: AppInitStatus.initializing,
          animeListLoadingStatus: LoadingStatus.none,
          feedAnimeList: const [],
          mostRecentAnimeList: const [],
          topAnimeList: const [],
          dayReleaseList: const [],
          genreList: const [],
          myAnimeMap: const {},
          watchedEpisodeMap: const {},
          latestEpisodes: const [],
          mainAnimesPageCounter: 1,
          maxMainAnimesPageNumber: 1,
        );

  @override
  ApplicationState copyWith({
    AppInitStatus? initStatus,
    LoadingStatus? animeListLoadingStatus,
    List<AnimeModel>? feedAnimeList,
    List<AnimeModel>? mostRecentAnimeList,
    List<AnimeModel>? topAnimeList,
    List<AnimeModel>? dayReleaseList,
    List<String>? genreList,
    Map<String, AnimeModel>? myAnimeMap,
    Map<String, EpisodeWatched>? watchedEpisodeMap,
    List<EpisodeModel>? latestEpisodes,
    int? mainAnimesPageCounter,
    int? maxMainAnimesPageNumber,
    AppInfo? appInfo,
  }) {
    return ApplicationLoaded(
      initStatus: initStatus ?? this.initStatus,
      animeListLoadingStatus: animeListLoadingStatus ?? this.animeListLoadingStatus,
      feedAnimeList: feedAnimeList ?? this.feedAnimeList,
      mostRecentAnimeList: mostRecentAnimeList ?? this.mostRecentAnimeList,
      topAnimeList: topAnimeList ?? this.topAnimeList,
      dayReleaseList: dayReleaseList ?? this.dayReleaseList,
      genreList: genreList ?? this.genreList,
      myAnimeMap: myAnimeMap ?? this.myAnimeMap,
      watchedEpisodeMap: watchedEpisodeMap ?? this.watchedEpisodeMap,
      latestEpisodes: latestEpisodes ?? this.latestEpisodes,
      mainAnimesPageCounter: mainAnimesPageCounter ?? this.mainAnimesPageCounter,
      maxMainAnimesPageNumber: maxMainAnimesPageNumber ?? this.maxMainAnimesPageNumber,
      appInfo: appInfo ?? this.appInfo,
    );
  }
}

/// State when app initialization failed
class ApplicationInitError extends ApplicationState {
  final String? errorMessage;

  const ApplicationInitError({this.errorMessage})
      : super(
          initStatus: AppInitStatus.initError,
          animeListLoadingStatus: LoadingStatus.none,
          feedAnimeList: const [],
          mostRecentAnimeList: const [],
          topAnimeList: const [],
          dayReleaseList: const [],
          genreList: const [],
          myAnimeMap: const {},
          watchedEpisodeMap: const {},
          latestEpisodes: const [],
          mainAnimesPageCounter: 1,
          maxMainAnimesPageNumber: 1,
        );

  @override
  List<Object?> get props => [...super.props, errorMessage];

  @override
  ApplicationState copyWith({
    AppInitStatus? initStatus,
    LoadingStatus? animeListLoadingStatus,
    List<AnimeModel>? feedAnimeList,
    List<AnimeModel>? mostRecentAnimeList,
    List<AnimeModel>? topAnimeList,
    List<AnimeModel>? dayReleaseList,
    List<String>? genreList,
    Map<String, AnimeModel>? myAnimeMap,
    Map<String, EpisodeWatched>? watchedEpisodeMap,
    List<EpisodeModel>? latestEpisodes,
    int? mainAnimesPageCounter,
    int? maxMainAnimesPageNumber,
    AppInfo? appInfo,
  }) {
    return ApplicationLoaded(
      initStatus: initStatus ?? this.initStatus,
      animeListLoadingStatus: animeListLoadingStatus ?? this.animeListLoadingStatus,
      feedAnimeList: feedAnimeList ?? this.feedAnimeList,
      mostRecentAnimeList: mostRecentAnimeList ?? this.mostRecentAnimeList,
      topAnimeList: topAnimeList ?? this.topAnimeList,
      dayReleaseList: dayReleaseList ?? this.dayReleaseList,
      genreList: genreList ?? this.genreList,
      myAnimeMap: myAnimeMap ?? this.myAnimeMap,
      watchedEpisodeMap: watchedEpisodeMap ?? this.watchedEpisodeMap,
      latestEpisodes: latestEpisodes ?? this.latestEpisodes,
      mainAnimesPageCounter: mainAnimesPageCounter ?? this.mainAnimesPageCounter,
      maxMainAnimesPageNumber: maxMainAnimesPageNumber ?? this.maxMainAnimesPageNumber,
      appInfo: appInfo ?? this.appInfo,
    );
  }
}

/// Main state when app is initialized and loaded
class ApplicationLoaded extends ApplicationState {
  const ApplicationLoaded({
    required AppInitStatus initStatus,
    required LoadingStatus animeListLoadingStatus,
    required List<AnimeModel> feedAnimeList,
    required List<AnimeModel> mostRecentAnimeList,
    required List<AnimeModel> topAnimeList,
    required List<AnimeModel> dayReleaseList,
    required List<String> genreList,
    required Map<String, AnimeModel> myAnimeMap,
    required Map<String, EpisodeWatched> watchedEpisodeMap,
    required List<EpisodeModel> latestEpisodes,
    required int mainAnimesPageCounter,
    required int maxMainAnimesPageNumber,
    AppInfo? appInfo,
  }) : super(
          initStatus: initStatus,
          animeListLoadingStatus: animeListLoadingStatus,
          feedAnimeList: feedAnimeList,
          mostRecentAnimeList: mostRecentAnimeList,
          topAnimeList: topAnimeList,
          dayReleaseList: dayReleaseList,
          genreList: genreList,
          myAnimeMap: myAnimeMap,
          watchedEpisodeMap: watchedEpisodeMap,
          latestEpisodes: latestEpisodes,
          mainAnimesPageCounter: mainAnimesPageCounter,
          maxMainAnimesPageNumber: maxMainAnimesPageNumber,
          appInfo: appInfo,
        );

  @override
  ApplicationLoaded copyWith({
    AppInitStatus? initStatus,
    LoadingStatus? animeListLoadingStatus,
    List<AnimeModel>? feedAnimeList,
    List<AnimeModel>? mostRecentAnimeList,
    List<AnimeModel>? topAnimeList,
    List<AnimeModel>? dayReleaseList,
    List<String>? genreList,
    Map<String, AnimeModel>? myAnimeMap,
    Map<String, EpisodeWatched>? watchedEpisodeMap,
    List<EpisodeModel>? latestEpisodes,
    int? mainAnimesPageCounter,
    int? maxMainAnimesPageNumber,
    AppInfo? appInfo,
  }) {
    return ApplicationLoaded(
      initStatus: initStatus ?? this.initStatus,
      animeListLoadingStatus: animeListLoadingStatus ?? this.animeListLoadingStatus,
      feedAnimeList: feedAnimeList ?? this.feedAnimeList,
      mostRecentAnimeList: mostRecentAnimeList ?? this.mostRecentAnimeList,
      topAnimeList: topAnimeList ?? this.topAnimeList,
      dayReleaseList: dayReleaseList ?? this.dayReleaseList,
      genreList: genreList ?? this.genreList,
      myAnimeMap: myAnimeMap ?? this.myAnimeMap,
      watchedEpisodeMap: watchedEpisodeMap ?? this.watchedEpisodeMap,
      latestEpisodes: latestEpisodes ?? this.latestEpisodes,
      mainAnimesPageCounter: mainAnimesPageCounter ?? this.mainAnimesPageCounter,
      maxMainAnimesPageNumber: maxMainAnimesPageNumber ?? this.maxMainAnimesPageNumber,
      appInfo: appInfo ?? this.appInfo,
    );
  }
}
