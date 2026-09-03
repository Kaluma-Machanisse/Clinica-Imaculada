import 'package:drift/drift.dart';

import 'sync_columns.dart';

/// Utilizadores do sistema e respetivo perfil de acesso.
///
/// A senha nunca é guardada em texto: apenas o hash bcrypt em [passwordHash].
class Users extends Table with SyncColumns {
  /// Nome completo, para mostrar na interface e em registos de auditoria.
  TextColumn get fullName => text().withLength(min: 1, max: 120)();

  /// Nome de utilizador para início de sessão (único, sem espaços).
  TextColumn get username => text().withLength(min: 3, max: 40)();

  /// Hash bcrypt da senha.
  TextColumn get passwordHash => text()();

  /// Perfil de acesso — valor de `UserRole.name`
  /// (recepcao | farmaceutico | medico | admin).
  TextColumn get role => text().withLength(min: 3, max: 20)();

  /// Se `false`, o utilizador não pode iniciar sessão.
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  /// Nº de tentativas de início de sessão falhadas consecutivas.
  IntColumn get failedAttempts => integer().withDefault(const Constant(0))();

  /// Bloqueado até este momento (após demasiadas tentativas falhadas).
  DateTimeColumn get lockedUntil => dateTime().nullable()();

  /// Último início de sessão bem-sucedido.
  DateTimeColumn get lastLoginAt => dateTime().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {username},
      ];
}
