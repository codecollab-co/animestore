import 'package:anime_app/data/repositories/anime_repository.dart';
import 'package:anime_app/data/repositories/user_repository.dart';
import 'package:anime_app/logic/blocs/application/application_event.dart';
import 'package:anime_app/logic/blocs/application/application_state.dart';
import 'package:anime_app/model/AppInfo.dart';
import 'package:anime_app/model/EpisodeWatched.dart' as model;
import 'package:anime_app/models/anime_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info/package_info.dart';

/// ApplicationBloc manages the main application state
/// Handles initialization, anime lists, user data, and watched episodes
class ApplicationBloc extends Bloc<ApplicationEvent, ApplicationState> {
  final AnimeRepository _animeRepository;
  final UserRepository _userRepository;

  static const int defaultPagesLoading = 4;

  ApplicationBloc({
    required AnimeRepository animeRepository,
    required UserRepository userRepository,
  })  : _animeRepository = animeRepository,
        _userRepository = userRepository,
        super(const ApplicationInitial()) {
    on<AppInitializeRequested>(_onAppInitializeRequested);
    on<AppRetryRequested>(_onAppRetryRequested);
    on<AnimeListLoadRequested>(_onAnimeListLoadRequested);
    on<HomePageInfoLoadRequested>(_onHomePageInfoLoadRequested);
    on<HomePageRefreshRequested>(_onHomePageRefreshRequested);
    on<GenresLoadRequested>(_onGenresLoadRequested);
    on<MyAnimeAdded>(_onMyAnimeAdded);
    on<MyAnimeRemoved>(_onMyAnimeRemoved);
    on<MyAnimeListCleared>(_onMyAnimeListCleared);
    on<EpisodeWatched>(_onEpisodeWatched);
    on<EpisodeUnwatched>(_onEpisodeUnwatched);
    on<WatchedEpisodesCleared>(_onWatchedEpisodesCleared);
  }

  /// Initialize the application
  Future<void> _onAppInitializeRequested(
    AppInitializeRequested event,
    Emitter<ApplicationState> emit,
  ) async {
    if (state.initStatus == AppInitStatus.initialized) return;

    emit(const ApplicationInitializing());

    try {
      // Initialize database
      await _userRepository.initialize();

      // Get app info
      final appInfo = await _getAppInfo();

      // Load data from network and database
      await _initDataFromNetwork(emit, appInfo);

      emit(state.copyWith(
        initStatus: AppInitStatus.initialized,
        appInfo: appInfo,
      ));
    } catch (e) {
      print('ApplicationBloc::_onAppInitializeRequested Error: $e');
      emit(ApplicationInitError(errorMessage: e.toString()));
    }
  }

  /// Retry initialization after error
  Future<void> _onAppRetryRequested(
    AppRetryRequested event,
    Emitter<ApplicationState> emit,
  ) async {
    if (state.initStatus != AppInitStatus.initError) return;

    emit(const ApplicationInitializing());

    try {
      final appInfo = await _getAppInfo();
      await _initDataFromNetwork(emit, appInfo);

      emit(state.copyWith(
        initStatus: AppInitStatus.initialized,
        appInfo: appInfo,
      ));
    } catch (e) {
      print('ApplicationBloc::_onAppRetryRequested Error: $e');
      emit(ApplicationInitError(errorMessage: e.toString()));
    }
  }

