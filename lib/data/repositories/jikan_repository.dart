import 'package:anime_app/models/anime_model.dart';
import 'package:anime_app/models/episode_model.dart';
import 'package:anime_app/models/genre_model.dart';
import 'package:anime_app/models/search_result_model.dart';
import 'package:anime_app/models/converters/jikan_converter.dart';
import 'package:jikan_api/jikan_api.dart' as jikan;

/// Repository for Jikan API (MyAnimeList metadata)
///
/// Provides access to anime metadata from MyAnimeList via the Jikan API.
/// Does NOT provide video streaming URLs - use ConsumetRepository for that.
///
/// Capabilities:
/// - Search anime
/// - Get anime details with episodes
/// - Get recommendations
/// - Get seasonal anime
/// - Get top rankings
/// - Get genres
class JikanRepository {
  final jikan.Jikan _jikan;

  JikanRepository({jikan.Jikan? jikanInstance})
      : _jikan = jikanInstance ?? jikan.Jikan();

  /// Search anime on MyAnimeList
  ///
  /// Returns a SearchResultModel with anime matching the query.
  /// Note: Results are limited by Jikan API (default 25 per page)
  Future<SearchResultModel> search(
    String query, {
    int page = 1,
  }) async {
    try {
      final results = await _jikan.searchAnime(
        query: query.isEmpty ? null : query,
        page: page,
      );

      final animeList = JikanConverter.fromAnimeList(results);

      return SearchResultModel(
        query: query,
        results: animeList,
        currentPage: page,
        hasNextPage: results.length >= 25, // Jikan returns 25 per page
        timestamp: DateTime.now(),
      );
    } catch (e) {
      return SearchResultModel.error(query, 'Failed to search anime: $e');
    }
  }

  /// Get anime details by MyAnimeList ID
  ///
  /// Returns full AnimeModel including synopsis, genres, etc.
  /// This is more comprehensive than the search results.
  Future<AnimeModel> getAnimeDetails(int malId) async {
    try {
      final anime = await _jikan.getAnime(malId);
      return JikanConverter.fromAnime(anime);
    } catch (e) {
      throw Exception('Failed to get anime details: $e');
    }
  }

  /// Get episodes for an anime
  ///
  /// Returns a list of EpisodeModel for the specified anime.
  /// May be paginated - fetches all available episodes.
  Future<List<EpisodeModel>> getEpisodes(int malId) async {
    try {
      final animeId = malId.toString();
      final List<jikan.Episode> allEpisodes = [];
      int currentPage = 1;
      bool hasNextPage = true;

      while (hasNextPage && currentPage <= 10) {
        // Limit to 10 pages max
        try {
          final episodesPage = await _jikan.getAnimeEpisodes(
            malId,
            page: currentPage,
          );

          if (episodesPage.isEmpty) {
            hasNextPage = false;
          } else {
            allEpisodes.addAll(episodesPage);
            currentPage++;
          }
        } catch (e) {
          // No more episodes or error
          hasNextPage = false;
        }
      }

      return JikanConverter.fromEpisodeList(allEpisodes, animeId);
    } catch (e) {
      throw Exception('Failed to get episodes: $e');
    }
  }

  /// Get anime recommendations by MAL ID
  ///
  /// Returns a list of related/similar anime that users might like.
  Future<List<AnimeModel>> getRecommendations(int malId) async {
    try {
      final recommendations = await _jikan.getAnimeRecommendations(malId);

      // Convert EntryMeta to AnimeModel (limited info from recommendations)
      return recommendations
          .map((rec) => AnimeModel(
                id: rec.entry.malId.toString(),
                title: rec.entry.title,
                imageUrl: rec.entry.url, // EntryMeta doesn't have images, using URL
                sourceIds: SourceIds(malId: rec.entry.malId.toString()),
              ))
          .take(10) // Limit to 10 recommendations
          .toList();
    } catch (e) {
      // Return empty list if recommendations fail (not critical)
      return [];
    }
  }

  /// Get current season anime
  ///
  /// Returns anime airing in the current season.
  Future<List<AnimeModel>> getCurrentSeasonAnime({int page = 1}) async {
    try {
      // getSeason with no parameters returns current season
      final seasonAnime = await _jikan.getSeason(page: page);
      return JikanConverter.fromAnimeList(seasonAnime);
    } catch (e) {
      throw Exception('Failed to get seasonal anime: $e');
    }
  }

  /// Get top anime by rating
  ///
  /// Returns the highest-rated anime on MyAnimeList.
  Future<List<AnimeModel>> getTopAnime({int page = 1}) async {
    try {
      final topAnime = await _jikan.getTopAnime(page: page);
      return JikanConverter.fromAnimeList(topAnime);
    } catch (e) {
      throw Exception('Failed to get top anime: $e');
    }
  }

