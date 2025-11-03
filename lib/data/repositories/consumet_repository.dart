import 'package:dio/dio.dart';
import 'package:anime_app/config/api_config.dart';
import 'package:anime_app/models/anime_model.dart';
import 'package:anime_app/models/episode_model.dart';
import 'package:anime_app/models/search_result_model.dart';
import 'package:anime_app/models/converters/consumet_converter.dart';

/// Repository for Consumet API (Video streaming)
///
/// Provides access to anime video streaming from multiple providers.
/// Requires a deployed Consumet instance (see CONSUMET_DEPLOYMENT_GUIDE.md)
///
/// Capabilities:
/// - Search anime on GogoAnime, Zoro, 9anime, etc.
/// - Get episode streaming links
/// - Get multiple quality options
/// - Get recent episodes
/// - Get top airing anime
///
/// Note: This repository ONLY handles video streaming URLs.
/// Use JikanRepository for metadata (descriptions, ratings, etc.)
class ConsumetRepository {
  final Dio _dio;
  final String _baseUrl;
  final String _provider;

  ConsumetRepository(
    this._dio, {
    String? baseUrl,
    String provider = ApiConfig.defaultProvider,
  })  : _baseUrl = baseUrl ?? ApiConfig.consumetBaseUrl,
        _provider = provider {
    // Configure Dio
    _dio.options.baseUrl = _baseUrl;
    _dio.options.connectTimeout = ApiConfig.connectTimeout;
    _dio.options.receiveTimeout = ApiConfig.receiveTimeout;
    _dio.options.headers = ApiConfig.consumetHeaders();
  }

  /// Search anime on the configured provider
  ///
  /// Returns a SearchResultModel with anime matching the query.
  /// Each result includes an ID that can be used to get episode info.
  Future<SearchResultModel> search(String query) async {
    try {
      final response = await _dio.get(
        '/anime/$_provider/$query',
      );

      if (response.data == null) {
        return SearchResultModel(
          query: query,
          timestamp: DateTime.now(),
        );
      }

      final results = response.data['results'] as List? ?? [];
      final animeList = ConsumetConverter.fromSearchResults(results);

      return SearchResultModel(
        query: query,
        results: animeList,
        currentPage: 1,
        hasNextPage: false, // Consumet doesn't paginate search
        timestamp: DateTime.now(),
      );
    } catch (e) {
      return SearchResultModel.error(query, 'Failed to search anime on $_provider: $e');
    }
  }

  /// Get anime info including episode list
  ///
  /// Returns detailed AnimeModel with all available episodes.
  /// Use this to get episode IDs before requesting streaming links.
  Future<AnimeModel> getAnimeInfo(String animeId) async {
    try {
      final response = await _dio.get(
        '/anime/$_provider/info/$animeId',
      );

      if (response.data == null) {
        throw Exception('No data returned for anime: $animeId');
      }

      return ConsumetConverter.fromAnimeInfo(response.data);
    } catch (e) {
      throw Exception('Failed to get anime info: $e');
    }
  }

  /// Get episodes for an anime
  ///
  /// Returns a list of EpisodeModel for the specified anime.
  Future<List<EpisodeModel>> getEpisodes(String animeId) async {
    try {
      final response = await _dio.get(
        '/anime/$_provider/info/$animeId',
      );

      if (response.data == null) {
        throw Exception('No data returned for anime: $animeId');
      }

      final episodes = response.data['episodes'] as List? ?? [];
      return ConsumetConverter.fromEpisodeList(episodes, animeId);
    } catch (e) {
      throw Exception('Failed to get episodes: $e');
    }
  }

  /// Get episode streaming links
  ///
  /// Returns EpisodeModel with StreamingInfo containing URLs, qualities, and subtitles.
  ///
  /// [episodeId] - The episode ID from getAnimeInfo()
  /// [animeId] - The anime ID
  /// [episodeNumber] - The episode number
  /// [server] - Video server to use (default: gogocdn)
  Future<EpisodeModel> getEpisodeStreamingLinks(
    String episodeId,
    String animeId,
    int episodeNumber, {
    String? server,
  }) async {
    try {
      final serverName = server ?? ApiConfig.defaultServer;

      final response = await _dio.get(
        '/anime/$_provider/watch/$episodeId',
        queryParameters: {'server': serverName},
      );

      if (response.data == null) {
        throw Exception('No streaming data for episode: $episodeId');
      }

      return ConsumetConverter.fromStreamingData(
        response.data,
        episodeId,
        animeId,
        episodeNumber,
      );
    } catch (e) {
      throw Exception('Failed to get streaming links: $e');
    }
  }

