import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patres/services/author_service.dart';

class _FakeAssetBundle extends CachingAssetBundle {
  final Map<String, dynamic> authorsData;

  _FakeAssetBundle(this.authorsData);

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    if (key == 'assets/authors.json') {
      return json.encode(authorsData);
    }
    throw Exception('Asset not found: $key');
  }

  @override
  Future<ByteData> load(String key) async {
    throw UnimplementedError();
  }
}

void main() {
  final testData = {
    'authors': [
      {
        'id': 'augustyn',
        'name': 'Św. Augustyn z Hippony',
        'nameOriginal': 'Aurelius Augustinus',
        'dates': '354–430',
        'era': 'IV-V w.',
        'bio': 'Test bio.',
        'significance': 'Test significance.',
      },
      {
        'id': 'chryzostom',
        'name': 'Św. Jan Chryzostom',
        'nameOriginal': 'Ἰωάννης ὁ Χρυσόστομος',
        'dates': '349–407',
        'era': 'IV-V w.',
        'bio': 'Test bio 2.',
        'significance': 'Test significance 2.',
      },
    ],
    'authorMapping': {
      'Św. Augustyn z Hippony': 'augustyn',
      'Św. Jan Chryzostom': 'chryzostom',
    },
  };

  group('AuthorService', () {
    late _FakeAssetBundle bundle;
    late AuthorService service;

    setUp(() {
      bundle = _FakeAssetBundle(testData);
      service = AuthorService(assetBundle: bundle);
    });

    test('loadAuthors returns all authors', () async {
      final authors = await service.loadAuthors();
      expect(authors.length, 2);
      expect(authors[0].id, 'augustyn');
      expect(authors[1].id, 'chryzostom');
    });

    test('loadAuthorMapping returns name-to-id map', () async {
      final mapping = await service.loadAuthorMapping();
      expect(mapping['Św. Augustyn z Hippony'], 'augustyn');
      expect(mapping['Św. Jan Chryzostom'], 'chryzostom');
    });

    test('getAuthorById returns correct author', () async {
      final author = await service.getAuthorById('augustyn');
      expect(author, isNotNull);
      expect(author!.name, 'Św. Augustyn z Hippony');
      expect(author.dates, '354–430');
    });

    test('getAuthorById returns null for unknown id', () async {
      final author = await service.getAuthorById('unknown');
      expect(author, isNull);
    });

    test('getAuthorByName returns correct author', () async {
      final author = await service.getAuthorByName('Św. Jan Chryzostom');
      expect(author, isNotNull);
      expect(author!.id, 'chryzostom');
    });

    test('getAuthorByName returns null for unmapped name', () async {
      final author = await service.getAuthorByName('Unknown Author');
      expect(author, isNull);
    });
  });
}
