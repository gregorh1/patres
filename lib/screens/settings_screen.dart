import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:patres/l10n/generated/app_localizations.dart';
import 'package:patres/blocs/theme_bloc.dart';
import 'package:patres/models/app_theme_mode.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return CustomScrollView(
      slivers: [
        SliverAppBar.large(
          title: Text(
            l10n.settingsTitle,
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
              // Theme section
              Text(
                l10n.themeMode,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              BlocBuilder<ThemeBloc, ThemeState>(
                builder: (context, state) {
                  return _ThemeSelector(
                    currentMode: state.themeMode,
                    onChanged: (mode) {
                      context.read<ThemeBloc>().add(ThemeChanged(mode));
                    },
                  );
                },
              ),
              const SizedBox(height: 32),

              // About section
              Text(
                l10n.aboutApp,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: cs.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.auto_stories_rounded,
                              color: cs.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.appTitle,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${l10n.version} 0.1.0',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.aboutDescription,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ThemeSelector extends StatelessWidget {
  const _ThemeSelector({
    required this.currentMode,
    required this.onChanged,
  });

  final AppThemeMode currentMode;
  final ValueChanged<AppThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        _ThemeOption(
          label: l10n.themeLight,
          icon: Icons.light_mode_rounded,
          isSelected: currentMode == AppThemeMode.light,
          previewColors: (
            bg: const Color(0xFFFFFBFF),
            fg: const Color(0xFF201A18),
            accent: const Color(0xFF8B1A1A),
          ),
          onTap: () => onChanged(AppThemeMode.light),
        ),
        const SizedBox(width: 12),
        _ThemeOption(
          label: l10n.themeDark,
          icon: Icons.dark_mode_rounded,
          isSelected: currentMode == AppThemeMode.dark,
          previewColors: (
            bg: const Color(0xFF201A18),
            fg: const Color(0xFFFFFBFF),
            accent: const Color(0xFFFFB4A8),
          ),
          onTap: () => onChanged(AppThemeMode.dark),
        ),
        const SizedBox(width: 12),
        _ThemeOption(
          label: l10n.themeSepia,
          icon: Icons.auto_stories_rounded,
          isSelected: currentMode == AppThemeMode.sepia,
          previewColors: (
            bg: const Color(0xFFF5ECD7),
            fg: const Color(0xFF3E2C1C),
            accent: const Color(0xFF6D4C2A),
          ),
          onTap: () => onChanged(AppThemeMode.sepia),
        ),
      ],
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.previewColors,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final ({Color bg, Color fg, Color accent}) previewColors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? cs.primaryContainer : cs.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? cs.primary : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              // Mini theme preview
              Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  color: previewColors.bg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: previewColors.fg.withValues(alpha: 0.15),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 32,
                      height: 4,
                      decoration: BoxDecoration(
                        color: previewColors.accent,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 44,
                      height: 3,
                      decoration: BoxDecoration(
                        color: previewColors.fg.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Container(
                      width: 38,
                      height: 3,
                      decoration: BoxDecoration(
                        color: previewColors.fg.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Icon(
                icon,
                size: 18,
                color: isSelected ? cs.onPrimaryContainer : cs.onSurfaceVariant,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isSelected ? cs.onPrimaryContainer : cs.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
