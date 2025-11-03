# Anime API Migration Recommendation
## Replacing AniTube Crawler API

**Analysis Date:** January 2025
**Current API:** anitube_crawler_api (GitHub: sc4v3ng3r/anitube_crawler_api)

---

## Executive Summary

After comprehensive research of anime APIs available in 2025, I recommend migrating from the **anitube_crawler_api** to one of the following alternatives based on your requirements:

1. **Best Overall Choice:** Consumet API (self-hosted) + Jikan API (metadata)
2. **Easiest Migration:** Jikan API alone (no video streaming)
3. **Most Features:** Consumet API (requires self-hosting since 2025)

---

## Current State Analysis

### AniTube Crawler API
**Repository:** https://github.com/sc4v3ng3r/anitube_crawler_api
**Version:** 1.0.1 (referenced in pubspec.yaml)

**Capabilities:**
- Fetches anime and episode data from Brazilian Anitube website
- Parses HTML pages for data extraction
- Returns formatted data model classes
- Provides pagination support
- Search functionality

**Limitations & Risks:**
1. ⚠️ **Region-Specific:** Only scrapes Brazilian Anitube (anitube.site)
2. ⚠️ **Fragile:** Web scraping breaks when site structure changes
3. ⚠️ **Legal Risk:** Scraping may violate terms of service
4. ⚠️ **Maintenance:** Requires constant updates when site changes
5. ⚠️ **Limited Data:** Only Brazilian/Portuguese content
6. ⚠️ **No Official Support:** Community-maintained package (6 stars, 1 fork)

---

## Recommended Alternatives

### Option 1: Consumet API (Best for Video Streaming) 🌟

**Website:** https://docs.consumet.org
**GitHub:** https://github.com/consumet/api.consumet.org
**Type:** REST API (self-hosted required since 2025)

#### Capabilities ✅
- **Video Streaming:** Direct streaming links for episodes
- **Multiple Providers:** GogoAnime, 9anime, Zoro, Crunchyroll, Enime, BiliBili
- **Metadata:** Anime details, episodes, characters, staff
- **Search:** Cross-provider search functionality
- **Pagination:** Built-in pagination support
- **Recent Episodes:** Track latest releases
- **Quality Options:** Multiple video quality streams
- **Subtitles:** Multi-language subtitle support

#### Providers Supported
1. **GogoAnime** (Default, most reliable)
2. **Zoro** (High quality, fast)
3. **9anime**
4. **Crunchyroll** (Official, but may require premium)
5. **Enime**
6. **BiliBili**

#### API Endpoints
```
Base: https://your-hosted-instance.com/

# Search
GET /anime/gogoanime/{query}

# Anime Info
GET /anime/gogoanime/info/{id}

# Episode Streaming Links
GET /anime/gogoanime/watch/{episodeId}?server={serverName}

# Recent Episodes
GET /anime/gogoanime/recent-episodes?page={page}&type={type}

# Top Airing
GET /anime/gogoanime/top-airing?page={page}
```

#### Dart/Flutter Integration
**No official Dart package**, but easy HTTP integration:

```dart
// Using dio (already in your pubspec.yaml)
class ConsumetRepository {
  final Dio _dio;
  final String baseUrl;

  ConsumetRepository(this._dio, {required this.baseUrl});

  Future<AnimeSearchResults> search(String query) async {
    final response = await _dio.get('$baseUrl/anime/gogoanime/$query');
    return AnimeSearchResults.fromJson(response.data);
  }

  Future<AnimeDetails> getAnimeInfo(String id) async {
    final response = await _dio.get('$baseUrl/anime/gogoanime/info/$id');
    return AnimeDetails.fromJson(response.data);
  }

  Future<EpisodeStreamingLinks> getStreamingLinks(String episodeId) async {
    final response = await _dio.get(
      '$baseUrl/anime/gogoanime/watch/$episodeId',
      queryParameters: {'server': 'gogocdn'},
    );
    return EpisodeStreamingLinks.fromJson(response.data);
  }
}
```

#### Pros ✅
- ✅ Direct video streaming links (most important for your app)
- ✅ Multiple quality options
- ✅ Multiple provider fallbacks
- ✅ Active development (2024-2025)
- ✅ Comprehensive documentation
- ✅ RESTful API (easy integration)
- ✅ Handles video hosting complexity
- ✅ Multi-language subtitle support

