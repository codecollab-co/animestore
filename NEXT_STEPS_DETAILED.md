# Next Steps - Detailed Migration Plan

**Current Status:** 75% Complete, 139 errors remaining
**Time to Complete:** 8-12 hours

---

## 🎯 Phase 1: Update AnimeRepository (PRIORITY 1)

**File:** `lib/data/repositories/anime_repository.dart`
**Current Issues:** Still uses AniTube API directly
**Estimated Time:** 1-2 hours

### Changes Needed:

The old `AnimeRepository` needs to be rewritten to use Jikan + Consumet instead of AniTube:

```dart
// OLD (AniTube):
Future<AnimeListPageInfo> getAnimeListPageData({required int pageNumber}) {
  return _api.getAnimeListPageData(pageNumber: pageNumber);
}

// NEW (Jikan + Consumet):
Future<List<AnimeModel>> getAnimeListPage({required int pageNumber}) async {
  // Use Jikan search or top anime endpoint
  final topAnime = await _jikanRepository.getTopAnime(page: pageNumber);
  return topAnime;
}
```

### Methods to Update:

1. **getHomePageData()** → Return HomePageModel
   - Use Jikan getCurrentSeasonAnime() for recent
   - Use Jikan getTopAnime() for top
   - Use Consumet getRecentEpisodes() for latest episodes
   - Use Consumet getTopAiring() for day releases

2. **getAnimeListPageData()** → Return List<AnimeModel>
   - Use Jikan search or getTopAnime()

3. **getGenresAvailable()** → Return List<GenreModel>
   - Use Jikan getGenres()

4. **getAnimeDetails()** → Return AnimeModel
   - Use Jikan getAnimeDetails()

5. **getAnimeEpisodes()** → Return List<EpisodeModel>
   - Use Jikan getEpisodes()
   - Merge with Consumet for streaming URLs

### Strategy Options:

**Option A: Rewrite completely** (Recommended)
- Clean implementation
- Use Jikan + Consumet directly
- No legacy code
- **Time:** 2 hours

**Option B: Wrapper approach**
- Keep interface similar
- Translate calls to Jikan/Consumet
- Easier migration for BLoCs
- **Time:** 1.5 hours

---

## 🎯 Phase 2: Update ApplicationBloc (PRIORITY 1)

**File:** `lib/logic/blocs/application/application_bloc.dart`
**Current Issues:** References old repository methods and AniTube exceptions
**Estimated Time:** 1-2 hours

### Changes Needed:

1. **Remove AniTube imports:**
```dart
// Remove:
import 'package:anitube_crawler_api/anitube_crawler_api.dart';

// Keep:
import 'package:anime_app/models/anime_model.dart';
import 'package:anime_app/models/episode_model.dart';
```

2. **Update exception handling:**
```dart
// Remove:
} on CrawlerApiException catch (e) {

// Replace with:
} catch (e) {
```

3. **Update _initDataFromNetwork:**
```dart
// OLD:
final homePageData = await _animeRepository.getHomePageData();
emit(state.copyWith(
  mostRecentAnimeList: homePageData.mostRecentAnimes,
  topAnimeList: homePageData.mostShowedAnimes,
  latestEpisodes: homePageData.latestEpisodes,
  dayReleaseList: homePageData.dayReleases,
));

// NEW:
final homePageData = await _animeRepository.getHomePageData();
emit(state.copyWith(
  mostRecentAnimeList: homePageData.currentlyAiring,
  topAnimeList: homePageData.topRated,
  latestEpisodes: homePageData.recentlyUpdated, // Episodes from anime
  dayReleaseList: homePageData.popularThisSeason,
));
```

4. **Update _loadAnimeListInternal:**
```dart
// OLD:
final cacheList = <AnimeItem>[];
final data = await _animeRepository.getAnimeListPageData(pageNumber: pageCounter);
cacheList.addAll(data.animes);
maxPageNumber = int.parse(data.maxPageNumber);

// NEW:
final cacheList = <AnimeModel>[];
final data = await _animeRepository.getAnimeListPage(pageNumber: pageCounter);
cacheList.addAll(data);
maxPageNumber = 100; // Or get from pagination metadata
```

5. **Update genre loading:**
```dart
// OLD:
final genres = await _animeRepository.getGenresAvailable();
emit(state.copyWith(
  genreList: genres.map((g) => g.title).toList(),
));

// NEW:
final genres = await _animeRepository.getGenresAvailable();
emit(state.copyWith(
  genreList: genres.map((g) => g.name).toList(),
));
```

