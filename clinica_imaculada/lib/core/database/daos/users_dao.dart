import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/sync_columns.dart';
import '../tables/users.dart';

part 'users_dao.g.dart';

/// Acesso aos dados de utilizadores.
///
/// Não guarda senhas em texto: recebe e devolve sempre o hash bcrypt.
@DriftAccessor(tables: [Users])
class UsersDao extends DatabaseAccessor<AppDatabase> with _$UsersDaoMixin {
  UsersDao(super.db);

  /// Nº de utilizadores existentes (para detetar o primeiro arranque).
  Future<int> countAll() async {
    final count = users.id.count();
    final query = selectOnly(users)..addColumns([count]);
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  /// Procura um utilizador pelo nome de utilizador (case-insensitive).
  Future<User?> findByUsername(String username) {
    final normalized = username.trim().toLowerCase();
    return (select(users)
          ..where((u) => u.username.lower().equals(normalized))
          ..limit(1))
        .getSingleOrNull();
  }

  Future<User?> findById(String id) {
    return (select(users)..where((u) => u.id.equals(id))).getSingleOrNull();
  }

  /// Lista utilizadores ativos e não apagados, por nome.
  Future<List<User>> listActive() {
    return (select(users)
          ..where((u) => u.isActive.equals(true) & u.isDeleted.equals(false))
          ..orderBy([(u) => OrderingTerm(expression: u.fullName)]))
        .get();
  }

  Future<void> insertUser(UsersCompanion user) => into(users).insert(user);

  /// Início de sessão bem-sucedido: limpa tentativas falhadas e atualiza a
  /// data do último acesso.
  Future<void> markLoginSuccess(String id) {
    final now = DateTime.now();
    return (update(users)..where((u) => u.id.equals(id))).write(
      UsersCompanion(
        failedAttempts: const Value(0),
        lockedUntil: const Value(null),
        lastLoginAt: Value(now),
        updatedAt: Value(now),
        syncState: const Value(SyncStates.pending),
      ),
    );
  }

  /// Tentativa falhada; ao atingir o limite, [lockedUntil] fica preenchido.
  Future<void> markLoginFailure(
    String id, {
    required int newFailedCount,
    DateTime? lockedUntil,
  }) {
    return (update(users)..where((u) => u.id.equals(id))).write(
      UsersCompanion(
        failedAttempts: Value(newFailedCount),
        lockedUntil: Value(lockedUntil),
        updatedAt: Value(DateTime.now()),
        syncState: const Value(SyncStates.pending),
      ),
    );
  }
}
