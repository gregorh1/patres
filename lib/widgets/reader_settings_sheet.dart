import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:patres/blocs/reader_bloc.dart';
import 'package:patres/blocs/reader_event.dart';
import 'package:patres/blocs/reader_state.dart';
import 'package:patres/l10n/generated/app_localizations.dart';

class ReaderSettingsSheet extends StatelessWidget {
  const ReaderSettingsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return BlocBuilder<ReaderBloc, ReaderState>(
      builder: (context, state) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
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
                const SizedBox(height: 20),

                // Title
                Text(
                  l10n.readerSettings,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),

                // Font size selector
                Text(
                  l10n.fontSize,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: List.generate(5, (index) {
                    final isSelected = state.fontSizeIndex == index;
                    final sampleSize = 12.0 + index * 3.0;
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: index < 4 ? 8 : 0,
                        ),
                        child: Material(
                          color: isSelected
                              ? cs.primaryContainer
                              : cs.surfaceContainerHighest
                                  .withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              context.read<ReaderBloc>().add(
                                    ReaderFontSizeChanged(
                                        fontSizeIndex: index),
                                  );
                            },
                            child: Container(
                              height: 48,
                              alignment: Alignment.center,
                              child: Text(
                                ReaderState.fontSizeLabels[index],
                                style: TextStyle(
                                  fontSize: sampleSize,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w400,
                                  color: isSelected
                                      ? cs.onPrimaryContainer
                                      : cs.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),

                // Font family selector
                Text(
                  l10n.fontFamily,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _FontFamilyChip(
                      fontFamily: 'Lora',
                      isSelected: state.fontFamily == 'Lora',
                      onTap: () {
                        context.read<ReaderBloc>().add(
                              const ReaderFontFamilyChanged(
                                  fontFamily: 'Lora'),
                            );
                      },
                    ),
                    const SizedBox(width: 12),
                    _FontFamilyChip(
                      fontFamily: 'Merriweather',
                      isSelected: state.fontFamily == 'Merriweather',
                      onTap: () {
                        context.read<ReaderBloc>().add(
                              const ReaderFontFamilyChanged(
                                  fontFamily: 'Merriweather'),
                            );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Preview text
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Ąą Ęę Ćć Łł Ńń Óó Śś Źź Żż',
                    style: GoogleFonts.getFont(
                      state.fontFamily,
                      fontSize: state.fontSize,
                      height: 1.6,
                      color: cs.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FontFamilyChip extends StatelessWidget {
  const _FontFamilyChip({
    required this.fontFamily,
    required this.isSelected,
    required this.onTap,
  });

  final String fontFamily;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Expanded(
      child: Material(
        color: isSelected
            ? cs.primaryContainer
            : cs.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            height: 52,
            alignment: Alignment.center,
            child: Text(
              fontFamily,
              style: GoogleFonts.getFont(
                fontFamily,
                fontSize: 16,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? cs.onPrimaryContainer
                    : cs.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