  /// Load initial data from network and database
  Future<void> _initDataFromNetwork(
    Emitter<ApplicationState> emit,
    AppInfo appInfo,
  ) async {
    // Load user's anime list from database
    final myAnimeMap = await _userRepository.loadMyAnimeList();
    emit(state.copyWith(myAnimeMap: myAnimeMap, appInfo: appInfo));

    // Load watched episodes from database
    final watchedEpisodesList = await _userRepository.loadWatchedEpisodes();
    final watchedEpisodeMap = <String, model.EpisodeWatched>{};
    for (var ep in watchedEpisodesList) {
      watchedEpisodeMap[ep.id] = ep;
    }
    emit(state.copyWith(watchedEpisodeMap: watchedEpisodeMap));

    // Load home page data
    final homePageData = await _animeRepository.getHomePageData();
    emit(state.copyWith(
      mostRecentAnimeList: homePageData.currentlyAiring,
      topAnimeList: homePageData.topRated,
      // TODO: latestEpisodes needs to be fetched separately or restructured
      latestEpisodes: const [],
      dayReleaseList: homePageData.popularThisSeason,
    ));

    // Load anime list with pagination
    await _loadAnimeListInternal(emit);

    // Load available genres
    final genres = await _animeRepository.getGenresAvailable();
    emit(state.copyWith(
      genreList: genres.map((g) => g.name).toList(),
    ));
  }

  /// Load more anime in the main feed list
  Future<void> _onAnimeListLoadRequested(
    AnimeListLoadRequested event,
    Emitter<ApplicationState> emit,
  ) async {
    await _loadAnimeListInternal(emit);
  }

  /// Internal method to load anime list with pagination
  Future<void> _loadAnimeListInternal(
    Emitter<ApplicationState> emit,
  ) async {
    if (state.animeListLoadingStatus == LoadingStatus.loading) return;

    final cacheList = <AnimeModel>[];

    if (state.mainAnimesPageCounter <= state.maxMainAnimesPageNumber) {
      emit(state.copyWith(animeListLoadingStatus: LoadingStatus.loading));

      var pageCounter = state.mainAnimesPageCounter;
      var maxPageNumber = state.maxMainAnimesPageNumber;

      for (int i = 0; i < defaultPagesLoading; i++) {
        try {
          final data = await _animeRepository.getAnimeListPage(
            pageNumber: pageCounter,
          );

          cacheList.addAll(data);
          // Jikan API has many pages, using reasonable default
          maxPageNumber = 100;
          pageCounter++;
        } catch (ex) {
          print('Fail loading page number $pageCounter: $ex');
          pageCounter++;
        }
      }

      emit(state.copyWith(
        feedAnimeList: [...state.feedAnimeList, ...cacheList],
        mainAnimesPageCounter: pageCounter,
        maxMainAnimesPageNumber: maxPageNumber,
        animeListLoadingStatus: LoadingStatus.done,
      ));
    }
  }

  /// Load home page data
  Future<void> _onHomePageInfoLoadRequested(
    HomePageInfoLoadRequested event,
    Emitter<ApplicationState> emit,
  ) async {
    try {
      final homePageData = await _animeRepository.getHomePageData();
      emit(state.copyWith(
        mostRecentAnimeList: homePageData.currentlyAiring,
        topAnimeList: homePageData.topRated,
        latestEpisodes: const [],
        dayReleaseList: homePageData.popularThisSeason,
      ));
    } catch (e) {
      print('ApplicationBloc::_onHomePageInfoLoadRequested Error: $e');
    }
  }

  /// Refresh home page data
  Future<void> _onHomePageRefreshRequested(
    HomePageRefreshRequested event,
    Emitter<ApplicationState> emit,
  ) async {
    try {
      final homePageData = await _animeRepository.getHomePageData();
      emit(state.copyWith(
        mostRecentAnimeList: homePageData.currentlyAiring,
        topAnimeList: homePageData.topRated,
        latestEpisodes: const [],
        dayReleaseList: homePageData.popularThisSeason,
      ));

      final genres = await _animeRepository.getGenresAvailable();
      emit(state.copyWith(
        genreList: genres.map((g) => g.name).toList(),
      ));
    } catch (e) {
      print('ApplicationBloc::_onHomePageRefreshRequested Error: $e');
    }
  }

  /// Load available genres
  Future<void> _onGenresLoadRequested(
    GenresLoadRequested event,
    Emitter<ApplicationState> emit,
  ) async {
    try {
      final genres = await _animeRepository.getGenresAvailable();
      emit(state.copyWith(
        genreList: genres.map((g) => g.name).toList(),
      ));
    } catch (e) {
      print('ApplicationBloc::_onGenresLoadRequested Error: $e');
    }
  }