#### Cons ❌
- ❌ **Requires self-hosting** (no public instance since 2025)
- ❌ Legal concerns (scraping copyrighted content)
- ❌ No official Dart package (need custom HTTP wrapper)
- ❌ Self-hosting costs (server/cloud hosting required)
- ❌ Maintenance overhead (keeping instance updated)

#### Self-Hosting Requirements
```bash
# Docker deployment (recommended)
docker run -p 3000:3000 ghcr.io/consumet/api:latest

# Or Node.js
git clone https://github.com/consumet/api.consumet.org.git
npm install
npm start
```

**Hosting Options:**
- Railway.app (free tier available)
- Vercel (free tier with limitations)
- Heroku (paid)
- Your own VPS (AWS, DigitalOcean, etc.)

---

### Option 2: Jikan API (Best for Metadata) 🎯

**Website:** https://jikan.moe
**Pub.dev:** https://pub.dev/packages/jikan_api or https://pub.dev/packages/jikan_moe
**Type:** REST API + Official Dart Package

#### Capabilities ✅
- **Comprehensive Metadata:** Anime details, episodes, characters, staff
- **MyAnimeList Data:** Official MAL database
- **Search:** Advanced search with filters
- **Seasonal Anime:** Current season tracking
- **Schedules:** Daily release schedules
- **Top Rankings:** Top anime/manga by rating
- **Recommendations:** Related anime suggestions
- **Reviews & News:** Community reviews and news
- **Genre Filtering:** Extensive genre support
- **User Profiles:** MAL user statistics

#### API Endpoints (via Dart package)
```dart
import 'package:jikan_api/jikan_api.dart';

final jikan = Jikan();

// Search anime
final searchResults = await jikan.searchAnime(query: 'Naruto');

// Get anime details
final anime = await jikan.getAnime(1); // Anime ID

// Get episodes
final episodes = await jikan.getAnimeEpisodes(1);

// Seasonal anime
final seasonal = await jikan.getSeason(2025, Season.winter);

// Top anime
final topAnime = await jikan.getTopAnime();
```

#### Pros ✅
- ✅ **Official Dart package** (jikan_api or jikan_moe)
- ✅ No self-hosting required (free public API)
- ✅ MyAnimeList's extensive database
- ✅ Actively maintained (2025)
- ✅ Comprehensive metadata
- ✅ Well-documented
- ✅ Legal (uses public MAL data)
- ✅ Reliable uptime
- ✅ Rate limiting is reasonable (3 req/sec, 60 req/min)

#### Cons ❌
- ❌ **NO VIDEO STREAMING LINKS** (metadata only)
- ❌ Requires separate video source
- ❌ MyAnimeList data only (no other sources)
- ❌ Rate limits (may need caching)

#### Perfect For:
- Anime information, descriptions, ratings
- Episode lists and titles
- Character/staff information
- Recommendations and related anime
- Search functionality
- Genre filtering

**⚠️ Critical Limitation:** Jikan does NOT provide video streaming URLs. You would need to combine it with another service for video playback.

---

### Option 3: AniList API (GraphQL Alternative)

**Website:** https://anilist.co/
**Pub.dev:** https://pub.dev/packages/anilist (⚠️ Last updated 4 years ago)
**Type:** GraphQL API

#### Capabilities ✅
- **GraphQL API:** Flexible data queries
- **Metadata:** Anime, manga, characters, staff
- **User Tracking:** Watch lists, favorites
- **Social Features:** Reviews, comments
- **Recommendations:** AI-powered suggestions
- **Airing Schedule:** Upcoming episodes

#### API Example (GraphQL)
```dart
import 'package:graphql_flutter/graphql_flutter.dart';

const String searchQuery = '''
  query (\$search: String) {
    Page {
      media(search: \$search, type: ANIME) {
        id
        title {
          romaji
          english
        }
        episodes
        coverImage {
          large
        }
      }
    }
  }
''';

// Execute query with graphql_flutter package
```

#### Pros ✅
- ✅ GraphQL flexibility (request only needed data)
- ✅ Free public API
- ✅ Comprehensive anime database
- ✅ Active community
- ✅ Social features
- ✅ Legal and reliable

#### Cons ❌
- ❌ **NO VIDEO STREAMING** (metadata only)
- ❌ Dart package outdated (4 years old)
- ❌ Requires GraphQL knowledge
- ❌ More complex than REST
- ❌ Need to build custom wrapper

