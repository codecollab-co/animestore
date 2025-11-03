import 'package:equatable/equatable.dart';
import 'anime_model.dart';

/// Custom Search Result Model for the app
///
/// This model represents paginated search results.
/// It's independent of any API package and supports multiple sources.
class SearchResultModel extends Equatable {
  /// Search query that produced these results
  final String query;

  /// List of anime results
  final List<AnimeModel> results;

  /// Current page number
  final int currentPage;

  /// Total number of pages (if known)
  final int? totalPages;

  /// Total number of results (if known)
  final int? totalResults;

  /// Whether there's a next page
  final bool hasNextPage;

  /// Whether data is still loading
  final bool isLoading;

  /// Error message if something went wrong
  final String? errorMessage;

  /// Search filters applied (optional)
  final SearchFilters? filters;

  /// When this search was performed
  final DateTime timestamp;

  const SearchResultModel({
    required this.query,
    this.results = const [],
    this.currentPage = 1,
    this.totalPages,
    this.totalResults,
    this.hasNextPage = false,
    this.isLoading = false,
    this.errorMessage,
    this.filters,
    required this.timestamp,
  });

  /// Create initial/empty search state
  factory SearchResultModel.initial(String query) {
    return SearchResultModel(
      query: query,
      timestamp: DateTime.now(),
      isLoading: true,
    );
  }

  /// Create error state
  factory SearchResultModel.error(String query, String message) {
    return SearchResultModel(
      query: query,
      timestamp: DateTime.now(),
      isLoading: false,
      errorMessage: message,
    );
  }

  /// Check if search has results
  bool get hasResults => results.isNotEmpty;

  /// Check if this is an empty/no results state
  bool get isEmpty => !isLoading && results.isEmpty && errorMessage == null;

  /// Create a copy with updated fields
  SearchResultModel copyWith({
    String? query,
    List<AnimeModel>? results,
    int? currentPage,
    int? totalPages,
    int? totalResults,
    bool? hasNextPage,
    bool? isLoading,
    String? errorMessage,
    SearchFilters? filters,
    DateTime? timestamp,
  }) {
    return SearchResultModel(
      query: query ?? this.query,
      results: results ?? this.results,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalResults: totalResults ?? this.totalResults,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      filters: filters ?? this.filters,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  /// Append more results (for pagination)
  SearchResultModel appendResults(List<AnimeModel> newResults, {bool? hasNextPage}) {
    return copyWith(
      results: [...results, ...newResults],
      currentPage: currentPage + 1,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      isLoading: false,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'query': query,
      'results': results.map((a) => a.toJson()).toList(),
      'currentPage': currentPage,
      'totalPages': totalPages,
      'totalResults': totalResults,
      'hasNextPage': hasNextPage,
      'isLoading': isLoading,
      'errorMessage': errorMessage,
      'filters': filters?.toJson(),
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Create from JSON
  factory SearchResultModel.fromJson(Map<String, dynamic> json) {
    return SearchResultModel(
      query: json['query'] as String,
      results: (json['results'] as List?)
              ?.map((a) => AnimeModel.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
      currentPage: json['currentPage'] as int? ?? 1,
      totalPages: json['totalPages'] as int?,
      totalResults: json['totalResults'] as int?,
      hasNextPage: json['hasNextPage'] as bool? ?? false,
      isLoading: json['isLoading'] as bool? ?? false,
      errorMessage: json['errorMessage'] as String?,
      filters: json['filters'] != null
          ? SearchFilters.fromJson(json['filters'] as Map<String, dynamic>)
          : null,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  @override
  List<Object?> get props => [
        query,
        results,
        currentPage,
        totalPages,
        totalResults,
        hasNextPage,
        isLoading,
        errorMessage,
        filters,
        timestamp,
      ];

  @override
  String toString() =>
      'SearchResultModel(query: $query, results: ${results.length}, page: $currentPage)';
}

/// Search filters for advanced search
class SearchFilters extends Equatable {
  /// Filter by genres
  final List<String> genres;

  /// Filter by type (TV, Movie, OVA, etc.)
  final String? type;

  /// Filter by status (Airing, Finished, Upcoming)
  final String? status;

  /// Filter by rating (minimum score)
  final double? minRating;

  /// Filter by year
  final int? year;

  /// Filter by season (Winter, Spring, Summer, Fall)
  final String? season;

  /// Sort by (popularity, rating, title, etc.)
  final String? sortBy;

  /// Sort order (asc or desc)
  final String? sortOrder;

  /// Audio type (sub, dub, both)
  final String? audioType;

  const SearchFilters({
    this.genres = const [],
    this.type,
    this.status,
    this.minRating,
    this.year,
    this.season,
    this.sortBy,
    this.sortOrder,
    this.audioType,
  });

  /// Check if any filters are applied
  bool get hasFilters =>
      genres.isNotEmpty ||
      type != null ||
      status != null ||
      minRating != null ||
      year != null ||
      season != null ||
      audioType != null;

  /// Create a copy with updated fields
  SearchFilters copyWith({
    List<String>? genres,
    String? type,
    String? status,
    double? minRating,
    int? year,
    String? season,
    String? sortBy,
    String? sortOrder,
    String? audioType,
  }) {
    return SearchFilters(
      genres: genres ?? this.genres,
      type: type ?? this.type,
      status: status ?? this.status,
      minRating: minRating ?? this.minRating,
      year: year ?? this.year,
      season: season ?? this.season,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
      audioType: audioType ?? this.audioType,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'genres': genres,
      'type': type,
      'status': status,
      'minRating': minRating,
      'year': year,
      'season': season,
      'sortBy': sortBy,
      'sortOrder': sortOrder,
      'audioType': audioType,
    };
  }

  /// Create from JSON
  factory SearchFilters.fromJson(Map<String, dynamic> json) {
    return SearchFilters(
      genres: (json['genres'] as List?)?.cast<String>() ?? [],
      type: json['type'] as String?,
      status: json['status'] as String?,
      minRating: (json['minRating'] as num?)?.toDouble(),
      year: json['year'] as int?,
      season: json['season'] as String?,
      sortBy: json['sortBy'] as String?,
      sortOrder: json['sortOrder'] as String?,
      audioType: json['audioType'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        genres,
        type,
        status,
        minRating,
        year,
        season,
        sortBy,
        sortOrder,
        audioType,
      ];

  @override
  String toString() => 'SearchFilters(genres: $genres, type: $type, status: $status)';
}

/// Quick search suggestion model
class SearchSuggestion extends Equatable {
  /// Suggestion text
  final String text;

  /// Type of suggestion (anime, genre, recent_search)
  final String type;

  /// Associated anime ID (if type is 'anime')
  final String? animeId;

  /// Thumbnail image (if available)
  final String? imageUrl;

  const SearchSuggestion({
    required this.text,
    required this.type,
    this.animeId,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'type': type,
      'animeId': animeId,
      'imageUrl': imageUrl,
    };
  }

  factory SearchSuggestion.fromJson(Map<String, dynamic> json) {
    return SearchSuggestion(
      text: json['text'] as String,
      type: json['type'] as String,
      animeId: json['animeId'] as String?,
      imageUrl: json['imageUrl'] as String?,
    );
  }

  @override
  List<Object?> get props => [text, type, animeId, imageUrl];
}
