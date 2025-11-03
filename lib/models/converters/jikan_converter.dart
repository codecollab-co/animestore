import 'package:jikan_api/jikan_api.dart' as jikan;
import '../anime_model.dart';
import '../episode_model.dart';
import '../genre_model.dart';

/// Converter for Jikan API models to custom app models
class JikanConverter {
  /// Convert Jikan Anime to custom AnimeModel
  static AnimeModel fromAnime(jikan.Anime anime) {
    return AnimeModel(
      id: anime.malId.toString(),
      title: anime.title,
      englishTitle: anime.titleEnglish,
      japaneseTitle: anime.titleJapanese,
      imageUrl: anime.imageUrl,
      synopsis: anime.synopsis,
      type: anime.type,
      status: anime.status,
      releaseYear: anime.year?.toString(),
      episodeCount: anime.episodes,
      rating: anime.score?.toDouble(),
      genres: anime.genres?.map((g) => g.name).toList() ?? [],
      studios: anime.studios?.map((s) => s.name).toList() ?? [],
      season: anime.season,
      year: anime.year,
      sourceIds: SourceIds(
        malId: anime.malId.toString(),
      ),
    );
  }

  /// Convert Jikan Episode to custom EpisodeModel
  static EpisodeModel fromEpisode(jikan.Episode episode, String animeId) {
    return EpisodeModel(
      id: '${animeId}_ep_${episode.malId}',
      number: episode.malId,
      animeId: animeId,
      title: episode.title,
      airDate: _parseAired(episode.aired),
      isFiller: episode.filler ?? false,
      sourceIds: EpisodeSourceIds(
        malId: episode.malId.toString(),
      ),
    );
  }

  /// Parse aired string to DateTime
  static DateTime? _parseAired(String? aired) {
    if (aired == null || aired.isEmpty) return null;
    try {
      return DateTime.parse(aired);
    } catch (e) {
      return null;
    }
  }

  /// Convert Jikan Genre to custom GenreModel
  static GenreModel fromGenre(jikan.Genre genre) {
    return GenreModel(
      id: genre.malId.toString(),
      name: genre.name,
      animeCount: genre.count,
      sourceIds: GenreSourceIds(
        malId: genre.malId.toString(),
      ),
    );
  }

  /// Convert BuiltList of Jikan Anime to list of AnimeModel
  static List<AnimeModel> fromAnimeList(Iterable<jikan.Anime> animeList) {
    return animeList.map((anime) => fromAnime(anime)).toList();
  }

  /// Convert BuiltList of Jikan Episodes to list of EpisodeModel
  static List<EpisodeModel> fromEpisodeList(
    Iterable<jikan.Episode> episodes,
    String animeId,
  ) {
    return episodes.map((ep) => fromEpisode(ep, animeId)).toList();
  }

  /// Convert BuiltList of Jikan Genres to list of GenreModel
  static List<GenreModel> fromGenreList(Iterable<jikan.Genre> genres) {
    return genres.map((genre) => fromGenre(genre)).toList();
  }
}
