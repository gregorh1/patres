import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'package:patres/blocs/reader_bloc.dart';
import 'package:patres/blocs/reader_event.dart';
import 'package:patres/blocs/reader_state.dart';
import 'package:patres/l10n/generated/app_localizations.dart';
import 'package:patres/widgets/chapter_list_sheet.dart';
import 'package:patres/widgets/reader_settings_sheet.dart';

class ReaderScreen extends StatefulWidget {
  const ReaderScreen({super.key, required this.textId});
  final String textId;

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  final ScrollController _scrollController = ScrollController();
  double _scrollProgress = 0.0;
  Timer? _scrollSaveTimer;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WakelockPlus.enable().catchError((_) {});
  }

  @override
  void dispose() {
    _scrollSaveTimer?.cancel();
    _scrollController.dispose();
    WakelockPlus.disable().catchError((_) {});
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    if (maxScroll > 0) {
      setState(() {
        _scrollProgress =
            (_scrollController.offset / maxScroll).clamp(0.0, 1.0);
      });
    }
    _debouncedSaveScroll();
  }

  void _debouncedSaveScroll() {
    _scrollSaveTimer?.cancel();
    _scrollSaveTimer = Timer(const Duration(milliseconds: 500), () {
      if (_scrollController.hasClients && mounted) {
        context.read<ReaderBloc>().add(
              ReaderScrollPositionSaved(position: _scrollController.offset),
            );
      }
    });
  }

  void _restoreScroll(double position) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients && mounted) {
        final clamped =
            position.clamp(0.0, _scrollController.position.maxScrollExtent);
        _scrollController.jumpTo(clamped);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return BlocConsumer<ReaderBloc, ReaderState>(
      listenWhen: (prev, curr) =>
          prev.currentChapter != curr.currentChapter ||
          (prev.status != ReaderStatus.loaded &&
              curr.status == ReaderStatus.loaded),
      listener: (context, state) {
        if (state.status == ReaderStatus.loaded) {
          _restoreScroll(state.scrollPosition);
        }
      },
      builder: (context, state) {
        if (state.status == ReaderStatus.loading ||
            state.status == ReaderStatus.initial) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (state.status == ReaderStatus.error) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  state.errorMessage ?? l10n.readerPlaceholder,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        final textContent = state.textContent!;
        final chapter = textContent.chapters[state.currentChapter];
        final paragraphs = chapter.content
            .split('\n')
            .where((p) => p.trim().isNotEmpty)
            .toList();

        return Scaffold(
          body: Column(
            children: [
              Expanded(
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    // Floating AppBar with progress indicator
                    SliverAppBar(
                      floating: true,
                      snap: true,
                      title: Text(
                        textContent.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      bottom: PreferredSize(
                        preferredSize: const Size.fromHeight(2),
                        child: LinearProgressIndicator(
                          value: _scrollProgress,
                          minHeight: 2,
                          backgroundColor: Colors.transparent,
                          color: cs.primary.withValues(alpha: 0.5),
                        ),
                      ),
                      actions: [
                        IconButton(
                          icon: Icon(
                            state.isCurrentChapterBookmarked
                                ? Icons.bookmark_rounded
                                : Icons.bookmark_border_rounded,
                            color: state.isCurrentChapterBookmarked
                                ? cs.primary
                                : null,
                          ),
                          tooltip: state.isCurrentChapterBookmarked
                              ? l10n.removeBookmark
                              : l10n.addBookmark,
                          onPressed: () => _onBookmarkPressed(context, state),
                        ),
                        IconButton(
                          icon: const Icon(Icons.text_fields_rounded),
                          tooltip: l10n.readerSettings,
                          onPressed: () => _showSettingsSheet(context),
                        ),
                        IconButton(
                          icon: const Icon(Icons.list_rounded),
                          tooltip: l10n.chapters,
                          onPressed: () => _showChapterList(context, state),
                        ),
                      ],
                    ),

                    // Chapter header
                    SliverToBoxAdapter(
                      child: _ChapterHeader(
                        chapterTitle: chapter.title,
                        authorName: textContent.author,
                        fontFamily: state.fontFamily,
                        fontSize: state.fontSize,
                      ),
                    ),

                    // Text paragraphs
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      sliver: SliverList.builder(
                        itemCount: paragraphs.length,
                        itemBuilder: (context, index) {
                          return _ParagraphTile(
                            text: paragraphs[index],
                            isHighlighted:
                                state.isParagraphHighlighted(index),
                            fontFamily: state.fontFamily,
                            fontSize: state.fontSize,
                            onLongPress: () {
                              context.read<ReaderBloc>().add(
                                    ReaderHighlightToggled(
                                        paragraphIndex: index),
                                  );
                            },
                          );
                        },
                      ),
                    ),

                    // End-of-chapter ornament
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 48),
                        child: Center(
                          child: Text(
                            '\u2756',
                            style: TextStyle(
                              fontSize: 18,
                              color: cs.outline.withValues(alpha: 0.4),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  ],
                ),
              ),

              // Bottom chapter navigation
              _ChapterNavigationBar(
                currentChapter: state.currentChapter,
                totalChapters: textContent.chapters.length,
                onPrevious: state.currentChapter > 0
                    ? () => context.read<ReaderBloc>().add(
                          ReaderChapterChanged(
                              chapterIndex: state.currentChapter - 1),
                        )
                    : null,
                onNext:
                    state.currentChapter < textContent.chapters.length - 1
                        ? () => context.read<ReaderBloc>().add(
                              ReaderChapterChanged(
                                  chapterIndex: state.currentChapter + 1),
                            )
                        : null,
              ),
            ],
          ),
        );
      },
    );
  }

  void _onBookmarkPressed(BuildContext context, ReaderState state) {
    final l10n = AppLocalizations.of(context)!;
    if (state.isCurrentChapterBookmarked) {
      context.read<ReaderBloc>().add(const ReaderBookmarkToggled());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.bookmarkRemoved),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      _showAddBookmarkDialog(context);
    }
  }

  void _showAddBookmarkDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final noteController = TextEditingController();
    final bloc = context.read<ReaderBloc>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.addBookmark),
        content: TextField(
          controller: noteController,
          decoration: InputDecoration(
            hintText: l10n.bookmarkNoteHint,
            border: const OutlineInputBorder(),
          ),
          maxLines: 3,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              final scrollPos = _scrollController.hasClients
                  ? _scrollController.offset
                  : 0.0;
              bloc.add(ReaderBookmarkToggled(
                note: noteController.text.isEmpty
                    ? null
                    : noteController.text,
                scrollPosition: scrollPos,
              ));
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.bookmarkAdded),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  void _showSettingsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<ReaderBloc>(),
        child: const ReaderSettingsSheet(),
      ),
    );
  }

  void _showChapterList(BuildContext context, ReaderState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: context.read<ReaderBloc>(),
        child: ChapterListSheet(
          chapters: state.textContent!.chapters,
          currentChapter: state.currentChapter,
          bookmarkedChapters:
              state.bookmarks.map((b) => b.chapterIndex).toSet(),
        ),
      ),
    );
  }
}

