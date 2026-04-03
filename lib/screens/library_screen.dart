import 'package:flutter/material.dart';
import 'package:patres/l10n/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return CustomScrollView(
      slivers: [
        SliverAppBar.large(
          title: Text(
            l10n.libraryTitle,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w300,
              letterSpacing: 2,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList.list(
            children: [
              // Search bar
              TextField(
                decoration: InputDecoration(
                  hintText: l10n.searchHint,
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Church Fathers section
              _SectionHeader(title: l10n.churchFathers),
              const SizedBox(height: 12),
            ],
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList.separated(
            itemCount: _churchFathers.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final item = _churchFathers[index];
              return _LibraryItem(
                title: item.$1,
                subtitle: item.$2,
                icon: item.$3,
                onTap: () => context.push('/reader/sample'),
              );
            },
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList.list(
            children: [
              const SizedBox(height: 28),
              _SectionHeader(title: l10n.christianClassics),
              const SizedBox(height: 12),
            ],
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList.separated(
            itemCount: _classics.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final item = _classics[index];
              return _LibraryItem(
                title: item.$1,
                subtitle: item.$2,
                icon: item.$3,
                onTap: () => context.push('/reader/sample'),
              );
            },
          ),
        ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
      ],
    );
  }
}

const _churchFathers = [
  ('Didache', 'Nauka Dwunastu Apostołów • ok. 50-120', Icons.menu_book_rounded),
  ('List do Diogneta', 'Anonim • ok. II w.', Icons.history_edu_rounded),
  ('Wyznania', 'Św. Augustyn z Hippony • 397-400', Icons.auto_stories_rounded),
  ('O Wcieleniu Słowa', 'Św. Atanazy Wielki • ok. 318', Icons.church_rounded),
  ('Katechezy', 'Św. Cyryl Jerozolimski • ok. 350', Icons.school_rounded),
];

const _classics = [
  ('Reguła', 'Św. Benedykt z Nursji • ok. 516', Icons.account_balance_rounded),
  ('Naśladowanie Chrystusa', 'Tomasz à Kempis • ok. 1418-1427', Icons.favorite_rounded),
  ('Ćwiczenia duchowne', 'Św. Ignacy Loyola • 1548', Icons.self_improvement_rounded),
];

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _LibraryItem extends StatelessWidget {
  const _LibraryItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: cs.secondaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: cs.onSecondaryContainer, size: 22),
        ),
        title: Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: cs.onSurfaceVariant,
          ),
        ),
        trailing: Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
        onTap: onTap,
      ),
    );
  }
}