  /// Get episode streaming URL (simplified)
  ///
  /// Returns just the video URL without additional metadata.
  /// Automatically selects the best quality available.
  Future<String> getEpisodeStreamUrl(
    String episodeId,
    String animeId,
    int episodeNumber,
  ) async {
    try {
      final episodeModel = await getEpisodeStreamingLinks(
        episodeId,
        animeId,
        episodeNumber,
      );

      if (episodeModel.streamingInfo == null ||
          episodeModel.streamingInfo!.videoUrl == null) {
        throw Exception('No video URL available');
      }

      return episodeModel.streamingInfo!.videoUrl!;
    } catch (e) {
      throw Exception('Failed to get stream URL: $e');
    }
  }

  /// Get recent episodes
  ///
  /// Returns recently released episodes on the provider.
  /// Useful for displaying "Latest Releases" section.
  Future<List<AnimeModel>> getRecentEpisodes({
    int page = 1,
    String type = 'sub', // sub or dub
  }) async {
    try {
      final response = await _dio.get(
        '/anime/$_provider/recent-episodes',
        queryParameters: {
          'page': page,
          'type': type,
        },
      );

      if (response.data == null) {
        return [];
      }

      final results = response.data['results'] as List? ?? [];
      return ConsumetConverter.fromSearchResults(results);
    } catch (e) {
      // Return empty list instead of throwing (not critical)
      return [];
    }
  }

  /// Get top airing anime
  ///
  /// Returns currently airing anime sorted by popularity.
  Future<List<AnimeModel>> getTopAiring({int page = 1}) async {
    try {
      final response = await _dio.get(
        '/anime/$_provider/top-airing',
        queryParameters: {'page': page},
      );

      if (response.data == null) {
        return [];
      }

      final results = response.data['results'] as List? ?? [];
      return ConsumetConverter.fromSearchResults(results);
    } catch (e) {
      return [];
    }
  }

  /// Search anime by title and get episode streaming URL
  ///
  /// Convenience method that combines search + info + streaming.
  /// Useful when you have anime title and episode number from Jikan.
  ///
  /// [animeTitle] - Name of the anime
  /// [episodeNumber] - Episode number to get
  Future<String> getStreamUrlByTitle({
    required String animeTitle,
    required int episodeNumber,
  }) async {
    try {
      // Step 1: Search for anime
      final searchResult = await search(animeTitle);

      if (searchResult.results.isEmpty) {
        throw Exception('Anime not found: $animeTitle');
      }

      // Take first result (best match)
      final anime = searchResult.results.first;
      final animeId = anime.id;

      // Step 2: Get anime info to find episode ID
      final episodes = await getEpisodes(animeId);

      // Find episode by number
      final episode = episodes.firstWhere(
        (ep) => ep.number == episodeNumber,
        orElse: () => throw Exception('Episode $episodeNumber not found'),
      );

      // Step 3: Get streaming URL
      return await getEpisodeStreamUrl(episode.id, animeId, episodeNumber);
    } catch (e) {
      throw Exception(
          'Failed to get stream URL for $animeTitle ep $episodeNumber: $e');
    }
  }

  /// Get available video qualities for an episode
  ///
  /// Returns list of quality options (e.g., ["1080p", "720p", "480p"]).
  Future<List<String>> getAvailableQualities(
    String episodeId,
    String animeId,
    int episodeNumber,
  ) async {
    try {
      final episodeModel = await getEpisodeStreamingLinks(
        episodeId,
        animeId,
        episodeNumber,
      );

      return episodeModel.streamingInfo?.qualities
              .map((q) => q.quality)
              .toList() ??
          [];
    } catch (e) {
      return [];
    }
  }

  /// Switch video provider
  ///
  /// Creates a new repository instance with a different provider.
  /// Useful for fallback when primary provider fails.
  ConsumetRepository withProvider(String provider) {
    return ConsumetRepository(
      _dio,
      baseUrl: _baseUrl,
      provider: provider,
    );
  }

  /// Check if Consumet API is available
  ///
  /// Performs a health check by trying to get recent episodes.
  Future<bool> isAvailable() async {
    try {
      await _dio.get('/anime/$_provider/recent-episodes?page=1');
      return true;
    } catch (e) {
      return false;
    }
  }
}
