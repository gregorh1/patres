import 'package:equatable/equatable.dart';

class Author extends Equatable {
  const Author({
    required this.id,
    required this.name,
    required this.nameOriginal,
    required this.dates,
    required this.era,
    required this.bio,
    required this.significance,
    this.portraitAsset,
  });

  final String id;
  final String name;
  final String nameOriginal;
  final String dates;
  final String era;
  final String bio;
  final String significance;
  final String? portraitAsset;

  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
      id: json['id'] as String,
      name: json['name'] as String,
      nameOriginal: json['nameOriginal'] as String? ?? '',
      dates: json['dates'] as String? ?? '',
      era: json['era'] as String? ?? '',
      bio: json['bio'] as String? ?? '',
      significance: json['significance'] as String? ?? '',
      portraitAsset: json['portraitAsset'] as String?,
    );
  }

  @override
  List<Object?> get props => [id];
}