---

### Option 4: Hybrid Approach (RECOMMENDED) 🏆

**Combine Consumet (video) + Jikan/AniList (metadata)**

#### Why Hybrid?
1. **Jikan/AniList:** Reliable, legal metadata (descriptions, ratings, reviews)
2. **Consumet:** Video streaming links (the core feature your app needs)
3. **Best of Both Worlds:** Legal metadata + functional streaming

#### Architecture
```
User searches anime
    ↓
Jikan API → Search results with metadata
    ↓
User selects anime
    ↓
Jikan API → Anime details, episodes list
    ↓
User selects episode
    ↓
Consumet API → Streaming video URL
    ↓
Video Player → Plays episode
```

#### Implementation Strategy
```dart
class HybridAnimeRepository {
  final Jikan jikan;
  final ConsumetRepository consumet;

  // Use Jikan for search and metadata
  Future<List<AnimeItem>> search(String query) async {
    final results = await jikan.searchAnime(query: query);
    return results.map((e) => AnimeItem.fromJikan(e)).toList();
  }

  // Use Jikan for anime details
  Future<AnimeDetails> getAnimeDetails(int malId) async {
    final anime = await jikan.getAnime(malId);
    return AnimeDetails.fromJikan(anime);
  }

  // Use Consumet for video streaming
  Future<String> getEpisodeStreamUrl(String animeTitle, int episodeNumber) async {
    // Search on GogoAnime via Consumet
    final searchResults = await consumet.search(animeTitle);
    final animeId = searchResults.results.first.id;

    // Get episode streaming link
    final episodeId = '$animeId-episode-$episodeNumber';
    final streamData = await consumet.getStreamingLinks(episodeId);

    return streamData.sources.first.url; // Video URL
  }
}
```

#### Pros ✅
- ✅ Legal metadata source
- ✅ Functional video streaming
- ✅ Best user experience
- ✅ Reliable anime information
- ✅ Fallback options

#### Cons ❌
- ❌ Two API dependencies
- ❌ More complex implementation
- ❌ Still requires Consumet self-hosting
- ❌ Potential data sync issues (MAL ID ≠ GogoAnime ID)

---

## Migration Comparison Matrix

| Feature | AniTube Crawler | Consumet | Jikan | AniList | Hybrid |
|---------|----------------|----------|-------|---------|--------|
| **Video Streaming** | ✅ Yes | ✅ Yes | ❌ No | ❌ No | ✅ Yes |
| **Metadata Quality** | ⚠️ Limited | ✅ Good | ✅ Excellent | ✅ Excellent | ✅ Excellent |
| **Dart Package** | ✅ Yes (Git) | ❌ No | ✅ Yes | ⚠️ Outdated | ⚠️ Partial |
| **Self-Hosting Required** | ❌ No | ✅ Yes | ❌ No | ❌ No | ✅ Yes (partial) |
| **Legal Status** | ⚠️ Gray area | ⚠️ Gray area | ✅ Legal | ✅ Legal | ⚠️ Mixed |
| **Maintenance** | ⚠️ Community | ✅ Active | ✅ Active | ✅ Active | ✅ Active |
| **Multi-language** | ❌ PT-BR only | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| **Setup Complexity** | ⭐ Easy | ⭐⭐⭐ Hard | ⭐ Easy | ⭐⭐ Medium | ⭐⭐⭐⭐ Complex |
| **Ongoing Cost** | Free | $5-20/month | Free | Free | $5-20/month |

---

## Migration Plan

### Recommended: Hybrid Approach (Jikan + Consumet)

#### Phase 1: Setup Consumet (Week 1)

**Step 1.1: Deploy Consumet Instance**
```bash
# Option A: Railway.app (recommended for beginners)
1. Sign up at railway.app
2. Click "New Project" → "Deploy from GitHub"
3. Connect GitHub and deploy consumet/api.consumet.org
4. Note your deployment URL: https://your-app.up.railway.app

# Option B: Docker on VPS
1. Get a VPS (DigitalOcean, AWS, etc.)
2. Install Docker
3. Run: docker run -d -p 3000:3000 ghcr.io/consumet/api:latest
4. Note your URL: http://your-server-ip:3000
```

**Step 1.2: Test Consumet**
```bash
# Test endpoint
curl https://your-instance.com/anime/gogoanime/naruto

# Expected: JSON response with anime search results
```

