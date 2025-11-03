import 'package:equatable/equatable.dart';
import 'anime_model.dart';

/// Custom Home Page Model for the app
///
/// This model represents the home page data structure with multiple sections.
/// It's independent of any API package and can aggregate data from multiple sources.
class HomePageModel extends Equatable {
  /// Featured/banner anime (hero section)
  final List<AnimeModel> featured;

  /// Currently airing anime
  final List<AnimeModel> currentlyAiring;

  /// Top rated anime
  final List<AnimeModel> topRated;

  /// Recently updated episodes
  final List<AnimeModel> recentlyUpdated;

  /// Popular this season
  final List<AnimeModel> popularThisSeason;

  /// Trending anime
  final List<AnimeModel> trending;

  /// Recommended for user (personalized, can be empty)
  final List<AnimeModel> recommended;

  /// When this data was last refreshed
  final DateTime lastRefreshed;

  /// Whether data is still loading
  final bool isLoading;

  /// Error message if something went wrong
  final String? errorMessage;

  const HomePageModel({
    this.featured = const [],
    this.currentlyAiring = const [],
    this.topRated = const [],
    this.recentlyUpdated = const [],
    this.popularThisSeason = const [],
    this.trending = const [],
    this.recommended = const [],
    required this.lastRefreshed,
    this.isLoading = false,
    this.errorMessage,
  });

  /// Create initial/empty state
  factory HomePageModel.initial() {
    return HomePageModel(
      lastRefreshed: DateTime.now(),
      isLoading: true,
    );
  }

  /// Create error state
  factory HomePageModel.error(String message) {
    return HomePageModel(
      lastRefreshed: DateTime.now(),
      isLoading: false,
      errorMessage: message,
    );
  }

  /// Check if data needs refresh (older than threshold)
  bool needsRefresh({Duration threshold = const Duration(hours: 1)}) {
    final now = DateTime.now();
    final difference = now.difference(lastRefreshed);
    return difference > threshold;
  }

  /// Check if home page has any content
  bool get hasContent =>
      featured.isNotEmpty ||
      currentlyAiring.isNotEmpty ||
      topRated.isNotEmpty ||
      recentlyUpdated.isNotEmpty ||
      popularThisSeason.isNotEmpty ||
      trending.isNotEmpty;

  /// Create a copy with updated fields
  HomePageModel copyWith({
    List<AnimeModel>? featured,
    List<AnimeModel>? currentlyAiring,
    List<AnimeModel>? topRated,
    List<AnimeModel>? recentlyUpdated,
    List<AnimeModel>? popularThisSeason,
    List<AnimeModel>? trending,
    List<AnimeModel>? recommended,
    DateTime? lastRefreshed,
    bool? isLoading,
    String? errorMessage,
  }) {
    return HomePageModel(
      featured: featured ?? this.featured,
      currentlyAiring: currentlyAiring ?? this.currentlyAiring,
      topRated: topRated ?? this.topRated,
      recentlyUpdated: recentlyUpdated ?? this.recentlyUpdated,
      popularThisSeason: popularThisSeason ?? this.popularThisSeason,
      trending: trending ?? this.trending,
      recommended: recommended ?? this.recommended,
      lastRefreshed: lastRefreshed ?? this.lastRefreshed,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'featured': featured.map((a) => a.toJson()).toList(),
      'currentlyAiring': currentlyAiring.map((a) => a.toJson()).toList(),
      'topRated': topRated.map((a) => a.toJson()).toList(),
      'recentlyUpdated': recentlyUpdated.map((a) => a.toJson()).toList(),
      'popularThisSeason': popularThisSeason.map((a) => a.toJson()).toList(),
      'trending': trending.map((a) => a.toJson()).toList(),
      'recommended': recommended.map((a) => a.toJson()).toList(),
      'lastRefreshed': lastRefreshed.toIso8601String(),
      'isLoading': isLoading,
      'errorMessage': errorMessage,
    };
  }

  /// Create from JSON
  factory HomePageModel.fromJson(Map<String, dynamic> json) {
    return HomePageModel(
      featured: (json['featured'] as List?)
              ?.map((a) => AnimeModel.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
      currentlyAiring: (json['currentlyAiring'] as List?)
              ?.map((a) => AnimeModel.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
      topRated: (json['topRated'] as List?)
              ?.map((a) => AnimeModel.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
      recentlyUpdated: (json['recentlyUpdated'] as List?)
              ?.map((a) => AnimeModel.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
      popularThisSeason: (json['popularThisSeason'] as List?)
              ?.map((a) => AnimeModel.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
      trending: (json['trending'] as List?)
              ?.map((a) => AnimeModel.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
      recommended: (json['recommended'] as List?)
              ?.map((a) => AnimeModel.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
      lastRefreshed: DateTime.parse(json['lastRefreshed'] as String),
      isLoading: json['isLoading'] as bool? ?? false,
      errorMessage: json['errorMessage'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        featured,
        currentlyAiring,
        topRated,
        recentlyUpdated,
        popularThisSeason,
        trending,
        recommended,
        lastRefreshed,
        isLoading,
        errorMessage,
      ];

  @override
  String toString() =>
      'HomePageModel(featured: ${featured.length}, airing: ${currentlyAiring.length}, topRated: ${topRated.length})';
}

/// Individual section in home page
/// Useful for dynamic sections or custom layouts
class HomePageSection extends Equatable {
  /// Section title
  final String title;

  /// Section type/identifier
  final String type;

  /// Anime items in this section
  final List<AnimeModel> items;

  /// Whether this section supports pagination
  final bool isPaginatable;

  /// Current page number (if paginated)
  final int currentPage;

  /// Whether there are more pages available
  final bool hasNextPage;

  const HomePageSection({
    required this.title,
    required this.type,
    this.items = const [],
    this.isPaginatable = false,
    this.currentPage = 1,
    this.hasNextPage = false,
  });

  HomePageSection copyWith({
    String? title,
    String? type,
    List<AnimeModel>? items,
    bool? isPaginatable,
    int? currentPage,
    bool? hasNextPage,
  }) {
    return HomePageSection(
      title: title ?? this.title,
      type: type ?? this.type,
      items: items ?? this.items,
      isPaginatable: isPaginatable ?? this.isPaginatable,
      currentPage: currentPage ?? this.currentPage,
      hasNextPage: hasNextPage ?? this.hasNextPage,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'type': type,
      'items': items.map((a) => a.toJson()).toList(),
      'isPaginatable': isPaginatable,
      'currentPage': currentPage,
      'hasNextPage': hasNextPage,
    };
  }

  factory HomePageSection.fromJson(Map<String, dynamic> json) {
    return HomePageSection(
      title: json['title'] as String,
      type: json['type'] as String,
      items: (json['items'] as List?)
              ?.map((a) => AnimeModel.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
      isPaginatable: json['isPaginatable'] as bool? ?? false,
      currentPage: json['currentPage'] as int? ?? 1,
      hasNextPage: json['hasNextPage'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [
        title,
        type,
        items,
        isPaginatable,
        currentPage,
        hasNextPage,
      ];
}
