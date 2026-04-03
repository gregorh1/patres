import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patres/blocs/library_bloc.dart';
import 'package:patres/models/text_entry.dart';
import 'package:patres/services/text_service.dart';

const _manifestJson = '''
{
  "version": "1.0.0",
  "texts": [
    {
      "id": "augustyn",
      "file": "augustyn.json",
      "title": "Wyznania",
      "titleOriginal": "Confessiones",
      "author": "Św. Augustyn",
      "era": "IV-V w.",
      "category": "patrystyka",
      "language": "pl",
      "chaptersCount": 42,
      "status": "complete"
    },
    {
      "id": "didache",
      "file": "didache.json",
      "title": "Didache",
      "titleOriginal": "Διδαχή",
      "author": "Anonim",
      "era": "I-II w.",
      "category": "patrystyka",
      "language": "pl",
      "chaptersCount": 6,
      "status": "complete"
    },
    {
      "id": "benedykt",
      "file": "benedykt.json",
      "title": "Reguła",
      "titleOriginal": "Regula",
      "author": "Św. Benedykt",
      "era": "VI w.",
      "category": "monastycyzm",
      "language": "pl",
      "chaptersCount": 4,
      "status": "partial"
    }
  ]
}
''';

class _FakeAssetBundle extends CachingAssetBundle {
  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    if (key == 'assets/texts/manifest.json') {
      return _manifestJson;
    }
    throw FlutterError('Asset not found: $key');
  }

  @override
  Future<ByteData> load(String key) async {
    final str = await loadString(key);
    return ByteData.view(
      Uint8List.fromList(utf8.encode(str)).buffer,
    );
  }
}

TextService _fakeService() =>
    TextService(assetBundle: _FakeAssetBundle());

void main() {
  group('LibraryBloc', () {
    late LibraryBloc bloc;

    setUp(() {
      bloc = LibraryBloc(textService: _fakeService());
    });

    tearDown(() => bloc.close());

    test('initial state is LibraryStatus.initial', () {
      expect(bloc.state.status, LibraryStatus.initial);
      expect(bloc.state.allTexts, isEmpty);
    });

    test('LibraryLoadRequested loads texts from manifest', () async {
      bloc.add(const LibraryLoadRequested());
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(bloc.state.status, LibraryStatus.loaded);
      expect(bloc.state.allTexts, hasLength(3));
      expect(bloc.state.filteredTexts, hasLength(3));
      expect(bloc.state.availableCategories, containsAll(['monastycyzm', 'patrystyka']));
      expect(bloc.state.availableEras, isNotEmpty);
    });

    test('LibrarySearchChanged filters by title', () async {
      bloc.add(const LibraryLoadRequested());
      await Future<void>.delayed(const Duration(milliseconds: 50));

      bloc.add(const LibrarySearchChanged('Wyznania'));
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.filteredTexts, hasLength(1));
      expect(bloc.state.filteredTexts.first.id, 'augustyn');
    });

    test('LibrarySearchChanged filters by author', () async {
      bloc.add(const LibraryLoadRequested());
      await Future<void>.delayed(const Duration(milliseconds: 50));

      bloc.add(const LibrarySearchChanged('Benedykt'));
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.filteredTexts, hasLength(1));
      expect(bloc.state.filteredTexts.first.id, 'benedykt');
    });

    test('LibraryCategoryFilterChanged filters by category', () async {
      bloc.add(const LibraryLoadRequested());
      await Future<void>.delayed(const Duration(milliseconds: 50));

      bloc.add(const LibraryCategoryFilterChanged('monastycyzm'));
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.filteredTexts, hasLength(1));
      expect(bloc.state.filteredTexts.first.category, 'monastycyzm');
    });

    test('LibraryCategoryFilterChanged(null) clears category filter', () async {
      bloc.add(const LibraryLoadRequested());
      await Future<void>.delayed(const Duration(milliseconds: 50));

      bloc.add(const LibraryCategoryFilterChanged('monastycyzm'));
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.filteredTexts, hasLength(1));

      bloc.add(const LibraryCategoryFilterChanged(null));
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.filteredTexts, hasLength(3));
    });

    test('LibraryEraFilterChanged filters by era', () async {
      bloc.add(const LibraryLoadRequested());
      await Future<void>.delayed(const Duration(milliseconds: 50));

      bloc.add(const LibraryEraFilterChanged('VI w.'));
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.filteredTexts, hasLength(1));
      expect(bloc.state.filteredTexts.first.era, 'VI w.');
    });

    test('LibrarySortChanged sorts by author', () async {
      bloc.add(const LibraryLoadRequested());
      await Future<void>.delayed(const Duration(milliseconds: 50));

      bloc.add(const LibrarySortChanged(LibrarySortMode.author));
      await Future<void>.delayed(Duration.zero);

      final authors = bloc.state.filteredTexts.map((t) => t.author).toList();
      expect(authors, equals([...authors]..sort()));
    });

    test('LibrarySortChanged sorts by era', () async {
      bloc.add(const LibraryLoadRequested());
      await Future<void>.delayed(const Duration(milliseconds: 50));

      bloc.add(const LibrarySortChanged(LibrarySortMode.era));
      await Future<void>.delayed(Duration.zero);

      // I-II w. (1) should come before IV-V w. (4) before VI w. (6)
      expect(bloc.state.filteredTexts[0].id, 'didache');
      expect(bloc.state.filteredTexts[1].id, 'augustyn');
      expect(bloc.state.filteredTexts[2].id, 'benedykt');
    });

    test('LibraryViewModeToggled toggles between grid and list', () async {
      expect(bloc.state.viewMode, LibraryViewMode.grid);

      bloc.add(const LibraryViewModeToggled());
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.viewMode, LibraryViewMode.list);

      bloc.add(const LibraryViewModeToggled());
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.viewMode, LibraryViewMode.grid);
    });

    test('combined filters work together', () async {
      bloc.add(const LibraryLoadRequested());
      await Future<void>.delayed(const Duration(milliseconds: 50));

      bloc.add(const LibraryCategoryFilterChanged('patrystyka'));
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.filteredTexts, hasLength(2));

      bloc.add(const LibrarySearchChanged('Didache'));
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.filteredTexts, hasLength(1));
      expect(bloc.state.filteredTexts.first.id, 'didache');
    });
  });
}
