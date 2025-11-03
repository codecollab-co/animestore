import 'package:equatable/equatable.dart';

/// Custom Episode Model for the app
///
/// This model is independent of any API package (AniTube, Jikan, Consumet).
/// It represents episode data in the format our app needs.
class EpisodeModel extends Equatable {
  /// Unique identifier for the episode
  final String id;

  /// Episode number
  final int number;

  /// Episode title (may be null for some sources)
  final String? title;

  /// Episode description/synopsis
  final String? description;

  /// Thumbnail/preview image URL
  final String? imageUrl;

  /// Air date
  final DateTime? airDate;

  /// Duration in minutes
  final int? duration;

  /// Filler episode flag
  final bool isFiller;

  /// Anime ID this episode belongs to
  final String animeId;

  /// Streaming information
  final StreamingInfo? streamingInfo;

  /// Watch progress (0.0 to 1.0)
  final double watchProgress;

  /// Whether user has watched this episode
  final bool isWatched;

  /// Source IDs from different APIs
  final EpisodeSourceIds sourceIds;

  const EpisodeModel({
    required this.id,
    required this.number,
    required this.animeId,
    this.title,
    this.description,
    this.imageUrl,
    this.airDate,
    this.duration,
    this.isFiller = false,
    this.streamingInfo,
    this.watchProgress = 0.0,
    this.isWatched = false,
    this.sourceIds = const EpisodeSourceIds(),
  });

  /// Create a copy with updated fields
  EpisodeModel copyWith({
    String? id,
    int? number,
    String? animeId,
    String? title,
    String? description,
    String? imageUrl,
    DateTime? airDate,
    int? duration,
    bool? isFiller,
    StreamingInfo? streamingInfo,
    double? watchProgress,
    bool? isWatched,
    EpisodeSourceIds? sourceIds,
  }) {
    return EpisodeModel(
      id: id ?? this.id,
      number: number ?? this.number,
      animeId: animeId ?? this.animeId,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      airDate: airDate ?? this.airDate,
      duration: duration ?? this.duration,
      isFiller: isFiller ?? this.isFiller,
      streamingInfo: streamingInfo ?? this.streamingInfo,
      watchProgress: watchProgress ?? this.watchProgress,
      isWatched: isWatched ?? this.isWatched,
      sourceIds: sourceIds ?? this.sourceIds,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'number': number,
      'animeId': animeId,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'airDate': airDate?.toIso8601String(),
      'duration': duration,
      'isFiller': isFiller,
      'streamingInfo': streamingInfo?.toJson(),
      'watchProgress': watchProgress,
      'isWatched': isWatched,
      'sourceIds': sourceIds.toJson(),
    };
  }

