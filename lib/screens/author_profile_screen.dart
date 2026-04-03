import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:patres/blocs/library_bloc.dart';
import 'package:patres/l10n/generated/app_localizations.dart';
import 'package:patres/models/author.dart';
import 'package:patres/models/text_entry.dart';
import 'package:patres/services/author_service.dart';

class AuthorProfileScreen extends StatefulWidget {
  const AuthorProfileScreen({
    super.key,
    required this.authorId,
    this.authorService,
  });

  final String authorId;
  final AuthorService? authorService;

  @override
  State<AuthorProfileScreen> createState() => _AuthorProfileScreenState();
}

class _AuthorProfileScreenState extends State<AuthorProfileScreen> {
  late Future<Author?> _authorFuture;

  AuthorService get _service =>
      widget.authorService ?? const AuthorService();

  @override
  void initState() {
    super.initState();
    _authorFuture = _service.getAuthorById(widget.authorId);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return FutureBuilder<Author?>(
      future: _authorFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final author = snapshot.data;
        if (author == null) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text(l10n.authorUnknown)),
          );
        }

        return _AuthorProfileBody(author: author);
      },
    );
  }
}

class _AuthorProfileBody extends StatelessWidget {
  const _AuthorProfileBody({required this.author});
  final Author author;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    // Get author's works from library bloc
    final libraryState = context.watch<LibraryBloc>().state;
    final authorWorks = libraryState.allTexts
        .where((t) => _authorOwnsText(t, author))
        .toList();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: _AuthorHeader(author: author),
            ),
            title: Text(
              author.name,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // Content
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            sliver: SliverList.list(
              children: [
                // Dates & era info row
                if (author.dates.isNotEmpty || author.era.isNotEmpty)
                  _InfoRow(author: author, l10n: l10n),

                // Original name
                if (author.nameOriginal.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _DetailChip(
                    icon: Icons.translate_rounded,
                    label: l10n.authorOriginalName,
                    value: author.nameOriginal,
                  ),
                ],

                // Biography
                if (author.bio.isNotEmpty) ...[
                  const SizedBox(height: 28),
                  _SectionHeader(
                    icon: Icons.history_edu_rounded,
                    title: l10n.authorBio,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    author.bio,
                    style: GoogleFonts.lora(
                      fontSize: 16,
                      height: 1.75,
                      color: cs.onSurface,
                    ),
                  ),
                ],

                // Significance
                if (author.significance.isNotEmpty) ...[
                  const SizedBox(height: 28),
                  _SectionHeader(
                    icon: Icons.auto_awesome_rounded,
                    title: l10n.authorSignificance,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cs.primaryContainer.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border(
                        left: BorderSide(
                          color: cs.primary.withValues(alpha: 0.5),
                          width: 3,
                        ),
                      ),
                    ),
                    child: Text(
                      author.significance,
                      style: GoogleFonts.lora(
                        fontSize: 15,
                        height: 1.7,
                        color: cs.onSurface,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],

                // Works
                if (authorWorks.isNotEmpty) ...[
                  const SizedBox(height: 28),
                  _SectionHeader(
                    icon: Icons.menu_book_rounded,
                    title: l10n.authorWorks,
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          ),

          // Works list
          if (authorWorks.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              sliver: SliverList.separated(
                itemCount: authorWorks.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) =>
                    _WorkCard(entry: authorWorks[index]),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  bool _authorOwnsText(TextEntry text, Author author) {
    // Match by author name — handle cases like "Anonim" matching "Anonim (Ojcowie Apostolscy)"
    if (author.id == 'anonim') {
      return text.author.startsWith('Anonim');
    }
    return text.author == author.name;
  }
}

// ---------------------------------------------------------------------------
// Author header with portrait placeholder
// ---------------------------------------------------------------------------

class _AuthorHeader extends StatelessWidget {
  const _AuthorHeader({required this.author});
  final Author author;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            cs.primaryContainer,
            cs.primaryContainer.withValues(alpha: 0.3),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 56, 24, 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Portrait placeholder
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: cs.surface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: cs.primary.withValues(alpha: 0.3),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: cs.shadow.withValues(alpha: 0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.person_rounded,
                  size: 48,
                  color: cs.primary.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                author.name,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: cs.onPrimaryContainer,
                ),
                textAlign: TextAlign.center,
              ),
              if (author.dates.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  author.dates,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: cs.onPrimaryContainer.withValues(alpha: 0.7),
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

// ---------------------------------------------------------------------------
// Info row (dates, era)
// ---------------------------------------------------------------------------

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.author, required this.l10n});
  final Author author;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (author.dates.isNotEmpty)
          _DetailChip(
            icon: Icons.calendar_today_rounded,
            label: l10n.authorDates,
            value: author.dates,
          ),
        if (author.dates.isNotEmpty && author.era.isNotEmpty)
          const SizedBox(width: 12),
        if (author.era.isNotEmpty)
          _DetailChip(
            icon: Icons.access_time_rounded,
            label: l10n.authorEra,
            value: author.era,
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Detail chip
// ---------------------------------------------------------------------------

class _DetailChip extends StatelessWidget {
  const _DetailChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: cs.primary),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontSize: 10,
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section header
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Row(
      children: [
        Icon(icon, size: 20, color: cs.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Work card
// ---------------------------------------------------------------------------

class _WorkCard extends StatelessWidget {
  const _WorkCard({required this.entry});
  final TextEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/reader/${entry.id}'),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: cs.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.menu_book_rounded,
                  color: cs.onSecondaryContainer,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (entry.titleOriginal.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        entry.titleOriginal,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      '${entry.era} · ${l10n.chaptersCount(entry.chaptersCount)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
