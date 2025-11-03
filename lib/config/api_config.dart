/// API Configuration for Anime App
///
/// This file contains all API endpoints and configuration for:
/// - Consumet API (video streaming)
/// - Jikan API (MyAnimeList metadata)
class ApiConfig {
  // Private constructor to prevent instantiation
  ApiConfig._();

  /// Consumet API Base URL
  ///
  /// TODO: Replace with your deployed Consumet instance URL
  /// Deploy using Railway.app, Render, or self-hosted Docker
  /// See: CONSUMET_DEPLOYMENT_GUIDE.md for deployment instructions
  ///
  /// Example URLs:
  /// - Railway: https://your-app.up.railway.app
  /// - Render: https://consumet-api.onrender.com
  /// - Vercel: https://your-app.vercel.app
  /// - Self-hosted: https://api.yourdomain.com
  static const String consumetBaseUrl = String.fromEnvironment(
    'CONSUMET_URL',
    defaultValue: 'https://consumet-api-demo.onrender.com', // Demo instance
  );

  /// Jikan API Base URL (Official MyAnimeList API)
  ///
  /// Public API, no deployment required
  /// Rate limits: 3 requests/second, 60 requests/minute
  static const String jikanBaseUrl = 'https://api.jikan.moe/v4';

  /// API Timeouts (in milliseconds for Dio 4.x)
  static const int connectTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 60000; // 60 seconds

  /// Consumet Providers
  ///
  /// Available providers for video streaming
  /// Ordered by reliability (most reliable first)
  static const List<String> videoProviders = [
    'gogoanime', // Default, most reliable
    'zoro', // High quality
    '9anime', // Alternative
    'animepahe', // Backup
  ];

  /// Consumet Servers
  ///
  /// Available video servers for each provider
  static const Map<String, List<String>> providerServers = {
    'gogoanime': ['gogocdn', 'streamsb', 'vidstreaming'],
    'zoro': ['rapid-cloud', 'streamsb', 'streamtape'],
    '9anime': ['vidstream', 'mycloud', 'streamtape'],
    'animepahe': ['kwik'],
  };

  /// Default video provider
  static const String defaultProvider = 'gogoanime';

  /// Default video server
  static const String defaultServer = 'gogocdn';

  /// Jikan API Configuration
  static const int jikanPageSize = 25;
  static const int jikanMaxSearchResults = 100;

  /// Cache Configuration
  static const Duration cacheExpiry = Duration(hours: 24);
  static const int maxCacheSize = 50; // MB

  /// Feature Flags
  static const bool enableConsumet = true; // Set to false to disable video streaming
  static const bool enableJikan = true; // Set to false to use only Consumet
  static const bool enableCaching = true;
  static const bool enableDebugLogs = true;

  /// Migration Mode
  ///
  /// During migration, we can run both APIs in parallel
  /// Set to true to compare results between old and new APIs
  static const bool migrationMode = false;
  static const bool keepAniTubeApi = true; // Keep during migration

  /// API Endpoints - Consumet

  /// Get anime search results
  static String consumetSearch(String query, {String provider = defaultProvider}) =>
      '$consumetBaseUrl/anime/$provider/$query';

  /// Get anime information and episodes
  static String consumetAnimeInfo(String animeId, {String provider = defaultProvider}) =>
      '$consumetBaseUrl/anime/$provider/info/$animeId';

  /// Get episode streaming links
  static String consumetEpisodeStream(
    String episodeId, {
    String provider = defaultProvider,
    String server = defaultServer,
  }) =>
      '$consumetBaseUrl/anime/$provider/watch/$episodeId?server=$server';

  /// Get recent episodes
  static String consumetRecentEpisodes({
    String provider = defaultProvider,
    int page = 1,
    String type = 'sub',
  }) =>
      '$consumetBaseUrl/anime/$provider/recent-episodes?page=$page&type=$type';

  /// Get top airing anime
  static String consumetTopAiring({
    String provider = defaultProvider,
    int page = 1,
  }) =>
      '$consumetBaseUrl/anime/$provider/top-airing?page=$page';

  /// Get anime by genre
  static String consumetGenre(
    String genre, {
    String provider = defaultProvider,
    int page = 1,
  }) =>
      '$consumetBaseUrl/anime/$provider/genre/$genre?page=$page';

  /// API Endpoints - Jikan

  /// Search anime on MyAnimeList
  static String jikanSearch({int page = 1}) =>
      '$jikanBaseUrl/anime?page=$page';

  /// Get anime details by MAL ID
  static String jikanAnimeDetails(int malId) =>
      '$jikanBaseUrl/anime/$malId';

  /// Get anime episodes by MAL ID
  static String jikanAnimeEpisodes(int malId, {int page = 1}) =>
      '$jikanBaseUrl/anime/$malId/episodes?page=$page';

  /// Get anime characters by MAL ID
  static String jikanAnimeCharacters(int malId) =>
      '$jikanBaseUrl/anime/$malId/characters';

  /// Get anime staff by MAL ID
  static String jikanAnimeStaff(int malId) =>
      '$jikanBaseUrl/anime/$malId/staff';

  /// Get anime recommendations by MAL ID
  static String jikanAnimeRecommendations(int malId) =>
      '$jikanBaseUrl/anime/$malId/recommendations';

  /// Get seasonal anime
  static String jikanSeasonal(int year, String season) =>
      '$jikanBaseUrl/seasons/$year/$season';

  /// Get current season anime
  static String jikanCurrentSeason() =>
      '$jikanBaseUrl/seasons/now';

  /// Get top anime
  static String jikanTopAnime({int page = 1, String type = 'anime'}) =>
      '$jikanBaseUrl/top/anime?page=$page&type=$type';

  /// Get anime by genre
  static String jikanAnimeByGenre(int genreId, {int page = 1}) =>
      '$jikanBaseUrl/anime?genres=$genreId&page=$page';

  /// Get all genres
  static String jikanGenres() =>
      '$jikanBaseUrl/genres/anime';

  /// Headers for API requests
  static Map<String, String> get headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  /// Consumet headers (with referer for video streaming)
  static Map<String, String> consumetHeaders({String? referer}) => {
        ...headers,
        if (referer != null) 'Referer': referer,
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
      };

  /// Validate Consumet URL
  static bool isConsumetConfigured() {
    return consumetBaseUrl != 'https://consumet-api-demo.onrender.com' &&
        consumetBaseUrl.isNotEmpty;
  }

  /// Get API status message
  static String getStatusMessage() {
    if (!isConsumetConfigured()) {
      return 'Consumet API not configured. Please deploy Consumet and update API_CONFIG.';
    }
    return 'APIs configured successfully';
  }

  /// Debug print configuration
  static void printConfig() {
    if (enableDebugLogs) {
      print('=== API Configuration ===');
      print('Consumet URL: $consumetBaseUrl');
      print('Consumet Configured: ${isConsumetConfigured()}');
      print('Jikan URL: $jikanBaseUrl');
      print('Default Provider: $defaultProvider');
      print('Default Server: $defaultServer');
      print('Migration Mode: $migrationMode');
      print('========================');
    }
  }
}
