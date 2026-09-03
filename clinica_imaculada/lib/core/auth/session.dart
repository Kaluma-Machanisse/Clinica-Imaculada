import 'permissions.dart';
import 'user_role.dart';

/// Sessão do utilizador com sessão iniciada.
class AppSession {
  const AppSession({
    required this.userId,
    required this.username,
    required this.fullName,
    required this.role,
    required this.loginAt,
  });

  final String userId;
  final String username;
  final String fullName;
  final UserRole role;
  final DateTime loginAt;

  /// Secções que este utilizador pode abrir.
  Set<AppSection> get allowedSections => Permissions.sectionsFor(role);

  bool can(AppSection section) => Permissions.can(role, section);
}