  /// Create from JSON
  factory EpisodeModel.fromJson(Map<String, dynamic> json) {
    return EpisodeModel(
      id: json['id'] as String,
      number: json['number'] as int,
      animeId: json['animeId'] as String,
      title: json['title'] as String?,
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      airDate: json['airDate'] != null
          ? DateTime.parse(json['airDate'] as String)
          : null,
      duration: json['duration'] as int?,
      isFiller: json['isFiller'] as bool? ?? false,
      streamingInfo: json['streamingInfo'] != null
          ? StreamingInfo.fromJson(json['streamingInfo'] as Map<String, dynamic>)
          : null,
      watchProgress: (json['watchProgress'] as num?)?.toDouble() ?? 0.0,
      isWatched: json['isWatched'] as bool? ?? false,
      sourceIds: json['sourceIds'] != null
          ? EpisodeSourceIds.fromJson(json['sourceIds'] as Map<String, dynamic>)
          : const EpisodeSourceIds(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        number,
        animeId,
        title,
        description,
        imageUrl,
        airDate,
        duration,
        isFiller,
        streamingInfo,
        watchProgress,
        isWatched,
        sourceIds,
      ];

  @override
  String toString() =>
      'EpisodeModel(id: $id, number: $number, title: $title, animeId: $animeId)';
}

/// Streaming information for an episode
class StreamingInfo extends Equatable {
  /// Direct video URL (if available)
  final String? videoUrl;

  /// Available video qualities
  final List<VideoQuality> qualities;

  /// Subtitle tracks
  final List<SubtitleTrack> subtitles;

  /// Video headers (for authentication)
  final Map<String, String>? headers;

  /// Referer URL (required by some providers)
  final String? referer;

  /// Provider name (gogoanime, zoro, etc.)
  final String provider;

  /// Server name (gogocdn, rapid-cloud, etc.)
  final String? server;

  const StreamingInfo({
    this.videoUrl,
    this.qualities = const [],
    this.subtitles = const [],
    this.headers,
    this.referer,
    required this.provider,
    this.server,
  });

  StreamingInfo copyWith({
    String? videoUrl,
    List<VideoQuality>? qualities,
    List<SubtitleTrack>? subtitles,
    Map<String, String>? headers,
    String? referer,
    String? provider,
    String? server,
  }) {
    return StreamingInfo(
      videoUrl: videoUrl ?? this.videoUrl,
      qualities: qualities ?? this.qualities,
      subtitles: subtitles ?? this.subtitles,
      headers: headers ?? this.headers,
      referer: referer ?? this.referer,
      provider: provider ?? this.provider,
      server: server ?? this.server,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'videoUrl': videoUrl,
      'qualities': qualities.map((q) => q.toJson()).toList(),
      'subtitles': subtitles.map((s) => s.toJson()).toList(),
      'headers': headers,
      'referer': referer,
      'provider': provider,
      'server': server,
    };
  }

  factory StreamingInfo.fromJson(Map<String, dynamic> json) {
    return StreamingInfo(
      videoUrl: json['videoUrl'] as String?,
      qualities: (json['qualities'] as List?)
              ?.map((q) => VideoQuality.fromJson(q as Map<String, dynamic>))
              .toList() ??
          [],
      subtitles: (json['subtitles'] as List?)
              ?.map((s) => SubtitleTrack.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
      headers: (json['headers'] as Map<String, dynamic>?)?.cast<String, String>(),
      referer: json['referer'] as String?,
      provider: json['provider'] as String,
      server: json['server'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        videoUrl,
        qualities,
        subtitles,
        headers,
        referer,
        provider,
        server,
      ];
}

/// Video quality option
class VideoQuality extends Equatable {
  /// Quality label (1080p, 720p, 480p, 360p, etc.)
  final String quality;

  /// Video URL for this quality
  final String url;

  /// Is this the default quality?
  final bool isDefault;

  const VideoQuality({
    required this.quality,
    required this.url,
    this.isDefault = false,
  });

  VideoQuality copyWith({
    String? quality,
    String? url,
    bool? isDefault,
  }) {
    return VideoQuality(
      quality: quality ?? this.quality,
      url: url ?? this.url,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quality': quality,
      'url': url,
      'isDefault': isDefault,
    };
  }

  factory VideoQuality.fromJson(Map<String, dynamic> json) {
    return VideoQuality(
      quality: json['quality'] as String,
      url: json['url'] as String,
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [quality, url, isDefault];
}

/// Subtitle track
class SubtitleTrack extends Equatable {
  /// Language code (en, ja, es, etc.)
  final String language;

  /// Language label (English, Japanese, Spanish, etc.)
  final String label;

  /// Subtitle file URL
  final String url;

  /// Is this the default subtitle?
  final bool isDefault;

  const SubtitleTrack({
    required this.language,
    required this.label,
    required this.url,
    this.isDefault = false,
  });

  SubtitleTrack copyWith({
    String? language,
    String? label,
    String? url,
    bool? isDefault,
  }) {
    return SubtitleTrack(
      language: language ?? this.language,
      label: label ?? this.label,
      url: url ?? this.url,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'language': language,
      'label': label,
      'url': url,
      'isDefault': isDefault,
    };
  }

  factory SubtitleTrack.fromJson(Map<String, dynamic> json) {
    return SubtitleTrack(
      language: json['language'] as String,
      label: json['label'] as String,
      url: json['url'] as String,
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [language, label, url, isDefault];
}

/// Episode source IDs from different APIs
class EpisodeSourceIds extends Equatable {
  final String? malId; // MyAnimeList episode ID
  final String? aniTubeId; // AniTube episode ID
  final String? gogoAnimeId; // GogoAnime episode ID
  final String? zoroId; // Zoro episode ID

  const EpisodeSourceIds({
    this.malId,
    this.aniTubeId,
    this.gogoAnimeId,
    this.zoroId,
  });

  EpisodeSourceIds copyWith({
    String? malId,
    String? aniTubeId,
    String? gogoAnimeId,
    String? zoroId,
  }) {
    return EpisodeSourceIds(
      malId: malId ?? this.malId,
      aniTubeId: aniTubeId ?? this.aniTubeId,
      gogoAnimeId: gogoAnimeId ?? this.gogoAnimeId,
      zoroId: zoroId ?? this.zoroId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'malId': malId,
      'aniTubeId': aniTubeId,
      'gogoAnimeId': gogoAnimeId,
      'zoroId': zoroId,
    };
  }

  factory EpisodeSourceIds.fromJson(Map<String, dynamic> json) {
    return EpisodeSourceIds(
      malId: json['malId'] as String?,
      aniTubeId: json['aniTubeId'] as String?,
      gogoAnimeId: json['gogoAnimeId'] as String?,
      zoroId: json['zoroId'] as String?,
    );
  }

  @override
  List<Object?> get props => [malId, aniTubeId, gogoAnimeId, zoroId];
}
