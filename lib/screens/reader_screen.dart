import 'package:flutter/material.dart';
import 'package:patres/l10n/generated/app_localizations.dart';

class ReaderScreen extends StatelessWidget {
  const ReaderScreen({super.key, required this.textId});
  final String textId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.readerTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title area
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cs.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.auto_stories_rounded,
                    size: 36,
                    color: cs.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Wyznania',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Św. Augustyn z Hippony',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Placeholder reading content
            Text(
              'Księga I',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Wielki jesteś, Panie, i godzien wielkiej chwały. '
              'Wielka jest potęga Twoja i mądrość Twoja jest niezmierzona. '
              'A oto człowiek, cząstka Twego stworzenia, pragnie Cię chwalić — '
              'człowiek, który dźwiga swą śmiertelność, '
              'dźwiga świadectwo swego grzechu '
              'i świadectwo, że pysznym się sprzeciwiasz.',
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.8,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'A jednak człowiek, cząstka Twego stworzenia, pragnie Cię chwalić. '
              'Ty sam sprawiasz, że znajduje on radość w oddawaniu Ci chwały, '
              'bo stworzyłeś nas dla siebie '
              'i niespokojne jest serce nasze, dopóki nie spocznie w Tobie.',
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.8,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  l10n.readerPlaceholder,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
