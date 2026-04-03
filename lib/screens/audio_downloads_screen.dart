import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:patres/blocs/library_bloc.dart';
import 'package:patres/blocs/tts_generation_bloc.dart';
import 'package:patres/blocs/tts_generation_event.dart';
import 'package:patres/blocs/tts_generation_state.dart';
import 'package:patres/l10n/generated/app_localizations.dart';
import 'package:patres/models/text_entry.dart';
import 'package:patres/services/text_service.dart';

class AudioDownloadsScreen extends StatelessWidget {
  const AudioDownloadsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.audioDownloads),
      ),
      body: BlocBuilder<TtsGenerationBloc, TtsGenerationState>(
        builder: (context, ttsState) {
          final libraryState = context.watch<LibraryBloc>().state;
          final texts = libraryState.allTexts;

          return CustomScrollView(
            slivers: [
              // Storage info header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: cs.primaryContainer,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.storage_rounded,
                              color: cs.onPrimaryContainer,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.audioStorageUsed,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                              Text(
                                ttsState.cacheSizeFormatted,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Generation progress
              if (ttsState.isGenerating)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Card(
                      color: cs.primaryContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: cs.onPrimaryContainer,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    l10n.audioGenerating,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: cs.onPrimaryContainer,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    context
                                        .read<TtsGenerationBloc>()
                                        .add(const TtsCancelRequested());
                                  },
                                  child: Text(l10n.cancel),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: ttsState.chapterProgress,
                              backgroundColor:
                                  cs.onPrimaryContainer.withValues(alpha: 0.15),
                              color: cs.onPrimaryContainer,
                              borderRadius: BorderRadius.circular(2),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.audioChapterProgress(
                                ttsState.completedChapters,
                                ttsState.totalChapters,
                              ),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color:
                                    cs.onPrimaryContainer.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              // Error message
              if (ttsState.status == TtsGenerationStatus.error)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 8),
                    child: Card(
                      color: cs.errorContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline,
                                color: cs.onErrorContainer),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                l10n.audioGenerationError,
                                style: TextStyle(color: cs.onErrorContainer),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              // Text list
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList.builder(
                  itemCount: texts.length,
                  itemBuilder: (context, index) {
                    final text = texts[index];
                    final isCached = ttsState.isTextCached(text.id);
                    final isCurrentlyGenerating = ttsState.isGenerating &&
                        ttsState.currentTextId == text.id;

                    return _TextDownloadTile(
                      text: text,
                      isCached: isCached,
                      isGenerating: isCurrentlyGenerating,
                      generationProgress: isCurrentlyGenerating
                          ? ttsState.chapterProgress
                          : null,
                    );
                  },
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          );
        },
      ),
    );
  }
}

class _TextDownloadTile extends StatelessWidget {
  const _TextDownloadTile({
    required this.text,
    required this.isCached,
    required this.isGenerating,
    this.generationProgress,
  });

  final TextEntry text;
  final bool isCached;
  final bool isGenerating;
  final double? generationProgress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 4,
        ),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isCached
                ? cs.primaryContainer
                : cs.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            isCached ? Icons.headphones_rounded : Icons.music_note_rounded,
            color: isCached ? cs.onPrimaryContainer : cs.onSurfaceVariant,
            size: 20,
          ),
        ),
        title: Text(
          text.title,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${text.author} · ${l10n.chaptersCount(text.chaptersCount)}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: cs.onSurfaceVariant,
          ),
        ),
        trailing: isGenerating
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  value: generationProgress,
                ),
              )
            : isCached
                ? IconButton(
                    icon: Icon(Icons.delete_outline_rounded,
                        color: cs.error),
                    tooltip: l10n.audioDeleteDownload,
                    onPressed: () => _confirmDelete(context),
                  )
                : IconButton(
                    icon: const Icon(Icons.download_rounded),
                    tooltip: l10n.audioDownload,
                    onPressed: () => _startDownload(context),
                  ),
      ),
    );
  }

  Future<void> _startDownload(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final textContent = await const TextService().loadText(text.id);
      if (!context.mounted) return;
      context.read<TtsGenerationBloc>().add(
            TtsGenerateTextRequested(
              textId: text.id,
              chapterContents:
                  textContent.chapters.map((c) => c.content).toList(),
            ),
          );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.audioGenerationError)),
      );
    }
  }

  void _confirmDelete(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.audioDeleteDownload),
        content: Text(l10n.audioDeleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              context
                  .read<TtsGenerationBloc>()
                  .add(TtsDeleteTextAudio(textId: text.id));
              Navigator.pop(dialogContext);
            },
            child: Text(l10n.audioDelete),
          ),
        ],
      ),
    );
  }
}
