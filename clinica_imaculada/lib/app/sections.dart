import 'package:flutter/material.dart';

import '../core/auth/permissions.dart';

/// Descreve uma secção navegável: rota, rótulo e ícone.
class SectionRoute {
  const SectionRoute({
    required this.section,
    required this.path,
    required this.label,
    required this.icon,
  });

  final AppSection section;
  final String path;
  final String label;
  final IconData icon;
}

/// Todas as secções, pela ordem em que aparecem na barra lateral.
const List<SectionRoute> kSectionRoutes = [
  SectionRoute(
    section: AppSection.pacientes,
    path: '/pacientes',
    label: 'Pacientes',
    icon: Icons.people_outline,
  ),
  SectionRoute(
    section: AppSection.consultas,
    path: '/consultas',
    label: 'Consultas',
    icon: Icons.event_note_outlined,
  ),
  SectionRoute(
    section: AppSection.anamnese,
    path: '/anamnese',
    label: 'Anamnese',
    icon: Icons.assignment_outlined,
  ),
  SectionRoute(
    section: AppSection.exames,
    path: '/exames',
    label: 'Exames',
    icon: Icons.science_outlined,
  ),
  SectionRoute(
    section: AppSection.farmacia,
    path: '/farmacia',
    label: 'Farmácia',
    icon: Icons.medication_outlined,
  ),
  SectionRoute(
    section: AppSection.faturacao,
    path: '/faturacao',
    label: 'Faturação',
    icon: Icons.receipt_long_outlined,
  ),
  SectionRoute(
    section: AppSection.caixa,
    path: '/caixa',
    label: 'Caixa',
    icon: Icons.point_of_sale_outlined,
  ),
  SectionRoute(
    section: AppSection.relatorios,
    path: '/relatorios',
    label: 'Relatórios',
    icon: Icons.bar_chart_outlined,
  ),
  SectionRoute(
    section: AppSection.administracao,
    path: '/administracao',
    label: 'Administração',
    icon: Icons.admin_panel_settings_outlined,
  ),
];

SectionRoute? sectionRouteForPath(String path) {
  for (final r in kSectionRoutes) {
    if (path == r.path || path.startsWith('${r.path}/')) return r;
  }
  return null;
}
