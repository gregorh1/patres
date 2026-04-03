import 'package:equatable/equatable.dart';

class TextEntry extends Equatable {
  const TextEntry({
    required this.id,
    required this.file,
    required this.title,
    required this.titleOriginal,
    required this.author,
    required this.era,
    required this.category,
    required this.language,
    required this.chaptersCount,
    required this.status,
  });

  final String id;
  final String file;
  final String title;
  final String titleOriginal;
  final String author;
  final String era;
  final String category;
  final String language;
  final int chaptersCount;
  final String status;

  factory TextEntry.fromJson(Map<String, dynamic> json) {
    return TextEntry(
      id: json['id'] as String,
      file: json['file'] as String,
      title: json['title'] as String,
      titleOriginal: json['titleOriginal'] as String? ?? '',
      author: json['author'] as String,
      era: json['era'] as String,
      category: json['category'] as String,
      language: json['language'] as String? ?? 'pl',
      chaptersCount: json['chaptersCount'] as int? ?? 0,
      status: json['status'] as String? ?? 'placeholder',
    );
  }

  /// Returns a numeric sort key derived from the era string (e.g. "IV-V w." → 4).
  int get eraSortKey {
    final match = RegExp(r'([IVXLCDM]+)').firstMatch(era);
    if (match == null) return 99;
    return romanToInt(match.group(1)!);
  }

  static int romanToInt(String s) {
    const values = {'I': 1, 'V': 5, 'X': 10, 'L': 50, 'C': 100, 'D': 500, 'M': 1000};
    var result = 0;
    for (var i = 0; i < s.length; i++) {
      final curr = values[s[i]] ?? 0;
      final next = i + 1 < s.length ? (values[s[i + 1]] ?? 0) : 0;
      result += curr < next ? -curr : curr;
    }
    return result;
  }

  @override
  List<Object?> get props => [id];
}
