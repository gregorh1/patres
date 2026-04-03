import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:patres/blocs/library_bloc.dart';
import 'package:patres/l10n/generated/app_localizations.dart';
import 'package:patres/models/text_entry.dart';
import 'package:patres/widgets/tappable_author.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final bloc = context.read<LibraryBloc>();
    if (bloc.state.status == LibraryStatus.initial) {
      bloc.add(const LibraryLoadRequested());
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return BlocBuilder<LibraryBloc, LibraryState>(
      builder: (context, state) {
        return CustomScrollView(
          slivers: [
            // App bar
            SliverAppBar.large(
              title: Text(
                l10n.libraryTitle,
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
                IconButton(
                  icon: Icon(
                    state.viewMode == LibraryViewMode.grid
                        ? Icons.view_list_rounded
                        : Icons.grid_view_rounded,
                  ),
                  onPressed: () => context
                      .read<LibraryBloc>()
                      .add(const LibraryViewModeToggled()),
                ),
                const SizedBox(width: 8),
              ],
            ),

            // Search bar
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              sliver: SliverToBoxAdapter(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: l10n.searchHint,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: state.searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              context
                                  .read<LibraryBloc>()
                                  .add(const LibrarySearchChanged(''));
                            },
                          )
                        : null,
                    filled: true,
                    fillColor:
                        cs.surfaceContainerHighest.withValues(alpha: 0.5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                  onChanged: (q) => context
                      .read<LibraryBloc>()
                      .add(LibrarySearchChanged(q)),
                ),
              ),
            ),

            // Filter chips
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
              sliver: SliverToBoxAdapter(
                child: _FilterBar(state: state),
              ),
            ),

            // Sort row
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              sliver: SliverToBoxAdapter(
                child: _SortBar(state: state),
              ),
            ),

            // Content
            if (state.status == LibraryStatus.loading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (state.filteredTexts.isEmpty &&
                state.status == LibraryStatus.loaded)
              SliverFillRemaining(
                child: _EmptyState(l10n: l10n),
              )
            else if (state.viewMode == LibraryViewMode.grid)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.72,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _TextGridCard(
                      entry: state.filteredTexts[index],
                    ),
                    childCount: state.filteredTexts.length,
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                sliver: SliverList.separated(
                  itemCount: state.filteredTexts.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) => _TextListCard(
                    entry: state.filteredTexts[index],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Filter bar
// ---------------------------------------------------------------------------

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.state});
  final LibraryState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bloc = context.read<LibraryBloc>();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _LanguageFilterChips(state: state),
          const SizedBox(width: 8),
          if (state.availableCategories.isNotEmpty) ...[
            _buildFilterChip(
              context,
              label: l10n.filterCategory,
              selected: state.selectedCategory,
              options: state.availableCategories,
              labelFor: (c) => _categoryLabel(c, l10n),
              onSelected: (v) =>
                  bloc.add(LibraryCategoryFilterChanged(v)),
              onCleared: () =>
                  bloc.add(const LibraryCategoryFilterChanged(null)),
            ),
            const SizedBox(width: 8),
          ],
          if (state.availableEras.isNotEmpty)
            _buildFilterChip(
              context,
              label: l10n.filterEra,
              selected: state.selectedEra,
              options: state.availableEras,
              labelFor: (e) => e,
              onSelected: (v) => bloc.add(LibraryEraFilterChanged(v)),
              onCleared: () =>
                  bloc.add(const LibraryEraFilterChanged(null)),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip<T extends String>(
    BuildContext context, {
    required String label,
    required T? selected,
    required List<T> options,
    required String Function(T) labelFor,
    required void Function(T) onSelected,
    required VoidCallback onCleared,
  }) {
    final cs = Theme.of(context).colorScheme;
    final isActive = selected != null;

    return FilterChip(
      label: Text(isActive ? labelFor(selected) : label),
      selected: isActive,
      onSelected: (_) {
        if (isActive) {
          onCleared();
        } else {
          _showFilterMenu(context, options, labelFor, onSelected);
        }
      },
      avatar: isActive
          ? null
          : Icon(Icons.arrow_drop_down, size: 18, color: cs.onSurfaceVariant),
      showCheckmark: isActive,
      selectedColor: cs.secondaryContainer,
    );
  }

  void _showFilterMenu<T extends String>(
    BuildContext context,
    List<T> options,
    String Function(T) labelFor,
    void Function(T) onSelected,
  ) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final offset = box.localToGlobal(Offset.zero);

    showMenu<T>(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + box.size.height,
        offset.dx + box.size.width,
        offset.dy + box.size.height + 200,
      ),
      items: options
          .map((o) => PopupMenuItem(value: o, child: Text(labelFor(o))))
          .toList(),
    ).then((value) {
      if (value != null) onSelected(value);
    });
  }
}

// ---------------------------------------------------------------------------
// Sort bar
// ---------------------------------------------------------------------------

class _SortBar extends StatelessWidget {
  const _SortBar({required this.state});
  final LibraryState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final bloc = context.read<LibraryBloc>();

