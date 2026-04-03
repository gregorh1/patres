import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:patres/blocs/library_bloc.dart';
import 'package:patres/l10n/generated/app_localizations.dart';
import 'package:patres/models/daily_reading.dart';
import 'package:patres/models/text_entry.dart';
import 'package:patres/services/daily_reading_service.dart';
import 'package:patres/theme.dart';
import 'package:go_router/go_router.dart';
import 'package:patres/widgets/tappable_author.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.dailyReadingService});

  final DailyReadingService? dailyReadingService;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<DailyReading>? _dailyReadingFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _dailyReadingFuture ??= _loadDailyReading();
  }

  Future<DailyReading> _loadDailyReading() {
    final service = widget.dailyReadingService ??
        DailyReadingService(
            assetBundle: DefaultAssetBundle.of(context));
    return service.getTodaysReading();
  }

  static const _featuredIds = [
    'didache',
    'list-do-diogneta',
    'benedykt-regula',
    'bogurodzica',
  ];

  static const _descriptions = {
    'didache':
        'Jeden z najstarszych tekstów chrześcijańskich — zbiór wskazań moralnych i liturgicznych dla pierwszych wspólnot.',
    'list-do-diogneta':
        'Anonimowy list apologetyczny — słynny opis chrześcijan jako „duszy świata".',
    'benedykt-regula':
        'Fundament życia klasztornego w Europie — wskazania dotyczące modlitwy, pracy i posłuszeństwa.',
    'bogurodzica':
        'Najstarsza polska pieśń religijna, hymn rycerstwa i modlitwa do Matki Bożej.',
  };

  static IconData _iconFor(String id) {
    return switch (id) {
      'didache' => Icons.menu_book_rounded,
      'list-do-diogneta' => Icons.history_edu_rounded,
      'benedykt-regula' => Icons.account_balance_rounded,
      'bogurodzica' => Icons.music_note_rounded,
      _ => Icons.auto_stories_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;

    return DecoratedBox(
      decoration: isLight
          ? const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  PatresTheme.lightParchment,
                  PatresTheme.lightParchmentEnd,
                ],
              ),
            )
          : const BoxDecoration(),
      child: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: Text(
              l10n.appTitle,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w300,
                letterSpacing: 2,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search_rounded),
                tooltip: l10n.searchFullText,
                onPressed: () => context.push('/search'),
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList.list(
              children: [
                const SizedBox(height: 8),
                // Hero greeting card
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        cs.primaryContainer,
                        cs.primaryContainer.withValues(alpha: 0.6),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.auto_stories_rounded,
                        size: 40,
                        color: cs.onPrimaryContainer.withValues(alpha: 0.8),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.homeGreeting,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: cs.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.homeSubtitle,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: cs.onPrimaryContainer.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Daily reading section
                Text(
                  l10n.dailyReading,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                FutureBuilder<DailyReading>(
                  future: _dailyReadingFuture,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const SizedBox(height: 120);
                    }
                    return _DailyReadingCard(reading: snapshot.data!);
                  },
                ),
                const SizedBox(height: 32),

                // Continue reading section
                Text(
                  l10n.continueReading,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                _ReadingCard(
                  title: 'Wyznania',
                  author: 'Św. Augustyn z Hippony',
                  progress: 0.34,
                  onTap: () => context.push('/reader/augustyn-wyznania'),
                ),
                const SizedBox(height: 32),

                // Recommended section
                Text(
                  l10n.recommended,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
          BlocBuilder<LibraryBloc, LibraryState>(
            builder: (context, state) {
              final featured = _featuredIds
                  .map((id) => state.allTexts
                      .cast<TextEntry?>()
                      .firstWhere((t) => t?.id == id, orElse: () => null))
                  .whereType<TextEntry>()
                  .toList();

              if (featured.isEmpty) {
                // Fallback while loading
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverGrid.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.65,
                    children: _featuredIds.map((id) {
                      return _BookCard(
                        title: _fallbackTitle(id),
                        author: '',
                        era: '',
                        description: _descriptions[id] ?? '',
                        icon: _iconFor(id),
                        textId: id,
                      );
                    }).toList(),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverGrid.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.65,
                  children: featured.map((text) {
                    return _BookCard(
                      title: text.title,
                      author: text.author,
                      era: text.era,
                      description: _descriptions[text.id] ?? '',
                      icon: _iconFor(text.id),
                      textId: text.id,
                    );
                  }).toList(),
                ),
              );
            },
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
        ],
      ),
    );
  }

  static String _fallbackTitle(String id) {
    return switch (id) {
      'didache' => 'Didache',
      'list-do-diogneta' => 'List do Diogneta',
      'benedykt-regula' => 'Reguła',
      'bogurodzica' => 'Bogurodzica',
      _ => id,
    };
  }
}

class _ReadingCard extends StatelessWidget {
  const _ReadingCard({
    required this.title,
    required this.author,
    required this.progress,
    required this.onTap,
  });

  final String title;
  final String author;
  final double progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 72,
                decoration: BoxDecoration(
                  color: cs.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.auto_stories_rounded,
                  color: cs.onSecondaryContainer,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    TappableAuthor(
                      authorName: author,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor: cs.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation(cs.primary),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(progress * 100).round()}%',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: cs.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BookCard extends StatelessWidget {
  const _BookCard({
    required this.title,
    required this.author,
    required this.era,
    required this.description,
    required this.icon,
    required this.textId,
  });

  final String title;
  final String author;
  final String era;
  final String description;
  final IconData icon;
  final String textId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/reader/$textId'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: cs.tertiaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, size: 20, color: cs.onTertiaryContainer),
                  ),
                  const Spacer(),
                  if (era.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: cs.secondaryContainer.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        era,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: cs.onSecondaryContainer,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (author.isNotEmpty) ...[
                const SizedBox(height: 2),
                TappableAuthor(
                  authorName: author,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
              if (description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Expanded(
                  child: Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                      fontSize: 11,
                      height: 1.4,
                    ),
                    overflow: TextOverflow.fade,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DailyReadingCard extends StatelessWidget {
  const _DailyReadingCard({required this.reading});

  final DailyReading reading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(
          '/reader/${reading.textId}?chapter=${reading.chapterIndex}',
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.format_quote_rounded,
                    size: 28,
                    color: cs.primary.withValues(alpha: 0.7),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      Icons.share_rounded,
                      size: 20,
                      color: cs.onSurfaceVariant,
                    ),
                    tooltip: l10n.shareDailyReading,
                    onPressed: () => _shareQuote(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                reading.quote,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontStyle: FontStyle.italic,
                  height: 1.6,
                  color: cs.onSurface,
                ),
                maxLines: 6,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    width: 24,
                    height: 2,
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TappableAuthor(
                      authorName: reading.author,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _shareQuote(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final text =
        '„${reading.quote}"\n${l10n.dailyReadingShared(reading.author)}';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.shareDailyReading),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
