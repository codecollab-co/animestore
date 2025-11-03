import 'package:anime_app/config/api_config.dart';
import 'package:anime_app/data/repositories/consumet_repository.dart';
import 'package:dio/dio.dart';

/// API Verification Utility
///
/// Use this to test if Consumet is deployed and working.
/// Run this before proceeding with full migration.
class ApiVerification {
  /// Verify Consumet API is accessible
  ///
  /// Returns true if Consumet is deployed and responding.
  static Future<ConsumetStatus> verifyConsumet() async {
    try {
      final dio = Dio();
      final consumet = ConsumetRepository(dio);

      // Test 1: Check if API is accessible
      final isAvailable = await consumet.isAvailable();
      if (!isAvailable) {
        return ConsumetStatus(
          isAvailable: false,
          message: 'Consumet API is not responding',
          needsDeployment: true,
        );
      }

      // Test 2: Try a simple search
      try {
        final results = await consumet.search('Naruto').timeout(
          const Duration(seconds: 10),
        );

        if (results.results.isEmpty) {
          return ConsumetStatus(
            isAvailable: true,
            message: 'Consumet is accessible but returned no results',
            needsDeployment: false,
            canSearch: false,
          );
        }

        // Test 3: Try to get anime info
        try {
          final animeInfo = await consumet
              .getAnimeInfo(results.results.first.id)
              .timeout(
                const Duration(seconds: 10),
              );

          final episodes = await consumet.getEpisodes(results.results.first.id);

          return ConsumetStatus(
            isAvailable: true,
            message: 'Consumet is fully functional! 🎉',
            needsDeployment: false,
            canSearch: true,
            canStream: episodes.isNotEmpty,
            testAnimeId: results.results.first.id,
            testAnimeTitle: results.results.first.title,
            episodeCount: episodes.length,
          );
        } catch (e) {
          return ConsumetStatus(
            isAvailable: true,
            message: 'Consumet search works, but anime info failed: $e',
            needsDeployment: false,
            canSearch: true,
            canStream: false,
          );
        }
      } catch (e) {
        return ConsumetStatus(
          isAvailable: true,
          message: 'Consumet is accessible but search failed: $e',
          needsDeployment: false,
          canSearch: false,
        );
      }
    } catch (e) {
      return ConsumetStatus(
        isAvailable: false,
        message: 'Failed to connect to Consumet: $e',
        needsDeployment: true,
      );
    }
  }

  /// Get current API configuration status
  static ApiConfigStatus getConfigStatus() {
    return ApiConfigStatus(
      consumetUrl: ApiConfig.consumetBaseUrl,
      isConsumetConfigured: ApiConfig.isConsumetConfigured(),
      jikanUrl: ApiConfig.jikanBaseUrl,
      enableConsumet: ApiConfig.enableConsumet,
      enableJikan: ApiConfig.enableJikan,
      migrationMode: ApiConfig.migrationMode,
      keepAniTube: ApiConfig.keepAniTubeApi,
    );
  }

  /// Print detailed verification report
  static Future<void> printVerificationReport() async {
    print('╔════════════════════════════════════════════════════════════════╗');
    print('║           ANIME API VERIFICATION REPORT                       ║');
    print('╚════════════════════════════════════════════════════════════════╝');
    print('');

    // Configuration
    final config = getConfigStatus();
    print('📋 Configuration:');
    print('   Consumet URL: ${config.consumetUrl}');
    print(
        '   Consumet Configured: ${config.isConsumetConfigured ? "✅ Yes" : "❌ No (using demo)"}');
    print('   Jikan URL: ${config.jikanUrl}');
    print('   Enable Consumet: ${config.enableConsumet ? "✅" : "❌"}');
    print('   Enable Jikan: ${config.enableJikan ? "✅" : "❌"}');
    print('   Keep AniTube: ${config.keepAniTube ? "✅" : "❌"}');
    print('');

    // Consumet Verification
    print('🔍 Testing Consumet API...');
    final consumetStatus = await verifyConsumet();
    print(
        '   Status: ${consumetStatus.isAvailable ? "✅ Available" : "❌ Unavailable"}');
    print('   Message: ${consumetStatus.message}');
    if (consumetStatus.canSearch) {
      print('   Search: ✅ Working');
    }
    if (consumetStatus.canStream) {
      print('   Streaming: ✅ Working');
      print('   Test Anime: ${consumetStatus.testAnimeTitle}');
      print('   Episodes: ${consumetStatus.episodeCount}');
    }
    print('');

    // Recommendations
    print('💡 Recommendations:');
    if (consumetStatus.needsDeployment) {
      print('   ⚠️  Deploy Consumet API:');
      print('      1. Visit: https://railway.app/template/consumet');
      print('      2. Click "Deploy Now"');
      print('      3. Update lib/config/api_config.dart with your URL');
      print('');
    } else if (!consumetStatus.canStream) {
      print('   ⚠️  Consumet is accessible but streaming may not work');
      print('      Check server logs for errors');
      print('');
    } else {
      print('   ✅ Consumet is fully functional!');
      print('   ✅ Ready to proceed with migration');
      print('');
    }

    print('╚════════════════════════════════════════════════════════════════╝');
  }

  /// Quick test for development
  static Future<bool> quickTest() async {
    final status = await verifyConsumet();
    return status.isAvailable && status.canSearch;
  }
}

/// Consumet verification status
class ConsumetStatus {
  final bool isAvailable;
  final String message;
  final bool needsDeployment;
  final bool canSearch;
  final bool canStream;
  final String? testAnimeId;
  final String? testAnimeTitle;
  final int? episodeCount;

  ConsumetStatus({
    required this.isAvailable,
    required this.message,
    required this.needsDeployment,
    this.canSearch = false,
    this.canStream = false,
    this.testAnimeId,
    this.testAnimeTitle,
    this.episodeCount,
  });
}

/// API configuration status
class ApiConfigStatus {
  final String consumetUrl;
  final bool isConsumetConfigured;
  final String jikanUrl;
  final bool enableConsumet;
  final bool enableJikan;
  final bool migrationMode;
  final bool keepAniTube;

  ApiConfigStatus({
    required this.consumetUrl,
    required this.isConsumetConfigured,
    required this.jikanUrl,
    required this.enableConsumet,
    required this.enableJikan,
    required this.migrationMode,
    required this.keepAniTube,
  });
}