#### Phase 2: Add Jikan Package (Week 1)

**Step 2.1: Update pubspec.yaml**
```yaml
dependencies:
  # Remove old API
  # anitube_crawler_api:
  #   git:
  #     url: git@github.com:sc4v3ng3r/anitube_crawler_api.git
  #     ref: 1.0.1

  # Add new APIs
  jikan_api: ^2.0.0  # Or jikan_moe for newer version
  dio: ^5.0.0  # Already present, for Consumet HTTP calls
```

**Step 2.2: Install**
```bash
flutter pub get
```

#### Phase 3: Create New Repositories (Week 2)

**Step 3.1: Create JikanRepository**
```dart
// lib/data/repositories/jikan_repository.dart
import 'package:jikan_api/jikan_api.dart';

class JikanRepository {
  final Jikan _jikan = Jikan();

  Future<List<AnimeItem>> search(String query) async {
    try {
      final results = await _jikan.searchAnime(query: query);
      return results.map((anime) => AnimeItem(
        id: anime.malId.toString(),
        title: anime.title ?? '',
        imageUrl: anime.imageUrl ?? '',
        // Map other fields
      )).toList();
    } catch (e) {
      throw Exception('Failed to search anime: $e');
    }
  }

  Future<AnimeDetails> getAnimeDetails(int malId) async {
    try {
      final anime = await _jikan.getAnime(malId);
      final episodes = await _jikan.getAnimeEpisodes(malId);

      return AnimeDetails(
        id: anime.malId.toString(),
        title: anime.title ?? '',
        description: anime.synopsis ?? '',
        imageUrl: anime.imageUrl ?? '',
        episodes: episodes.map((ep) => Episode(
          id: '${anime.malId}-episode-${ep.episodeId}',
          title: ep.title ?? 'Episode ${ep.episodeId}',
          episodeNumber: ep.episodeId ?? 0,
        )).toList(),
        // Map other fields
      );
    } catch (e) {
      throw Exception('Failed to get anime details: $e');
    }
  }
}
```

**Step 3.2: Create ConsumetRepository**
```dart
// lib/data/repositories/consumet_repository.dart
import 'package:dio/dio.dart';

class ConsumetRepository {
  final Dio _dio;
  final String baseUrl;

  ConsumetRepository(this._dio, {required this.baseUrl});

  Future<String> getEpisodeStreamUrl({
    required String animeTitle,
    required int episodeNumber,
  }) async {
    try {
      // Step 1: Search for anime on GogoAnime
      final searchResponse = await _dio.get(
        '$baseUrl/anime/gogoanime/$animeTitle',
      );

      if (searchResponse.data['results'].isEmpty) {
        throw Exception('Anime not found on GogoAnime');
      }

      final animeId = searchResponse.data['results'][0]['id'];

      // Step 2: Get anime info to find episode ID
      final infoResponse = await _dio.get(
        '$baseUrl/anime/gogoanime/info/$animeId',
      );

      final episodes = infoResponse.data['episodes'] as List;
      final episode = episodes.firstWhere(
        (ep) => ep['number'] == episodeNumber,
        orElse: () => throw Exception('Episode not found'),
      );

      // Step 3: Get streaming links
      final streamResponse = await _dio.get(
        '$baseUrl/anime/gogoanime/watch/${episode['id']}',
        queryParameters: {'server': 'gogocdn'},
      );

      final sources = streamResponse.data['sources'] as List;
      if (sources.isEmpty) {
        throw Exception('No streaming sources available');
      }

      // Return highest quality source
      return sources.first['url'];
    } catch (e) {
      throw Exception('Failed to get streaming URL: $e');
    }
  }

  Future<List<String>> getAvailableQualities(String episodeId) async {
    try {
      final response = await _dio.get(
        '$baseUrl/anime/gogoanime/watch/$episodeId',
        queryParameters: {'server': 'gogocdn'},
      );

      final sources = response.data['sources'] as List;
      return sources.map<String>((s) => s['quality'] as String).toList();
    } catch (e) {
      throw Exception('Failed to get qualities: $e');
    }
  }
}
```

