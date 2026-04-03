import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:patres/models/text_content.dart';
import 'package:patres/models/text_entry.dart';

/// Loads text metadata and full content from assets/texts/.
class TextService {
  const TextService({this.assetBundle});

  /// Optional bundle for testing; defaults to rootBundle.
  final AssetBundle? assetBundle;

  AssetBundle get _bundle => assetBundle ?? rootBundle;

  Future<List<TextEntry>> loadManifest() async {
    final jsonString = await _bundle.loadString('assets/texts/manifest.json');
    final data = json.decode(jsonString) as Map<String, dynamic>;
    final texts = data['texts'] as List<dynamic>;
    return texts
        .map((e) => TextEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Loads the full text content (with chapters) for a given text ID.
  Future<TextContent> loadText(String textId) async {
    final jsonString =
        await _bundle.loadString('assets/texts/$textId.json');
    final data = json.decode(jsonString) as Map<String, dynamic>;
    return TextContent.fromJson(data);
  }
}
