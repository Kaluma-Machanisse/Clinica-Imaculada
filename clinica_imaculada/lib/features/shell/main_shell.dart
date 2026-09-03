import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/sections.dart';
import 'sync_indicator.dart';

/// Estrutura visual da área autenticada: barra lateral de navegação (filtrada
/// pelo perfil) + barra superior com utilizador, sincronização e terminar sessão.
class MainShell extends ConsumerWidget {
  const MainShell({super.key, required this.location, required this.child});

  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    if (session == null) {
      return const Scaffold(body: SizedBox.shrink());
    }

    final visible = kSectionRoutes
        .where((r) => session.can(r.section))
        .toList(growable: false);

    final currentRoute = sectionRouteForPath(location);
    final selectedIndex = currentRoute == null
        ? 0
        : visible.indexWhere((r) => r.section == currentRoute.section).clamp(0, visible.length - 1);

    return Scaffold(
      appBar: AppBar(
        title: Text(currentRoute?.label ?? 'Clínica Imaculada'),
        actions: [
          const SyncIndicator(),
          const SizedBox(width: 16),
          Center(
            child: Text(
              '${session.fullName}  ·  ${session.role.label}',
              style: const TextStyle(fontSize: 13),
            ),
          ),
          IconButton(
            tooltip: 'Terminar sessão',
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(sessionProvider.notifier).signOut(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: selectedIndex,
            onDestinationSelected: (i) => context.go(visible[i].path),
            labelType: NavigationRailLabelType.all,
            destinations: [
              for (final r in visible)
                NavigationRailDestination(
                  icon: Icon(r.icon),
                  label: Text(r.label),
                ),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }
}
