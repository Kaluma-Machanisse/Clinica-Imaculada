import 'user_role.dart';

/// Secções funcionais da aplicação. Cada rota principal pertence a uma secção.
enum AppSection {
  pacientes,
  consultas,
  anamnese,
  exames,
  farmacia,
  faturacao,
  caixa,
  relatorios,
  administracao,
}

/// Matriz de acesso: que secções cada perfil pode abrir.
///
/// Regras acordadas:
/// - Recepção: pacientes, consultas, faturação/recibos, stock (farmácia), caixa.
/// - Farmacêutico: farmácia (stock e dispensa), caixa.
/// - Médico: pacientes (clínico), consultas, anamnese, exames.
/// - Admin: tudo.
class Permissions {
  const Permissions._();

  static const Map<UserRole, Set<AppSection>> _matrix = {
    UserRole.recepcao: {
      AppSection.pacientes,
      AppSection.consultas,
      AppSection.faturacao,
      AppSection.farmacia,
      AppSection.caixa,
    },
    UserRole.farmaceutico: {
      AppSection.farmacia,
      AppSection.caixa,
    },
    UserRole.medico: {
      AppSection.pacientes,
      AppSection.consultas,
      AppSection.anamnese,
      AppSection.exames,
    },
    UserRole.admin: {
      AppSection.pacientes,
      AppSection.consultas,
      AppSection.anamnese,
      AppSection.exames,
      AppSection.farmacia,
      AppSection.faturacao,
      AppSection.caixa,
      AppSection.relatorios,
      AppSection.administracao,
    },
  };

  /// Secções permitidas a um perfil.
  static Set<AppSection> sectionsFor(UserRole role) =>
      _matrix[role] ?? const {};

  /// Se um perfil pode aceder a uma secção.
  static bool can(UserRole role, AppSection section) =>
      sectionsFor(role).contains(section);
}