6. **Update MyAnime methods:**
```dart
// OLD:
final updatedMap = Map<String, AnimeItem>.from(state.myAnimeMap);
await _userRepository.addAnimeToList(event.animeId, event.anime);

// NEW:
final updatedMap = Map<String, AnimeModel>.from(state.myAnimeMap);
await _userRepository.addAnimeToList(event.animeId, event.anime);
```

---

## 🎯 Phase 3: Update Search & Genre Repositories (PRIORITY 2)

### SearchRepository
**File:** `lib/data/repositories/search_repository.dart`
**Estimated Time:** 30 minutes

```dart
// OLD:
Future<List<AnimeItem>> search(String query) async {
  return await _api.searchAnime(query: query);
}

// NEW:
Future<SearchResultModel> search(String query, {int page = 1}) async {
  return await _jikanRepository.search(query, page: page);
}
```

### GenreRepository
**File:** `lib/data/repositories/genre_repository.dart`
**Estimated Time:** 30 minutes

```dart
// OLD:
Future<List<Genre>> getGenres() async {
  return await _api.getGenres();
}

// NEW:
Future<List<GenreModel>> getGenres() async {
  return await _jikanRepository.getGenres();
}

// OLD:
Future<List<AnimeItem>> getAnimeByGenre(String genreId) async {
  return await _api.getAnimeByGenre(genreId);
}

// NEW:
Future<List<AnimeModel>> getAnimeByGenre(String genreId) async {
  final genreIdInt = int.parse(genreId);
  return await _jikanRepository.getAnimeByGenre(genreIdInt);
}
```

---

## 🎯 Phase 4: Update Remaining BLoCs (PRIORITY 2)

### SearchBloc
**File:** `lib/logic/blocs/search/search_bloc.dart`
**Estimated Time:** 30 minutes

**Changes:**
- Update search_state.dart to use AnimeModel
- Update event handlers to use SearchResultModel
- Remove AniTube imports

### GenreBloc
**File:** `lib/logic/blocs/genre/genre_bloc.dart`
**Estimated Time:** 30 minutes

**Changes:**
- Update genre_state.dart to use GenreModel, AnimeModel
- Update event handlers
- Remove AniTube imports

### VideoPlayerBloc
**File:** `lib/logic/blocs/video_player/video_player_state.dart`
**Estimated Time:** 30 minutes

**Changes:**
- Update to use EpisodeModel instead of EpisodeDetails
- Update streaming URL handling

---

## 🎯 Phase 5: Update DatabaseProvider (PRIORITY 3)

**File:** `lib/database/DatabaseProvider.dart`
**Estimated Time:** 1 hour

### Changes Needed:

1. **Update table schemas** to store JSON or normalized data:

```dart
// Option A: JSON column (simpler)
CREATE TABLE my_anime (
  id TEXT PRIMARY KEY,
  data TEXT NOT NULL  -- JSON serialized AnimeModel
);

// Option B: Normalized (more complex)
CREATE TABLE my_anime (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  image_url TEXT,
  synopsis TEXT,
  rating REAL,
  -- ... more columns
);
```

2. **Update methods:**
```dart
// OLD:
Future<Map<String, AnimeItem>> loadMyAnimeList() async {
  // Parse from JSON to AnimeItem
}

// NEW:
Future<Map<String, AnimeModel>> loadMyAnimeList() async {
  final db = await database;
  final maps = await db.query('my_anime');

  return {
    for (var map in maps)
      map['id'] as String: AnimeModel.fromJson(
        jsonDecode(map['data'] as String)
      )
  };
}

// Similar for addAnimeToList, removeAnimeFromList, etc.
```

---

## 🎯 Phase 6: Update UI Pages (PRIORITY 3)

### HomePage.dart
**File:** `lib/ui/pages/HomePage.dart`
**Estimated Time:** 30 minutes

**Changes:**
- Update to use AnimeModel instead of AnimeItem
- Update to use EpisodeModel instead of EpisodeItem
- Properties like `anime.imageUrl` remain the same

### AnimeDetailsScreen.dart
**File:** `lib/ui/pages/AnimeDetailsScreen.dart`
**Estimated Time:** 30 minutes

**Changes:**
- Update to use AnimeModel and EpisodeModel
- Update episode list rendering
- Update streaming URL handling

### Other UI Files (~10-15 files)
**Estimated Time:** 2-3 hours

**Common changes:**
- Replace `AnimeItem` → `AnimeModel`
- Replace `EpisodeItem` → `EpisodeModel`
- Replace `AnimeDetails` → `AnimeModel` with episodes
- Update property access (most will be the same)

