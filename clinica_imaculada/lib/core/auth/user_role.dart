/// Perfis de utilizador do sistema.
///
/// Cada perfil vê apenas a sua parte da aplicação. A verificação é feita em
/// duas camadas: nas guardas de navegação (router) e na camada de dados (DAOs).
enum UserRole {
  recepcao('Recepção'),
  farmaceutico('Farmacêutico'),
  medico('Médico'),
  admin('Administrador');

  const UserRole(this.label);

  /// Nome legível para mostrar na interface.
  final String label;

  /// Converte o valor guardado na base de dados para o enum.
  static UserRole fromName(String name) {
    return UserRole.values.firstWhere(
      (r) => r.name == name,
      orElse: () => throw ArgumentError('Perfil desconhecido: $name'),
    );
  }
}
