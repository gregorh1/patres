import 'package:flutter/material.dart';
import 'package:patres/l10n/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';

class ShellScaffold extends StatelessWidget {
  const ShellScaffold({super.key, required this.child});
  final Widget child;

  static const _tabs = ['/home', '/library', '/plans', '/settings'];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final index = _tabs.indexWhere((tab) => location.startsWith(tab));
    return index >= 0 ? index : 0;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final index = _currentIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => context.go(_tabs[i]),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: l10n.homeTab,
          ),
          NavigationDestination(
            icon: const Icon(Icons.local_library_outlined),
            selectedIcon: const Icon(Icons.local_library),
            label: l10n.libraryTab,
          ),
          NavigationDestination(
            icon: const Icon(Icons.calendar_today_outlined),
            selectedIcon: const Icon(Icons.calendar_today),
            label: l10n.plansTab,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: l10n.settingsTab,
          ),
        ],
      ),
    );
  }
}
