import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:patres/models/author.dart';

class AuthorService {
  const AuthorService({this.assetBundle});

  final AssetBundle? assetBundle;

  AssetBundle get _bundle => assetBundle ?? rootBundle;

  Future<List<Author>> loadAuthors() async {
    final jsonString = await _bundle.loadString('assets/authors.json');
    final data = json.decode(jsonString) as Map<String, dynamic>;
    final authorsList = data['authors'] as List<dynamic>;
    return authorsList
        .map((e) => Author.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, String>> loadAuthorMapping() async {
    final jsonString = await _bundle.loadString('assets/authors.json');
    final data = json.decode(jsonString) as Map<String, dynamic>;
    final mapping = data['authorMapping'] as Map<String, dynamic>;
    return mapping.map((key, value) => MapEntry(key, value as String));
  }

  Future<Author?> getAuthorByName(String authorName) async {
    final authors = await loadAuthors();
    final mapping = await loadAuthorMapping();
    final authorId = mapping[authorName];
    if (authorId == null) return null;
    try {
      return authors.firstWhere((a) => a.id == authorId);
    } catch (_) {
      return null;
    }
  }

  Future<Author?> getAuthorById(String id) async {
    final authors = await loadAuthors();
    try {
      return authors.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }
}
