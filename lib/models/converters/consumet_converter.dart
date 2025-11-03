import '../anime_model.dart';
import '../episode_model.dart';

/// Converter for Consumet API responses to custom app models
///
/// Note: Consumet returns raw JSON, not typed objects
class ConsumetConverter {
  /// Convert Consumet search result to AnimeModel
  static AnimeModel fromSearchResult(Map<String, dynamic> json) {
    return AnimeModel(
      id: json['id'] as String,
      title: json['title'] as String,
      imageUrl: json['image'] as String? ?? '',
      releaseYear: json['releaseDate'] as String?,
      type: _mapType(json['subOrDub'] as String?),
      audioType: _mapAudioType(json['subOrDub'] as String?),
      sourceIds: SourceIds(
        gogoAnimeId: json['id'] as String,
      ),
    );
  }

  /// Convert Consumet anime info to AnimeModel with episodes
  static AnimeModel fromAnimeInfo(Map<String, dynamic> json) {
    final episodes = json['episodes'] as List?;

    return AnimeModel(
      id: json['id'] as String,
      title: json['title'] as String,
      englishTitle: json['otherName'] as String?,
      imageUrl: json['image'] as String? ?? '',
      synopsis: json['description'] as String?,
      releaseYear: json['releaseDate'] as String?,
      episodeCount: episodes?.length,
      type: json['type'] as String?,
      status: json['status'] as String?,
      genres: (json['genres'] as List?)?.cast<String>() ?? [],
      audioType: _mapAudioType(json['subOrDub'] as String?),
      sourceIds: SourceIds(
        gogoAnimeId: json['id'] as String,
      ),
    );
  }

  /// Convert Consumet episode to EpisodeModel
  static EpisodeModel fromEpisode(Map<String, dynamic> json, String animeId) {
    return EpisodeModel(
      id: json['id'] as String,
      number: json['number'] as int,
      animeId: animeId,
      title: json['title'] as String?,
      imageUrl: json['image'] as String?,
      sourceIds: EpisodeSourceIds(
        gogoAnimeId: json['id'] as String,
      ),
    );
  }

  /// Convert Consumet streaming data to EpisodeModel with StreamingInfo
  static EpisodeModel fromStreamingData(
    Map<String, dynamic> json,
    String episodeId,
    String animeId,
    int episodeNumber,
  ) {
    final sources = json['sources'] as List?;
    final subtitles = json['subtitles'] as List?;
    final headers = json['headers'] as Map<String, dynamic>?;

    // Get video qualities
    final qualities = sources
            ?.map((source) => VideoQuality(
                  quality: source['quality'] as String? ?? 'default',
                  url: source['url'] as String,
                  isDefault: source['isM3U8'] as bool? ?? false,
                ))
            .toList() ??
        [];

    // Get subtitle tracks
    final subtitleTracks = subtitles
            ?.map((sub) => SubtitleTrack(
                  language: sub['lang'] as String? ?? 'en',
                  label: sub['lang'] as String? ?? 'English',
                  url: sub['url'] as String,
                ))
            .toList() ??
        [];

    final streamingInfo = StreamingInfo(
      videoUrl: sources?.isNotEmpty == true
          ? (sources!.first['url'] as String)
          : null,
      qualities: qualities,
      subtitles: subtitleTracks,
      headers: headers?.cast<String, String>(),
      referer: json['referer'] as String?,
      provider: json['provider'] as String? ?? 'gogoanime',
      server: json['server'] as String?,
    );

    return EpisodeModel(
      id: episodeId,
      number: episodeNumber,
      animeId: animeId,
      streamingInfo: streamingInfo,
      sourceIds: EpisodeSourceIds(
        gogoAnimeId: episodeId,
      ),
    );
  }

  /// Convert list of Consumet search results to list of AnimeModel
  static List<AnimeModel> fromSearchResults(List<dynamic> results) {
    return results
        .map((result) => fromSearchResult(result as Map<String, dynamic>))
        .toList();
  }

  /// Convert list of Consumet episodes to list of EpisodeModel
  static List<EpisodeModel> fromEpisodeList(
    List<dynamic> episodes,
    String animeId,
  ) {
    return episodes
        .map((ep) => fromEpisode(ep as Map<String, dynamic>, animeId))
        .toList();
  }

  /// Map Consumet subOrDub to type
  static String? _mapType(String? subOrDub) {
    if (subOrDub == null) return null;
    // Consumet doesn't provide type in search, only sub/dub info
    return 'TV'; // Default assumption
  }

  /// Map Consumet subOrDub to audio type
  static String? _mapAudioType(String? subOrDub) {
    if (subOrDub == null) return null;

    final lower = subOrDub.toLowerCase();
    if (lower.contains('sub')) {
      return 'sub';
    } else if (lower.contains('dub')) {
      return 'dub';
    }
    return 'sub'; // Default to sub
  }

  /// Map Consumet provider name to app format
  static String mapProvider(String provider) {
    final providers = {
      'gogoanime': 'GogoAnime',
      'zoro': 'Zoro',
      '9anime': '9Anime',
      'animepahe': 'AnimePahe',
    };
    return providers[provider.toLowerCase()] ?? provider;
  }

  /// Map Consumet quality to standardized format
  static String normalizeQuality(String quality) {
    final qualityMap = {
      'default': 'Auto',
      'backup': 'Auto',
      '1080p': '1080p',
      '720p': '720p',
      '480p': '480p',
      '360p': '360p',
    };
    return qualityMap[quality.toLowerCase()] ?? quality;
  }
}
