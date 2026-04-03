import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:patres/blocs/reader_bloc.dart';
import 'package:patres/blocs/reader_event.dart';
import 'package:patres/l10n/generated/app_localizations.dart';
import 'package:patres/models/text_content.dart';

class ChapterListSheet extends StatelessWidget {
  const ChapterListSheet({
    super.key,
    required this.chapters,
    required this.currentChapter,
    required this.bookmarkedChapters,
  });

  final List<Chapter> chapters;
  final int currentChapter;
  final Set<int> bookmarkedChapters;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.85,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Handle and title
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Column(
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: cs.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        l10n.chapters,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        l10n.chapterOf(currentChapter + 1, chapters.length),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Divider(color: cs.outlineVariant.withValues(alpha: 0.3)),
                ],
              ),
            ),

            // Chapter list
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: chapters.length,
                itemBuilder: (context, index) {
                  final chapter = chapters[index];
                  final isCurrent = index == currentChapter;
                  final isBookmarked = bookmarkedChapters.contains(index);

                  return ListTile(
                    leading: Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? cs.primaryContainer
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${index + 1}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: isCurrent
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: isCurrent
                              ? cs.onPrimaryContainer
                              : cs.onSurfaceVariant,
                        ),
                      ),
                    ),
                    title: Text(
                      chapter.title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight:
                            isCurrent ? FontWeight.w600 : FontWeight.w400,
                        color: isCurrent ? cs.primary : cs.onSurface,
                      ),
                    ),
                    trailing: isBookmarked
                        ? Icon(
                            Icons.bookmark_rounded,
                            size: 20,
                            color: cs.primary,
                          )
                        : null,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onTap: () {
                      context.read<ReaderBloc>().add(
                            ReaderChapterChanged(chapterIndex: index),
                          );
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
