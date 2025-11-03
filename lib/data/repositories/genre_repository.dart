import 'package:anime_app/data/repositories/jikan_repository.dart';
import 'package:anime_app/models/genre_model.dart';
import 'package:anime_app/models/anime_model.dart';

/// Repository responsible for genre-related operations
/// Now uses Jikan API for genre and anime filtering
class GenreRepository {
  final JikanRepository _jikanRepository;

  GenreRepository({JikanRepository? jikanRepository})
      : _jikanRepository = jikanRepository ?? JikanRepository();

  /// Get all available genres from MyAnimeList
  Future<List<GenreModel>> getGenresAvailable() async {
    try {
      return await _jikanRepository.getGenres();
    } catch (e) {
      throw Exception('Failed to load genres: $e');
    }
  }

  /// Get anime by genre ID
  Future<List<AnimeModel>> getAnimeByGenre(
    int genreId, {
    int page = 1,
  }) async {
    try {
      return await _jikanRepository.getAnimeByGenre(genreId, page: page);
    } catch (e) {
      throw Exception('Failed to get anime by genre: $e');
    }
  }

  /// Search for anime with a query string
  /// Use this for genre-based searches as well
  Future<List<AnimeModel>> search(String query, {int page = 1}) async {
    try {
      final result = await _jikanRepository.search(query, page: page);
      return result.results;
    } catch (e) {
      throw Exception('Failed to search anime: $e');
    }
  }
}