  /// Get anime by genre
  ///
  /// Returns anime matching the specified genre.
  /// Note: This uses search with genre filter since there's no direct genre endpoint
  Future<List<AnimeModel>> getAnimeByGenre(
    int genreId, {
    int page = 1,
  }) async {
    try {
      final animeList = await _jikan.searchAnime(
        genres: [genreId],
        page: page,
      );

      return JikanConverter.fromAnimeList(animeList);
    } catch (e) {
      throw Exception('Failed to get anime by genre: $e');
    }
  }

  /// Get all available genres
  ///
  /// Returns a list of anime genres from MyAnimeList.
  /// Note: Jikan v4 API doesn't have a direct genres endpoint
  /// This returns a predefined list of common MAL genres
  Future<List<GenreModel>> getGenres() async {
    // Return common MAL genre IDs
    // Since Jikan v4 doesn't have a genres endpoint, we provide common ones
    return [
      GenreModel(
          id: '1',
          name: 'Action',
          sourceIds: GenreSourceIds(malId: '1')),
      GenreModel(
          id: '2',
          name: 'Adventure',
          sourceIds: GenreSourceIds(malId: '2')),
      GenreModel(
          id: '4',
          name: 'Comedy',
          sourceIds: GenreSourceIds(malId: '4')),
      GenreModel(
          id: '8',
          name: 'Drama',
          sourceIds: GenreSourceIds(malId: '8')),
      GenreModel(
          id: '10',
          name: 'Fantasy',
          sourceIds: GenreSourceIds(malId: '10')),
      GenreModel(
          id: '14',
          name: 'Horror',
          sourceIds: GenreSourceIds(malId: '14')),
      GenreModel(
          id: '7',
          name: 'Mystery',
          sourceIds: GenreSourceIds(malId: '7')),
      GenreModel(
          id: '22',
          name: 'Romance',
          sourceIds: GenreSourceIds(malId: '22')),
      GenreModel(
          id: '24',
          name: 'Sci-Fi',
          sourceIds: GenreSourceIds(malId: '24')),
      GenreModel(
          id: '36',
          name: 'Slice of Life',
          sourceIds: GenreSourceIds(malId: '36')),
      GenreModel(
          id: '30',
          name: 'Sports',
          sourceIds: GenreSourceIds(malId: '30')),
      GenreModel(
          id: '37',
          name: 'Supernatural',
          sourceIds: GenreSourceIds(malId: '37')),
      GenreModel(
          id: '41',
          name: 'Thriller',
          sourceIds: GenreSourceIds(malId: '41')),
    ];
  }

  /// Get anime by multiple genres
  ///
  /// Helper method to search by multiple genre IDs
  Future<List<AnimeModel>> getAnimeByGenres(
    List<int> genreIds, {
    int page = 1,
  }) async {
    try {
      if (genreIds.isEmpty) {
        return [];
      }

      final animeList = await _jikan.searchAnime(
        genres: genreIds,
        page: page,
      );

      return JikanConverter.fromAnimeList(animeList);
    } catch (e) {
      throw Exception('Failed to get anime by genres: $e');
    }
  }

  /// Search anime with advanced filters
  ///
  /// Supports filtering by type, status, rating, genres, etc.
  Future<SearchResultModel> searchAdvanced({
    required String query,
    String? type, // tv, movie, ova, special, ona
    String? status, // airing, complete, upcoming
    double? minScore,
    List<int>? genreIds,
    int page = 1,
  }) async {
    try {
      // Map type string to AnimeType enum
      jikan.AnimeType? animeType;
      if (type != null) {
        switch (type.toLowerCase()) {
          case 'tv':
            animeType = jikan.AnimeType.tv;
            break;
          case 'movie':
            animeType = jikan.AnimeType.movie;
            break;
          case 'ova':
            animeType = jikan.AnimeType.ova;
            break;
          case 'special':
            animeType = jikan.AnimeType.special;
            break;
          case 'ona':
            animeType = jikan.AnimeType.ona;
            break;
        }
      }

      final results = await _jikan.searchAnime(
        query: query,
        type: animeType,
        genres: genreIds,
        page: page,
      );

      var animeList = JikanConverter.fromAnimeList(results);

      // Client-side filtering for status and minScore
      if (status != null) {
        animeList = animeList
            .where(
                (anime) => anime.status?.toLowerCase() == status.toLowerCase())
            .toList();
      }

      if (minScore != null) {
        animeList = animeList
            .where((anime) => (anime.rating ?? 0.0) >= minScore)
            .toList();
      }

      return SearchResultModel(
        query: query,
        results: animeList,
        currentPage: page,
        hasNextPage: results.length >= 25,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      return SearchResultModel.error(query, 'Failed to search anime: $e');
    }
  }

  /// Check if Jikan API is available
  ///
  /// Performs a simple health check by trying to get top anime.
  Future<bool> isAvailable() async {
    try {
      await _jikan.getTopAnime(page: 1);
      return true;
    } catch (e) {
      return false;
    }
  }
}