    return Row(
      children: [
        Icon(Icons.sort_rounded, size: 16, color: cs.onSurfaceVariant),
        const SizedBox(width: 6),
        Text(
          l10n.sortBy,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
        ),
        const SizedBox(width: 8),
        _sortChip(context, l10n.sortByTitle, LibrarySortMode.title, bloc),
        const SizedBox(width: 6),
        _sortChip(context, l10n.sortByAuthor, LibrarySortMode.author, bloc),
        const SizedBox(width: 6),
        _sortChip(context, l10n.sortByEra, LibrarySortMode.era, bloc),
      ],
    );
  }

  Widget _sortChip(
    BuildContext context,
    String label,
    LibrarySortMode mode,
    LibraryBloc bloc,
  ) {
    final isSelected = state.sortMode == mode;
    final cs = Theme.of(context).colorScheme;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => bloc.add(LibrarySortChanged(mode)),
      selectedColor: cs.primaryContainer,
      labelStyle: TextStyle(
        fontSize: 12,
        color: isSelected ? cs.onPrimaryContainer : cs.onSurfaceVariant,
      ),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

// ---------------------------------------------------------------------------
// Grid card
// ---------------------------------------------------------------------------

class _TextGridCard extends StatelessWidget {
  const _TextGridCard({required this.entry});
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
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: cs.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _categoryIcon(entry.category),
                  color: cs.onSecondaryContainer,
                  size: 22,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                entry.title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              if (entry.titleOriginal.isNotEmpty)
                Text(
                  entry.titleOriginal,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              const Spacer(),
              TappableAuthor(
                authorName: entry.author,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.access_time, size: 12, color: cs.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(
                    entry.era,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    l10n.chaptersCount(entry.chaptersCount),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _StatusBadge(status: entry.status),
                  const SizedBox(width: 6),
                  _LanguageBadge(language: entry.language),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// List card
// ---------------------------------------------------------------------------

class _TextListCard extends StatelessWidget {
  const _TextListCard({required this.entry});
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
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: cs.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _categoryIcon(entry.category),
                  color: cs.onSecondaryContainer,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
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
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Flexible(
                          child: TappableAuthor(
                            authorName: entry.author,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ),
                        Text(
                          ' · ${entry.era}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _StatusBadge(status: entry.status),
                        const SizedBox(width: 6),
                        _LanguageBadge(language: entry.language),
                        const SizedBox(width: 8),
                        Text(
                          l10n.chaptersCount(entry.chaptersCount),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                            fontSize: 11,
                          ),
                        ),
                      ],
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

// ---------------------------------------------------------------------------
// Status badge
// ---------------------------------------------------------------------------

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    final (String label, Color bg, Color fg) = switch (status) {
      'complete' => (l10n.statusComplete, cs.primaryContainer, cs.onPrimaryContainer),
      'partial' => (l10n.statusPartial, cs.tertiaryContainer, cs.onTertiaryContainer),
      _ => (l10n.statusPlaceholder, cs.surfaceContainerHighest, cs.onSurfaceVariant),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Language badge
// ---------------------------------------------------------------------------

class _LanguageBadge extends StatelessWidget {
  const _LanguageBadge({required this.language});
  final String language;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        language.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: cs.onSurfaceVariant,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: cs.onSurfaceVariant),
          const SizedBox(height: 16),
          Text(
            l10n.noResults,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.noResultsHint,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Language filter chips
// ---------------------------------------------------------------------------

class _LanguageFilterChips extends StatelessWidget {
  const _LanguageFilterChips({required this.state});
  final LibraryState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final bloc = context.read<LibraryBloc>();

    Widget chip(String label, String? filterValue) {
      final isSelected = state.selectedLanguage == filterValue;
      return ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) =>
            bloc.add(LibraryLanguageFilterChanged(filterValue)),
        selectedColor: cs.primaryContainer,
        labelStyle: TextStyle(
          fontSize: 12,
          color: isSelected ? cs.onPrimaryContainer : cs.onSurfaceVariant,
        ),
        visualDensity: VisualDensity.compact,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        chip(l10n.filterAll, null),
        const SizedBox(width: 6),
        chip(l10n.languagePolish, 'pl'),
        const SizedBox(width: 6),
        chip(l10n.languageEnglish, 'en'),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

IconData _categoryIcon(String category) {
  return switch (category) {
    'patrystyka' => Icons.auto_stories_rounded,
    'duchowość' => Icons.favorite_rounded,
    'monastycyzm' => Icons.account_balance_rounded,
    'hymnografia' => Icons.music_note_rounded,
    'kaznodziejstwo' => Icons.record_voice_over_rounded,
    _ => Icons.menu_book_rounded,
  };
}

String _categoryLabel(String category, AppLocalizations l10n) {
  return switch (category) {
    'patrystyka' => l10n.categoryPatrystyka,
    'duchowość' => l10n.categoryDuchowosc,
    'monastycyzm' => l10n.categoryMonastycyzm,
    'hymnografia' => l10n.categoryHymnografia,
    'kaznodziejstwo' => l10n.categoryKaznodziejstwo,
    _ => category,
  };
}
