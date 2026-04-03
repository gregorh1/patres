import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:patres/services/author_service.dart';

/// Navigates to the author profile screen for the given author name.
///
/// Looks up the author ID from the author mapping and pushes the
/// `/author/:id` route. If the author is not found, does nothing.
Future<void> navigateToAuthor(
  BuildContext context,
  String authorName, {
  AuthorService? authorService,
}) async {
  final service = authorService ?? const AuthorService();
  final author = await service.getAuthorByName(authorName);
  if (author != null && context.mounted) {
    context.push('/author/${author.id}');
  }
}

/// A widget that displays an author name as tappable text.
class TappableAuthor extends StatelessWidget {
  const TappableAuthor({
    super.key,
    required this.authorName,
    required this.style,
    this.maxLines = 1,
    this.overflow = TextOverflow.ellipsis,
  });

  final String authorName;
  final TextStyle? style;
  final int maxLines;
  final TextOverflow overflow;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => navigateToAuthor(context, authorName),
      child: Text(
        authorName,
        style: style?.copyWith(
          decoration: TextDecoration.underline,
          decorationStyle: TextDecorationStyle.dotted,
          decorationColor: style?.color?.withValues(alpha: 0.5),
        ),
        maxLines: maxLines,
        overflow: overflow,
      ),
    );
  }
}
