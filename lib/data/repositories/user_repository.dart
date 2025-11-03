import 'package:anime_app/database/DatabaseProvider.dart';
import 'package:anime_app/model/EpisodeWatched.dart';
import 'package:anime_app/models/anime_model.dart';

/// Repository responsible for user-specific data operations
/// Handles user's anime list and watched episodes persistence
class UserRepository {
  final DatabaseProvider _databaseProvider;

  UserRepository({DatabaseProvider? databaseProvider})
      : _databaseProvider = databaseProvider ?? DatabaseProvider();

  /// Initialize the database
  Future<void> initialize() async {
    await _databaseProvider.init();
  }

  /// Load user's anime list from database
  Future<Map<String, AnimeModel>> loadMyAnimeList() async {
    try {
      return await _databaseProvider.loadMyAnimeList();
    } catch (e) {
      throw Exception('Failed to load anime list: $e');
    }
  }

  /// Add an anime to user's list
  Future<void> addAnimeToList(String animeId, AnimeModel anime) async {
    try {
      await _databaseProvider.insertAnimeToList(animeId, anime);
    } catch (e) {
      throw Exception('Failed to add anime to list: $e');
    }
  }

  /// Remove an anime from user's list
  Future<void> removeAnimeFromList(String animeId) async {
    try {
      await _databaseProvider.removeAnimeFromList(animeId);
    } catch (e) {
      throw Exception('Failed to remove anime from list: $e');
    }
  }

  /// Clear all anime from user's list
  Future<void> clearAllMyList() async {
    try {
      await _databaseProvider.clearAllMyList();
    } catch (e) {
      throw Exception('Failed to clear anime list: $e');
    }
  }

  /// Load all watched episodes from database
  Future<List<EpisodeWatched>> loadWatchedEpisodes() async {
    try {
      return await _databaseProvider.loadWatchedEpisodes();
    } catch (e) {
      throw Exception('Failed to load watched episodes: $e');
    }
  }

  /// Mark an episode as watched
  Future<void> addWatchedEpisode(EpisodeWatched episode) async {
    try {
      await _databaseProvider.insertWatchedEpisode(episode);
    } catch (e) {
      throw Exception('Failed to add watched episode: $e');
    }
  }

  /// Remove a watched episode
  Future<void> removeWatchedEpisode(String episodeId) async {
    try {
      await _databaseProvider.removeWatchedEpisode(episodeId);
    } catch (e) {
      throw Exception('Failed to remove watched episode: $e');
    }
  }

  /// Clear all watched episodes
  Future<void> clearWatchedEpisodes() async {
    try {
      await _databaseProvider.clearWatchedEpisodes();
    } catch (e) {
      throw Exception('Failed to clear watched episodes: $e');
    }
  }

  /// Clear all watched episodes (alias)
  Future<void> removeAllWatchedEpisodes() async {
    try {
      await _databaseProvider.removeAllWatchedEpisodes();
    } catch (e) {
      throw Exception('Failed to remove all watched episodes: $e');
    }
  }

  /// Delete database (for testing or reset purposes)
  void deleteDatabase() {
    _databaseProvider.deleteDb();
  }
}
