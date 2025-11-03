import 'package:equatable/equatable.dart';

/// Custom Anime Model for the app
///
/// This model is independent of any API package (AniTube, Jikan, Consumet).
/// It represents anime data in the format our app needs.
class AnimeModel extends Equatable {
  /// Unique identifier (can be MAL ID, AniTube ID, or Consumet ID)
  final String id;

  /// Anime title (primary)
  final String title;

  /// Alternative titles
  final String? englishTitle;
  final String? japaneseTitle;

  /// Cover/poster image URL
  final String imageUrl;

  /// Banner image URL (for hero sections)
  final String? bannerUrl;

  /// Synopsis/description
  final String? synopsis;

  /// Type: TV, Movie, OVA, Special, ONA
  final String? type;

  /// Status: Airing, Finished, Upcoming
  final String? status;

  /// Release year
  final String? releaseYear;

  /// Number of episodes (null if unknown)
  final int? episodeCount;

  /// Rating/score (0-10)
  final double? rating;

  /// Genres
  final List<String> genres;

  /// Studios
  final List<String> studios;

  /// Sub or Dub
  final String? audioType; // 'sub', 'dub', or 'both'

  /// Source IDs from different APIs (for cross-referencing)
  final SourceIds sourceIds;

  /// Metadata
  final DateTime? airingStart;
  final DateTime? airingEnd;
  final String? season; // Winter, Spring, Summer, Fall
  final int? year;

  const AnimeModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.englishTitle,
    this.japaneseTitle,
    this.bannerUrl,
    this.synopsis,
    this.type,
    this.status,
    this.releaseYear,
    this.episodeCount,
    this.rating,
    this.genres = const [],
    this.studios = const [],
    this.audioType,
    this.sourceIds = const SourceIds(),
    this.airingStart,
    this.airingEnd,
    this.season,
    this.year,
  });

  /// Create a copy with updated fields
  AnimeModel copyWith({
    String? id,
    String? title,
    String? englishTitle,
    String? japaneseTitle,
    String? imageUrl,
    String? bannerUrl,
    String? synopsis,
    String? type,
    String? status,
    String? releaseYear,
    int? episodeCount,
    double? rating,
    List<String>? genres,
    List<String>? studios,
    String? audioType,
    SourceIds? sourceIds,
    DateTime? airingStart,
    DateTime? airingEnd,
    String? season,
    int? year,
  }) {
    return AnimeModel(
      id: id ?? this.id,
      title: title ?? this.title,
      englishTitle: englishTitle ?? this.englishTitle,
      japaneseTitle: japaneseTitle ?? this.japaneseTitle,
      imageUrl: imageUrl ?? this.imageUrl,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      synopsis: synopsis ?? this.synopsis,
      type: type ?? this.type,
      status: status ?? this.status,
      releaseYear: releaseYear ?? this.releaseYear,
      episodeCount: episodeCount ?? this.episodeCount,
      rating: rating ?? this.rating,
      genres: genres ?? this.genres,
      studios: studios ?? this.studios,
      audioType: audioType ?? this.audioType,
      sourceIds: sourceIds ?? this.sourceIds,
      airingStart: airingStart ?? this.airingStart,
      airingEnd: airingEnd ?? this.airingEnd,
      season: season ?? this.season,
      year: year ?? this.year,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'englishTitle': englishTitle,
      'japaneseTitle': japaneseTitle,
      'imageUrl': imageUrl,
      'bannerUrl': bannerUrl,
      'synopsis': synopsis,
      'type': type,
      'status': status,
      'releaseYear': releaseYear,
      'episodeCount': episodeCount,
      'rating': rating,
      'genres': genres,
      'studios': studios,
      'audioType': audioType,
      'sourceIds': sourceIds.toJson(),
      'airingStart': airingStart?.toIso8601String(),
      'airingEnd': airingEnd?.toIso8601String(),
      'season': season,
      'year': year,
    };
  }

  /// Create from JSON
  factory AnimeModel.fromJson(Map<String, dynamic> json) {
    return AnimeModel(
      id: json['id'] as String,
      title: json['title'] as String,
      imageUrl: json['imageUrl'] as String,
      englishTitle: json['englishTitle'] as String?,
      japaneseTitle: json['japaneseTitle'] as String?,
      bannerUrl: json['bannerUrl'] as String?,
      synopsis: json['synopsis'] as String?,
      type: json['type'] as String?,
      status: json['status'] as String?,
      releaseYear: json['releaseYear'] as String?,
      episodeCount: json['episodeCount'] as int?,
      rating: (json['rating'] as num?)?.toDouble(),
      genres: (json['genres'] as List?)?.cast<String>() ?? [],
      studios: (json['studios'] as List?)?.cast<String>() ?? [],
      audioType: json['audioType'] as String?,
      sourceIds: json['sourceIds'] != null
          ? SourceIds.fromJson(json['sourceIds'] as Map<String, dynamic>)
          : const SourceIds(),
      airingStart: json['airingStart'] != null
          ? DateTime.parse(json['airingStart'] as String)
          : null,
      airingEnd: json['airingEnd'] != null
          ? DateTime.parse(json['airingEnd'] as String)
          : null,
      season: json['season'] as String?,
      year: json['year'] as int?,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        englishTitle,
        japaneseTitle,
        imageUrl,
        bannerUrl,
        synopsis,
        type,
        status,
        releaseYear,
        episodeCount,
        rating,
        genres,
        studios,
        audioType,
        sourceIds,
        airingStart,
        airingEnd,
        season,
        year,
      ];

  @override
  String toString() => 'AnimeModel(id: $id, title: $title, type: $type)';
}

/// Source IDs from different APIs
///
/// Allows cross-referencing the same anime across different services
class SourceIds extends Equatable {
  final String? malId; // MyAnimeList ID
  final String? aniListId; // AniList ID
  final String? aniTubeId; // AniTube ID
  final String? gogoAnimeId; // GogoAnime ID (via Consumet)
  final String? zoroId; // Zoro ID (via Consumet)

  const SourceIds({
    this.malId,
    this.aniListId,
    this.aniTubeId,
    this.gogoAnimeId,
    this.zoroId,
  });

  SourceIds copyWith({
    String? malId,
    String? aniListId,
    String? aniTubeId,
    String? gogoAnimeId,
    String? zoroId,
  }) {
    return SourceIds(
      malId: malId ?? this.malId,
      aniListId: aniListId ?? this.aniListId,
      aniTubeId: aniTubeId ?? this.aniTubeId,
      gogoAnimeId: gogoAnimeId ?? this.gogoAnimeId,
      zoroId: zoroId ?? this.zoroId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'malId': malId,
      'aniListId': aniListId,
      'aniTubeId': aniTubeId,
      'gogoAnimeId': gogoAnimeId,
      'zoroId': zoroId,
    };
  }

  factory SourceIds.fromJson(Map<String, dynamic> json) {
    return SourceIds(
      malId: json['malId'] as String?,
      aniListId: json['aniListId'] as String?,
      aniTubeId: json['aniTubeId'] as String?,
      gogoAnimeId: json['gogoAnimeId'] as String?,
      zoroId: json['zoroId'] as String?,
    );
  }

  @override
  List<Object?> get props =>
      [malId, aniListId, aniTubeId, gogoAnimeId, zoroId];
}
