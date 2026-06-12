import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../ui/features/projects/views/global_search_dialog.dart';
import '../constants/app_constants.dart';
import '../routes/app_routes.dart';

enum AppSection {
  dashboard,
  projects,
  structures,
  prompts,
  analytics,
  suggestions,
  settings
}

/// Estructura general con barra lateral de navegación.
class AppShell extends StatelessWidget {
  final AppSection selected;
  final Widget child;
  final Widget? footer;

  const AppShell({
    super.key,
    required this.selected,
    required this.child,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyK, meta: true):
            _openSearch,
        const SingleActivator(LogicalKeyboardKey.keyK, control: true):
            _openSearch,
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          body: Row(
            children: [
              _Sidebar(selected: selected),
              const VerticalDivider(width: 1),
              Expanded(
                child: Column(
                  children: [
                    Expanded(child: child),
                    ?footer,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openSearch() => Get.dialog(const GlobalSearchDialog());
}

class _Sidebar extends StatelessWidget {
  final AppSection selected;

  const _Sidebar({required this.selected});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 232,
      color: scheme.surfaceContainerLowest,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => Get.offAllNamed(AppRoutes.dashboard),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: scheme.primary,
                        borderRadius: BorderRadius.circular(7),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.edit_note,
                          size: 18, color: Colors.white),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      AppConstants.appName,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          _SearchButton(onTap: () => Get.dialog(const GlobalSearchDialog())),
          const SizedBox(height: 16),
          _NavItem(
            icon: Icons.dashboard_outlined,
            label: 'Inicio',
            isSelected: selected == AppSection.dashboard,
            onTap: () => Get.offAllNamed(AppRoutes.dashboard),
          ),
          _NavItem(
            icon: Icons.video_library_outlined,
            label: 'Proyectos',
            isSelected: selected == AppSection.projects,
            onTap: () => Get.offAllNamed(AppRoutes.projects),
          ),
          _NavItem(
            icon: Icons.account_tree_outlined,
            label: 'Estructuras',
            isSelected: selected == AppSection.structures,
            onTap: () => Get.offAllNamed(AppRoutes.structures),
          ),
          _NavItem(
            icon: Icons.auto_awesome_outlined,
            label: 'Prompts',
            isSelected: selected == AppSection.prompts,
            onTap: () => Get.offAllNamed(AppRoutes.prompts),
          ),
          _NavItem(
            icon: Icons.bar_chart_outlined,
            label: 'Estadísticas',
            isSelected: selected == AppSection.analytics,
            onTap: () => Get.offAllNamed(AppRoutes.analytics),
          ),
          _NavItem(
            icon: Icons.lightbulb_outline,
            label: 'Sugerencias',
            isSelected: selected == AppSection.suggestions,
            onTap: () => Get.offAllNamed(AppRoutes.suggestions),
          ),
          const Spacer(),
          _NavItem(
            icon: Icons.settings_outlined,
            label: 'Ajustes',
            isSelected: selected == AppSection.settings,
            onTap: () => Get.offAllNamed(AppRoutes.settings),
          ),
        ],
      ),
    );
  }
}

class _SearchButton extends StatelessWidget {
  final VoidCallback onTap;

  const _SearchButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Row(
            children: [
              Icon(Icons.search, size: 16, color: scheme.onSurfaceVariant),
              const SizedBox(width: 8),
              Text(
                'Buscar…',
                style: TextStyle(
                    fontSize: 13, color: scheme.onSurfaceVariant),
              ),
              const Spacer(),
              Text(
                '⌘K',
                style: TextStyle(
                    fontSize: 11, color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: isSelected ? scheme.surfaceContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 17,
                  color: isSelected ? scheme.primary : scheme.onSurfaceVariant,
                ),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? Theme.of(context).textTheme.bodyLarge?.color
                        : scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
