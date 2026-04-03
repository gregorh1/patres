import 'package:flutter_test/flutter_test.dart';
import 'package:patres/models/author.dart';

void main() {
  group('Author', () {
    test('fromJson creates author from valid JSON', () {
      final json = {
        'id': 'augustyn',
        'name': 'Św. Augustyn z Hippony',
        'nameOriginal': 'Aurelius Augustinus Hipponensis',
        'dates': '354–430',
        'era': 'IV-V w.',
        'bio': 'Biskup Hippony.',
        'significance': 'Najważniejszy teolog.',
        'portraitAsset': 'assets/images/authors/augustyn.png',
      };

      final author = Author.fromJson(json);

      expect(author.id, 'augustyn');
      expect(author.name, 'Św. Augustyn z Hippony');
      expect(author.nameOriginal, 'Aurelius Augustinus Hipponensis');
      expect(author.dates, '354–430');
      expect(author.era, 'IV-V w.');
      expect(author.bio, 'Biskup Hippony.');
      expect(author.significance, 'Najważniejszy teolog.');
      expect(author.portraitAsset, 'assets/images/authors/augustyn.png');
    });

    test('fromJson handles missing optional fields', () {
      final json = {
        'id': 'anonim',
        'name': 'Anonim',
      };

      final author = Author.fromJson(json);

      expect(author.id, 'anonim');
      expect(author.name, 'Anonim');
      expect(author.nameOriginal, '');
      expect(author.dates, '');
      expect(author.era, '');
      expect(author.bio, '');
      expect(author.significance, '');
      expect(author.portraitAsset, isNull);
    });

    test('equality is based on id', () {
      const author1 = Author(
        id: 'augustyn',
        name: 'Św. Augustyn',
        nameOriginal: '',
        dates: '',
        era: '',
        bio: 'Bio 1',
        significance: '',
      );
      const author2 = Author(
        id: 'augustyn',
        name: 'Św. Augustyn z Hippony',
        nameOriginal: '',
        dates: '',
        era: '',
        bio: 'Bio 2',
        significance: '',
      );
      const author3 = Author(
        id: 'chryzostom',
        name: 'Św. Jan Chryzostom',
        nameOriginal: '',
        dates: '',
        era: '',
        bio: '',
        significance: '',
      );

      expect(author1, equals(author2));
      expect(author1, isNot(equals(author3)));
    });
  });
}
