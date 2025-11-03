import 'package:anime_app/data/repositories/jikan_repository.dart';
import 'package:anime_app/models/search_result_model.dart';

/// Repository responsible for search operations
/// Now uses Jikan API for search functionality
class SearchRepository {
  final JikanRepository _jikanRepository;

  SearchRepository({JikanRepository? jikanRepository})
      : _jikanRepository = jikanRepository ?? JikanRepository();

  /// Search for anime
  /// Uses Jikan's search endpoint with pagination
  Future<SearchResultModel> search(String query, {int page = 1}) async {
    try {
      return await _jikanRepository.search(query, page: page);
    } catch (e) {
      throw Exception('Failed to search anime: $e');
    }
  }

  /// Paginated search specifically for full-text queries
  /// Alias for search() method for backward compatibility
  Future<SearchResultModel> searchWithPagination({
    required String query,
    required int pageNumber,
  }) async {
    return await search(query, page: pageNumber);
  }

  /// Search anime that start with specific character(s)
  /// For Jikan, we just search with the letter as a query
  Future<SearchResultModel> searchStartsWith({
    required String startsWith,
    required int pageNumber,
  }) async {
    try {
      // Search with the letter as query
      return await _jikanRepository.search(
        startsWith.toUpperCase(),
        page: pageNumber,
      );
    } catch (e) {
      throw Exception('Failed to search anime by startsWith: $e');
    }
  }
}