**Step 3.3: Update AnimeRepository**
```dart
// lib/data/repositories/anime_repository.dart
class AnimeRepository {
  final JikanRepository _jikanRepo;
  final ConsumetRepository _consumetRepo;

  AnimeRepository({
    required JikanRepository jikanRepository,
    required ConsumetRepository consumetRepository,
  })  : _jikanRepo = jikanRepository,
        _consumetRepo = consumetRepository;

  // Use Jikan for search
  Future<AnimeListPageInfo> search(String query) async {
    final results = await _jikanRepo.search(query);
    return AnimeListPageInfo(results: results);
  }

  // Use Jikan for details
  Future<AnimeDetails> getAnimeDetails(String animeId) async {
    final malId = int.parse(animeId);
    return await _jikanRepo.getAnimeDetails(malId);
  }

  // Use Consumet for streaming
  Future<EpisodeDetails> getEpisodeDetails(String episodeId) async {
    // Parse episodeId format: "malId-episode-number"
    final parts = episodeId.split('-episode-');
    final malId = int.parse(parts[0]);
    final episodeNumber = int.parse(parts[1]);

    // Get anime title from Jikan
    final anime = await _jikanRepo.getAnimeDetails(malId);

    // Get streaming URL from Consumet
    final videoUrl = await _consumetRepo.getEpisodeStreamUrl(
      animeTitle: anime.title,
      episodeNumber: episodeNumber,
    );

    return EpisodeDetails(
      id: episodeId,
      title: 'Episode $episodeNumber',
      videoUrl: videoUrl,
    );
  }
}
```

#### Phase 4: Update BLoCs (Week 2-3)

**Step 4.1: Update ApplicationBloc**
```dart
// lib/logic/blocs/application/application_bloc.dart

// Update constructor to use new repositories
ApplicationBloc({
  required AnimeRepository animeRepository,
  required UserRepository userRepository,
  required JikanRepository jikanRepository,
  required ConsumetRepository consumetRepository,
})  : _animeRepository = AnimeRepository(
        jikanRepository: jikanRepository,
        consumetRepository: consumetRepository,
      ),
      _userRepository = userRepository,
      super(ApplicationInitial());
```

**Step 4.2: Update main.dart**
```dart
// lib/main.dart
void main() {
  final dio = Dio();

  final jikanRepo = JikanRepository();
  final consumetRepo = ConsumetRepository(
    dio,
    baseUrl: 'https://your-consumet-instance.com', // Your deployed URL
  );

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<ApplicationBloc>(
          create: (context) => ApplicationBloc(
            animeRepository: AnimeRepository(
              jikanRepository: jikanRepo,
              consumetRepository: consumetRepo,
            ),
            userRepository: UserRepository(),
            jikanRepository: jikanRepo,
            consumetRepository: consumetRepo,
          )..add(const AppInitializeRequested()),
        ),
        // ... other providers
      ],
      child: MyApp(),
    ),
  );
}
```

#### Phase 5: Update Models (Week 3)

**Step 5.1: Create Conversion Utilities**
```dart
// lib/models/converters/jikan_converter.dart
extension AnimeItemFromJikan on Anime {
  AnimeItem toAnimeItem() {
    return AnimeItem(
      id: malId.toString(),
      title: title ?? '',
      imageUrl: imageUrl ?? '',
      // Map other fields
    );
  }
}

extension AnimeDetailsFromJikan on Anime {
  AnimeDetails toAnimeDetails(List<AnimeEpisode> episodes) {
    return AnimeDetails(
      id: malId.toString(),
      title: title ?? '',
      description: synopsis ?? '',
      imageUrl: imageUrl ?? '',
      episodes: episodes.map((ep) => Episode(
        id: '${malId}-episode-${ep.episodeId}',
        title: ep.title ?? 'Episode ${ep.episodeId}',
        episodeNumber: ep.episodeId ?? 0,
      )).toList(),
      genres: genres?.map((g) => g.name).toList() ?? [],
      rating: score ?? 0.0,
      status: status ?? '',
      // Map other fields
    );
  }
}
```

#### Phase 6: Testing (Week 4)

**Step 6.1: Unit Tests**
```dart
// test/repositories/jikan_repository_test.dart
void main() {
  group('JikanRepository', () {
    test('search returns anime list', () async {
      final repo = JikanRepository();
      final results = await repo.search('Naruto');

      expect(results, isNotEmpty);
      expect(results.first.title, contains('Naruto'));
    });
  });
}
```