  /// Add anime to user's list
  Future<void> _onMyAnimeAdded(
    MyAnimeAdded event,
    Emitter<ApplicationState> emit,
  ) async {
    if (!state.myAnimeMap.containsKey(event.animeId)) {
      final updatedMap = Map<String, AnimeModel>.from(state.myAnimeMap);
      updatedMap[event.animeId] = event.anime;

      emit(state.copyWith(myAnimeMap: updatedMap));

      // Persist to database
      await _userRepository.addAnimeToList(event.animeId, event.anime);
    }
  }

  /// Remove anime from user's list
  Future<void> _onMyAnimeRemoved(
    MyAnimeRemoved event,
    Emitter<ApplicationState> emit,
  ) async {
    if (state.myAnimeMap.containsKey(event.animeId)) {
      final updatedMap = Map<String, AnimeModel>.from(state.myAnimeMap);
      updatedMap.remove(event.animeId);

      final updatedWatchedMap =
          Map<String, model.EpisodeWatched>.from(state.watchedEpisodeMap);
      updatedWatchedMap.remove(event.animeId);

      emit(state.copyWith(
        myAnimeMap: updatedMap,
        watchedEpisodeMap: updatedWatchedMap,
      ));

      // Persist to database
      await _userRepository.removeAnimeFromList(event.animeId);
    }
  }

  /// Clear all anime from user's list
  Future<void> _onMyAnimeListCleared(
    MyAnimeListCleared event,
    Emitter<ApplicationState> emit,
  ) async {
    emit(state.copyWith(myAnimeMap: const {}));
    await _userRepository.clearAllMyList();
  }

  /// Mark an episode as watched
  Future<void> _onEpisodeWatched(
    EpisodeWatched event,
    Emitter<ApplicationState> emit,
  ) async {
    if (!state.watchedEpisodeMap.containsKey(event.episodeId)) {
      final episode = model.EpisodeWatched(
        id: event.episodeId,
        title: event.episodeTitle,
        viewedAt: event.viewedAt,
      );

      final updatedMap = Map<String, model.EpisodeWatched>.from(state.watchedEpisodeMap);
      updatedMap[event.episodeId] = episode;

      emit(state.copyWith(watchedEpisodeMap: updatedMap));

      // Persist to database
      await _userRepository.addWatchedEpisode(episode);
    }
  }

  /// Remove an episode from watched list
  Future<void> _onEpisodeUnwatched(
    EpisodeUnwatched event,
    Emitter<ApplicationState> emit,
  ) async {
    if (state.watchedEpisodeMap.containsKey(event.episodeId)) {
      final updatedMap = Map<String, model.EpisodeWatched>.from(state.watchedEpisodeMap);
      updatedMap.remove(event.episodeId);

      emit(state.copyWith(watchedEpisodeMap: updatedMap));

      // Persist to database
      await _userRepository.removeWatchedEpisode(event.episodeId);
    }
  }

  /// Clear all watched episodes
  Future<void> _onWatchedEpisodesCleared(
    WatchedEpisodesCleared event,
    Emitter<ApplicationState> emit,
  ) async {
    emit(state.copyWith(watchedEpisodeMap: const {}));
    await _userRepository.clearWatchedEpisodes();
  }

  /// Get app information
  Future<AppInfo> _getAppInfo() async {
    try {
      final info = await PackageInfo.fromPlatform();
      return AppInfo(
        appName: info.appName,
        buildNumber: info.buildNumber,
        version: info.version,
      );
    } catch (ex) {
      print('ApplicationBloc::_getAppInfo Error: $ex');
      return AppInfo(
        appName: 'AnimeApp',
        buildNumber: '0',
        version: '0.0.0',
      );
    }
  }

  /// Get anime details (convenience method for UI)
  Future<AnimeModel> getAnimeDetails(String animeId) async {
    return await _animeRepository.getAnimeDetails(animeId);
  }
}
