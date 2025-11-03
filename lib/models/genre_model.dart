import 'package:equatable/equatable.dart';

/// Custom Genre Model for the app
///
/// This model is independent of any API package.
/// It represents genre/category data in the format our app needs.
class GenreModel extends Equatable {
  /// Unique identifier (can be MAL genre ID, name slug, etc.)
  final String id;

  /// Genre name (Action, Adventure, Comedy, etc.)
  final String name;

  /// Genre description
  final String? description;

  /// Number of anime in this genre (if available)
  final int? animeCount;

  /// Icon or image URL for the genre
  final String? imageUrl;

  /// Source IDs from different APIs
  final GenreSourceIds sourceIds;

  const GenreModel({
    required this.id,
    required this.name,
    this.description,
    this.animeCount,
    this.imageUrl,
    this.sourceIds = const GenreSourceIds(),
  });

  /// Create a copy with updated fields
  GenreModel copyWith({
    String? id,
    String? name,
    String? description,
    int? animeCount,
    String? imageUrl,
    GenreSourceIds? sourceIds,
  }) {
    return GenreModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      animeCount: animeCount ?? this.animeCount,
      imageUrl: imageUrl ?? this.imageUrl,
      sourceIds: sourceIds ?? this.sourceIds,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'animeCount': animeCount,
      'imageUrl': imageUrl,
      'sourceIds': sourceIds.toJson(),
    };
  }

  /// Create from JSON
  factory GenreModel.fromJson(Map<String, dynamic> json) {
    return GenreModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      animeCount: json['animeCount'] as int?,
      imageUrl: json['imageUrl'] as String?,
      sourceIds: json['sourceIds'] != null
          ? GenreSourceIds.fromJson(json['sourceIds'] as Map<String, dynamic>)
          : const GenreSourceIds(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        animeCount,
        imageUrl,
        sourceIds,
      ];

  @override
  String toString() => 'GenreModel(id: $id, name: $name)';
}

/// Genre source IDs from different APIs
class GenreSourceIds extends Equatable {
  final String? malId; // MyAnimeList genre ID
  final String? aniListId; // AniList genre ID
  final String? consumetSlug; // Consumet genre slug

  const GenreSourceIds({
    this.malId,
    this.aniListId,
    this.consumetSlug,
  });

  GenreSourceIds copyWith({
    String? malId,
    String? aniListId,
    String? consumetSlug,
  }) {
    return GenreSourceIds(
      malId: malId ?? this.malId,
      aniListId: aniListId ?? this.aniListId,
      consumetSlug: consumetSlug ?? this.consumetSlug,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'malId': malId,
      'aniListId': aniListId,
      'consumetSlug': consumetSlug,
    };
  }

  factory GenreSourceIds.fromJson(Map<String, dynamic> json) {
    return GenreSourceIds(
      malId: json['malId'] as String?,
      aniListId: json['aniListId'] as String?,
      consumetSlug: json['consumetSlug'] as String?,
    );
  }

  @override
  List<Object?> get props => [malId, aniListId, consumetSlug];
}
