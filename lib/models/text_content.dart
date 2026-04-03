import 'package:equatable/equatable.dart';

class TextContent extends Equatable {
  const TextContent({
    required this.id,
    required this.title,
    this.titleOriginal,
    required this.author,
    this.authorOriginal,
    this.era,
    this.description,
    required this.chapters,
  });

  final String id;
  final String title;
  final String? titleOriginal;
  final String author;
  final String? authorOriginal;
  final String? era;
  final String? description;
  final List<Chapter> chapters;

  factory TextContent.fromJson(Map<String, dynamic> json) {
    return TextContent(
      id: json['id'] as String,
      title: json['title'] as String,
      titleOriginal: json['titleOriginal'] as String?,
      author: json['author'] as String,
      authorOriginal: json['authorOriginal'] as String?,
      era: json['era'] as String?,
      description: json['description'] as String?,
      chapters: (json['chapters'] as List<dynamic>)
          .map((e) => Chapter.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [id];
}

class Chapter extends Equatable {
  const Chapter({
    required this.title,
    required this.content,
  });

  final String title;
  final String content;

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      title: json['title'] as String,
      content: json['content'] as String,
    );
  }

  @override
  List<Object?> get props => [title, content];
}
