import 'package:flutter_test/flutter_test.dart';
import 'package:anime_app/data/repositories/jikan_repository.dart';

void main() {
  group('JikanRepository', () {
    late JikanRepository repository;

    setUp(() {
      repository = JikanRepository();
    });

    test('search returns anime list', () async {
      final searchResult = await repository.search('Naruto');

      expect(searchResult.results, isNotEmpty);
      expect(searchResult.results.first.title, contains('Naruto'));
      expect(searchResult.results.first.id, isNotEmpty);
      expect(searchResult.results.first.imageUrl, isNotEmpty);
    });

    test('getAnimeDetails returns full details', () async {
      // MAL ID 1 = Cowboy Bebop
      final details = await repository.getAnimeDetails(1);

      expect(details.id, equals('1'));
      expect(details.title, isNotEmpty);
      expect(details.synopsis, isNotEmpty);
      expect(details.genres, isNotEmpty);

      // Note: episodes are fetched separately now via getEpisodes()
      final episodes = await repository.getEpisodes(1);
      expect(episodes, isNotEmpty);
    });

    test('getCurrentSeasonAnime returns seasonal anime', () async {
      final seasonalAnime = await repository.getCurrentSeasonAnime();

      expect(seasonalAnime, isNotEmpty);
      expect(seasonalAnime.first.id, isNotEmpty);
      expect(seasonalAnime.first.title, isNotEmpty);
    });

    test('getTopAnime returns top-rated anime', () async {
      final topAnime = await repository.getTopAnime();

      expect(topAnime, isNotEmpty);
      expect(topAnime.length, greaterThan(10));
    });

    test('getGenres returns list of genres', () async {
      final genres = await repository.getGenres();

      expect(genres, isNotEmpty);
      expect(genres.any((g) => g.name == 'Action'), isTrue);
      expect(genres.any((g) => g.name == 'Comedy'), isTrue);
    });

    test('getRecommendations returns similar anime', () async {
      // MAL ID 1 = Cowboy Bebop
      final recommendations = await repository.getRecommendations(1);

      // Might be empty if no recommendations
      expect(recommendations, isA<List>());
    });

    test('getAnimeByGenre returns genre-filtered anime', () async {
      // Genre ID 1 = Action
      final actionAnime = await repository.getAnimeByGenre(1);

      expect(actionAnime, isNotEmpty);
    });

    test('isAvailable returns true when API is working', () async {
      final isAvailable = await repository.isAvailable();

      expect(isAvailable, isTrue);
    });

    test('search with pagination works', () async {
      final page1 = await repository.search('One Piece', page: 1);
      final page2 = await repository.search('One Piece', page: 2);

      expect(page1.results, isNotEmpty);
      expect(page2.results, isNotEmpty);
      // Results should be different between pages
      expect(page1.results.first.id, isNot(equals(page2.results.first.id)));
    });
  });
}
