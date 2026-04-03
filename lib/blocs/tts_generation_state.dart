import 'package:equatable/equatable.dart';

enum TtsGenerationStatus { idle, generating, completed, error }

class TtsGenerationState extends Equatable {
  const TtsGenerationState({
    this.status = TtsGenerationStatus.idle,
    this.currentTextId,
    this.currentChapterIndex,
    this.completedChapters = 0,
    this.totalChapters = 0,
    this.completedChunks = 0,
    this.totalChunks = 0,
    this.cachedTextIds = const {},
    this.totalCacheSize = 0,
    this.errorMessage,
  });

  final TtsGenerationStatus status;
  final String? currentTextId;
  final int? currentChapterIndex;
  final int completedChapters;
  final int totalChapters;
  final int completedChunks;
  final int totalChunks;
  final Set<String> cachedTextIds;
  final int totalCacheSize; // bytes
  final String? errorMessage;

  bool get isGenerating => status == TtsGenerationStatus.generating;

  double get chapterProgress {
    if (totalChapters == 0) return 0;
    return completedChapters / totalChapters;
  }

  String get cacheSizeFormatted {
    if (totalCacheSize < 1024) return '$totalCacheSize B';
    if (totalCacheSize < 1024 * 1024) {
      return '${(totalCacheSize / 1024).toStringAsFixed(1)} KB';
    }
    return '${(totalCacheSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  bool isTextCached(String textId) => cachedTextIds.contains(textId);

  TtsGenerationState copyWith({
    TtsGenerationStatus? status,
    String? currentTextId,
    int? currentChapterIndex,
    int? completedChapters,
    int? totalChapters,
    int? completedChunks,
    int? totalChunks,
    Set<String>? cachedTextIds,
    int? totalCacheSize,
    String? errorMessage,
    bool clearCurrentText = false,
    bool clearError = false,
  }) {
    return TtsGenerationState(
      status: status ?? this.status,
      currentTextId:
          clearCurrentText ? null : currentTextId ?? this.currentTextId,
      currentChapterIndex: clearCurrentText
          ? null
          : currentChapterIndex ?? this.currentChapterIndex,
      completedChapters: completedChapters ?? this.completedChapters,
      totalChapters: totalChapters ?? this.totalChapters,
      completedChunks: completedChunks ?? this.completedChunks,
      totalChunks: totalChunks ?? this.totalChunks,
      cachedTextIds: cachedTextIds ?? this.cachedTextIds,
      totalCacheSize: totalCacheSize ?? this.totalCacheSize,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        currentTextId,
        currentChapterIndex,
        completedChapters,
        totalChapters,
        completedChunks,
        totalChunks,
        cachedTextIds,
        totalCacheSize,
        errorMessage,
      ];
}
