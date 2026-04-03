import 'package:patres/models/search_result.dart';
import 'package:patres/models/text_content.dart';
import 'package:patres/services/database_service.dart';
import 'package:patres/services/text_service.dart';

/// Indexes text content into FTS5 and provides full-text search.
class SearchService {
  SearchService({
    required this.databaseService,
    required this.textService,
  });

  final DatabaseService databaseService;
  final TextService textService;

  /// Ensures all text content is indexed for search.
  /// Indexes on first launch or when the index is empty.
  Future<void> ensureIndexed() async {
    final indexed = await databaseService.isSearchIndexed();
    if (indexed) return;
    await rebuildIndex();
  }

  /// Rebuilds the entire search index from asset texts.
  Future<void> rebuildIndex() async {
    await databaseService.clearSearchIndex();

    final manifest = await textService.loadManifest();

    for (final entry in manifest) {
      final text = await textService.loadText(entry.id);
      await _indexText(text);
    }
  }

  Future<void> _indexText(TextContent text) async {
    for (var i = 0; i < text.chapters.length; i++) {
      final chapter = text.chapters[i];
      await databaseService.insertSearchEntry(
        textId: text.id,
        chapterIndex: i,
        chapterTitle: chapter.title,
        bookTitle: text.title,
        bookAuthor: text.author,
        content: chapter.content,
      );
    }
  }

  /// Searches across all indexed texts.
  Future<List<SearchResult>> search(String query, {int limit = 50}) {
    return databaseService.search(query, limit: limit);
  }
}