**Step 6.2: Integration Tests**
```dart
// test/integration/anime_flow_test.dart
void main() {
  testWidgets('complete anime watching flow', (tester) async {
    // 1. Search anime
    // 2. Select anime
    // 3. View details
    // 4. Play episode
    // 5. Verify video loads
  });
}
```

**Step 6.3: Manual Testing Checklist**
- [ ] Search anime returns results
- [ ] Anime details load correctly
- [ ] Episode list displays
- [ ] Video plays when episode selected
- [ ] Video quality selection works
- [ ] Next/Previous episode works
- [ ] Add to My List works
- [ ] Episode watch tracking works

#### Phase 7: Deployment (Week 4)

**Step 7.1: Configuration**
```dart
// lib/config/api_config.dart
class ApiConfig {
  static const String consumetBaseUrl =
    String.fromEnvironment('CONSUMET_URL',
      defaultValue: 'https://your-consumet-instance.com');

  static const String jikanBaseUrl = 'https://api.jikan.moe/v4';
}
```

**Step 7.2: Environment Variables**
```bash
# .env
CONSUMET_URL=https://your-consumet-instance.com

# Run app
flutter run --dart-define=CONSUMET_URL=https://your-consumet-instance.com
```

**Step 7.3: Build Release**
```bash
# Android
flutter build apk --release --dart-define=CONSUMET_URL=https://your-instance.com

# iOS
flutter build ios --release --dart-define=CONSUMET_URL=https://your-instance.com
```

---

## Alternative: Jikan Only (No Streaming)

If you want to avoid self-hosting Consumet and only provide anime **information** (no video streaming):

### Migration Steps
1. Replace anitube_crawler_api with jikan_api
2. Update repositories to use Jikan
3. Remove video playback features
4. Focus on anime discovery, tracking, and recommendations

**Pros:**
- ✅ No hosting costs
- ✅ Legal and reliable
- ✅ Easy maintenance

**Cons:**
- ❌ No video streaming (major feature loss)
- ❌ Not suitable for current app functionality

---

## Cost Analysis

### Current (AniTube Crawler)
- **Hosting:** $0/month (scraping external site)
- **Maintenance:** High (breaks when site changes)
- **Legal Risk:** Medium-High

### Option 1: Consumet + Jikan
- **Hosting:** $5-20/month (Railway, VPS, or cloud)
- **Maintenance:** Low-Medium (API updates)
- **Legal Risk:** Medium (scraping content, but from aggregators)

### Option 2: Jikan Only
- **Hosting:** $0/month (free API)
- **Maintenance:** Very Low
- **Legal Risk:** None (using public MAL data)

---

## Legal Considerations

### ⚠️ Important Notice

**Consumet API Legal Status:**
> "Commercial utilization may lead to serious consequences, including potential site takedown measures. Ensure that you understand the legal implications before using this API."

**Recommendation:**
1. **Non-Commercial Use:** Keep app free without ads
2. **Educational Purpose:** Position as learning/research project
3. **Terms of Service:** Add disclaimer about content sources
4. **Respect Rate Limits:** Don't abuse APIs
5. **Consider Licensing:** For commercial use, explore official APIs (Crunchyroll API, Funimation, etc.)

### Crunchyroll Official API
If you plan to monetize, consider:
- Crunchyroll Partner API (requires approval)
- Funimation API (limited availability)
- HiDive API (emerging platform)

---

## Final Recommendation

### 🏆 Best Choice: Hybrid (Jikan + Consumet)

**Why:**
1. ✅ Maintains video streaming (core feature)
2. ✅ Legal metadata from MyAnimeList
3. ✅ Better anime information quality
4. ✅ Multi-language support
5. ✅ Multiple video sources (fallback options)
6. ✅ Active development and community
7. ✅ Scalable architecture

**Next Steps:**
1. Deploy Consumet instance (1-2 hours)
2. Add jikan_api package (15 minutes)
3. Create new repositories (2-4 hours)
4. Update BLoCs (4-8 hours)
5. Test thoroughly (8-16 hours)
6. Deploy updated app

**Total Effort:** ~1 week full-time or 2-3 weeks part-time

---

## Questions?

Feel free to ask about:
- Consumet deployment help
- Jikan API integration examples
- Migration code samples
- Alternative providers
- Legal concerns
- Cost optimization

---

**Document Version:** 1.0
**Last Updated:** January 2025
**Status:** Ready for Implementation