**Files likely affected:**
- lib/ui/widgets/AnimeCard.dart
- lib/ui/widgets/EpisodeCard.dart
- lib/ui/pages/MyListPage.dart
- lib/ui/pages/SearchPage.dart
- lib/ui/pages/GenrePage.dart
- And others...

---

## 📋 Migration Checklist

### Phase 1: Core Repositories (2-3 hours)
- [ ] Rewrite AnimeRepository to use Jikan + Consumet
- [ ] Update SearchRepository to use Jikan
- [ ] Update GenreRepository to use Jikan
- [ ] Test repository methods

### Phase 2: BLoC Logic (2-3 hours)
- [ ] Update ApplicationBloc event handlers
- [ ] Update SearchBloc
- [ ] Update GenreBloc
- [ ] Update VideoPlayerBloc
- [ ] Remove all AniTube imports
- [ ] Remove CrawlerApiException handling

### Phase 3: Database (1 hour)
- [ ] Update DatabaseProvider schema
- [ ] Update loadMyAnimeList method
- [ ] Update addAnimeToList method
- [ ] Update removeAnimeFromList method
- [ ] Update episode watched methods
- [ ] Test database operations

### Phase 4: UI (3-4 hours)
- [ ] Update HomePage.dart
- [ ] Update AnimeDetailsScreen.dart
- [ ] Update SearchPage.dart
- [ ] Update GenrePage.dart
- [ ] Update MyListPage.dart
- [ ] Update all widget files
- [ ] Test UI rendering

### Phase 5: Testing & Polish (2-3 hours)
- [ ] Deploy Consumet to Railway
- [ ] Test Jikan API calls
- [ ] Test Consumet streaming
- [ ] Test search functionality
- [ ] Test anime details
- [ ] Test episode watching
- [ ] Test my list functionality
- [ ] Performance testing
- [ ] Fix any runtime issues

---

## 🚀 Quick Win Strategy

To get compilable code faster, do this in order:

1. **Fix AnimeRepository** (1-2 hours)
   - This will fix most repository-related errors

2. **Fix ApplicationBloc** (1 hour)
   - This will fix most BLoC errors

3. **Fix DatabaseProvider** (1 hour)
   - This will fix database errors

4. **Batch fix UI files** (2-3 hours)
   - Simple find-replace for most files
   - `AnimeItem` → `AnimeModel`
   - `EpisodeItem` → `EpisodeModel`

**Total to compilable:** ~5-7 hours

Then test and polish: 2-3 hours

---

## 💡 Implementation Tips

### 1. Use Find & Replace Wisely

Many changes are simple type replacements:
```
Find: AnimeItem
Replace: AnimeModel

Find: EpisodeItem
Replace: EpisodeModel

Find: CrawlerApiException
Replace: Exception
```

### 2. Property Access Is Mostly The Same

Both old and new models use similar property names:
```dart
// OLD & NEW (same):
anime.title
anime.imageUrl
anime.id

// Changed:
anime.category → anime.type
episode.videoId → episode.id
```

### 3. Database Strategy

**Recommended:** JSON column approach for speed
- Simpler implementation
- Faster to implement
- Flexible for future changes
- AnimeModel already has toJson()/fromJson()

---

## ⏰ Time Estimates by Priority

**High Priority (Must Have):**
- AnimeRepository: 2 hours
- ApplicationBloc: 1 hour
- DatabaseProvider: 1 hour
- **Subtotal: 4 hours**

**Medium Priority (Important):**
- Search/GenreRepository: 1 hour
- Other BLoCs: 1.5 hours
- HomePage & AnimeDetails: 1 hour
- **Subtotal: 3.5 hours**

**Lower Priority (Polish):**
- Other UI files: 2-3 hours
- Testing & fixes: 2-3 hours
- **Subtotal: 4-6 hours**

**TOTAL: 11.5-13.5 hours**

---

## 🎯 Recommended Approach

**Day 1 (4-5 hours):**
1. Rewrite AnimeRepository (2 hours)
2. Update ApplicationBloc (1 hour)
3. Update DatabaseProvider (1 hour)
4. Test compilation (30 min)

**Day 2 (3-4 hours):**
5. Update Search/GenreRepository (1 hour)
6. Update remaining BLoCs (1.5 hours)
7. Update HomePage & AnimeDetails (1 hour)
8. Test compilation (30 min)

**Day 3 (3-4 hours):**
9. Batch update UI files (2-3 hours)
10. Final compilation fixes (1 hour)

**Day 4 (2-3 hours):**
11. Deploy Consumet
12. Integration testing
13. Bug fixes

---

**Total Timeline:** 3-4 days of focused work
**OR:** 12-16 hours of continuous work

Would you like me to start with Phase 1 (AnimeRepository)?
