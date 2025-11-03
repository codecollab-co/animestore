import 'package:anime_app/data/repositories/jikan_repository.dart';
import 'package:anime_app/data/repositories/consumet_repository.dart';
import 'package:anime_app/models/anime_model.dart';
import 'package:anime_app/models/episode_model.dart';
import 'package:anime_app/models/genre_model.dart';
import 'package:anime_app/models/home_page_model.dart';
import 'package:anime_app/models/search_result_model.dart';
import 'package:dio/dio.dart';

/// Repository responsible for all anime-related data operations
///
/// Now uses Jikan API (MyAnimeList metadata) + Consumet API (streaming)
/// instead of the deprecated AniTube API.
class AnimeRepository {
  final JikanRepository _jikanRepository;
  final ConsumetRepository _consumetRepository;

  AnimeRepository({
    JikanRepository? jikanRepository,
    ConsumetRepository? consumetRepository,
  })  : _jikanRepository = jikanRepository ?? JikanRepository(),
        _consumetRepository = consumetRepository ?? ConsumetRepository(Dio());

  /// Fetch paginated anime list data
  ///
  /// Uses Jikan's top anime endpoint for main feed
  Future<List<AnimeModel>> getAnimeListPage({required int pageNumber}) async {
    try {
      return await _jikanRepository.getTopAnime(page: pageNumber);
    } catch (e) {
      throw Exception('Failed to load anime list: $e');
    }
  }

  /// Fetch home page data (carousel, trending, recent episodes)
  ///
  /// Aggregates data from both Jikan and Consumet:
  /// - Currently airing from Jikan
  /// - Top rated from Jikan
  /// - Recent episodes from Consumet
  /// - Popular this season from Jikan
  Future<HomePageModel> getHomePageData() async {
    try {
      // Fetch data in parallel for better performance
      final results = await Future.wait([
        _jikanRepository.getCurrentSeasonAnime(page: 1), // Currently airing
        _jikanRepository.getTopAnime(page: 1), // Top rated
        _consumetRepository.getRecentEpisodes(page: 1), // Recent episodes
        _jikanRepository.getCurrentSeasonAnime(page: 1), // Popular this season
      ]);

      return HomePageModel(
        currentlyAiring: results[0] as List<AnimeModel>,
        topRated: results[1] as List<AnimeModel>,
        recentlyUpdated: results[2] as List<AnimeModel>,
        popularThisSeason: results[3] as List<AnimeModel>,
        lastRefreshed: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Failed to load home page data: $e');
    }
  }

  /// Fetch detailed information about a specific anime
  ///
  /// Returns anime details from Jikan (MyAnimeList)
  Future<AnimeModel> getAnimeDetails(String animeId) async {
    try {
      final malId = int.parse(animeId);
      return await _jikanRepository.getAnimeDetails(malId);
    } catch (e) {
      throw Exception('Failed to load anime details: $e');
    }
  }

  /// Fetch episodes for a specific anime
  ///
  /// Gets episode list from Jikan with metadata
  Future<List<EpisodeModel>> getAnimeEpisodes(String animeId) async {
    try {
      final malId = int.parse(animeId);
      return await _jikanRepository.getEpisodes(malId);
    } catch (e) {
      throw Exception('Failed to load anime episodes: $e');
    }
  }

  /// Get episode streaming details
  ///
  /// Uses Consumet to get video streaming URLs and qualities
  /// Requires the anime title and episode number
  Future<EpisodeModel> getEpisodeStreamingDetails({
    required String animeTitle,
    required int episodeNumber,
  }) async {
    try {
      // Search for anime on Consumet
      final searchResult = await _consumetRepository.search(animeTitle);

      if (searchResult.results.isEmpty) {
        throw Exception('Anime not found on streaming service');
      }

      final anime = searchResult.results.first;

      // Get episodes for the anime
      final episodes = await _consumetRepository.getEpisodes(anime.id);

      // Find the specific episode
      final episode = episodes.firstWhere(
        (ep) => ep.number == episodeNumber,
        orElse: () => throw Exception('Episode $episodeNumber not found'),
      );

      // Get streaming links
      return await _consumetRepository.getEpisodeStreamingLinks(
        episode.id,
        anime.id,
        episodeNumber,
      );
    } catch (e) {
      throw Exception('Failed to load episode streaming details: $e');
    }
  }

  /// Search for anime with a query string
  ///
  /// Uses Jikan search for metadata
  Future<SearchResultModel> search(String query, {int page = 1}) async {
    try {
      return await _jikanRepository.search(query, page: page);
    } catch (e) {
      throw Exception('Failed to search anime: $e');
    }
  }

  /// Get available genres
  ///
  /// Returns list of MAL genres from Jikan
  Future<List<GenreModel>> getGenresAvailable() async {
    try {
      return await _jikanRepository.getGenres();
    } catch (e) {
      throw Exception('Failed to load genres: $e');
    }
  }

  /// Get anime by genre
  ///
  /// Fetches anime filtered by specific genre
  Future<List<AnimeModel>> getAnimeByGenre(int genreId, {int page = 1}) async {
    try {
      return await _jikanRepository.getAnimeByGenre(genreId, page: page);
    } catch (e) {
      throw Exception('Failed to load anime by genre: $e');
    }
  }

  /// Get recommendations for an anime
  ///
  /// Returns similar/related anime from MyAnimeList
  Future<List<AnimeModel>> getRecommendations(int malId) async {
    try {
      return await _jikanRepository.getRecommendations(malId);
    } catch (e) {
      throw Exception('Failed to load recommendations: $e');
    }
  }

  /// Check if services are available
  ///
  /// Tests connectivity to both Jikan and Consumet
  Future<Map<String, bool>> checkServiceAvailability() async {
    final results = await Future.wait([
      _jikanRepository.isAvailable(),
      _consumetRepository.isAvailable(),
    ]);

    return {
      'jikan': results[0],
      'consumet': results[1],
    };
  }
}