// --- Chapter Header ---

class _ChapterHeader extends StatelessWidget {
  const _ChapterHeader({
    required this.chapterTitle,
    required this.authorName,
    required this.fontFamily,
    required this.fontSize,
  });

  final String chapterTitle;
  final String authorName;
  final String fontFamily;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 40, 28, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Decorative cross ornament
          Center(
            child: Text(
              '\u2720',
              style: TextStyle(
                fontSize: 20,
                color: cs.primary.withValues(alpha: 0.4),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            chapterTitle,
            style: GoogleFonts.getFont(
              fontFamily,
              fontSize: fontSize + 10,
              fontWeight: FontWeight.w600,
              height: 1.3,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            authorName,
            style: GoogleFonts.getFont(
              fontFamily,
              fontSize: fontSize - 2,
              fontStyle: FontStyle.italic,
              color: cs.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                width: 48,
                height: 2.5,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// --- Paragraph Tile ---

class _ParagraphTile extends StatelessWidget {
  const _ParagraphTile({
    required this.text,
    required this.isHighlighted,
    required this.fontFamily,
    required this.fontSize,
    required this.onLongPress,
  });

  final String text;
  final bool isHighlighted;
  final String fontFamily;
  final double fontSize;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: EdgeInsets.only(bottom: fontSize * 0.9),
        padding: isHighlighted
            ? const EdgeInsets.fromLTRB(12, 8, 12, 8)
            : EdgeInsets.zero,
        decoration: isHighlighted
            ? BoxDecoration(
                color: cs.primaryContainer.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(8),
                border: Border(
                  left: BorderSide(
                    color: cs.primary.withValues(alpha: 0.6),
                    width: 3,
                  ),
                ),
              )
            : null,
        child: SelectableText(
          text,
          style: GoogleFonts.getFont(
            fontFamily,
            fontSize: fontSize,
            height: 1.85,
            letterSpacing: 0.15,
            color: cs.onSurface,
          ),
        ),
      ),
    );
  }
}

// --- Chapter Navigation Bar ---

class _ChapterNavigationBar extends StatelessWidget {
  const _ChapterNavigationBar({
    required this.currentChapter,
    required this.totalChapters,
    required this.onPrevious,
    required this.onNext,
  });

  final int currentChapter;
  final int totalChapters;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: EdgeInsets.only(
        left: 8,
        right: 8,
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: cs.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded, size: 28),
            onPressed: onPrevious,
            tooltip: l10n.previousChapter,
          ),
          Expanded(
            child: Center(
              child: Text(
                l10n.chapterOf(currentChapter + 1, totalChapters),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded, size: 28),
            onPressed: onNext,
            tooltip: l10n.nextChapter,
          ),
        ],
      ),
    );
  }
}
