import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/audit_logs.dart';

part 'audit_dao.g.dart';

/// Escrita e leitura do registo de auditoria.
///
/// As linhas nunca são alteradas nem apagadas: só se inserem e se leem.
@DriftAccessor(tables: [AuditLogs])
class AuditDao extends DatabaseAccessor<AppDatabase> with _$AuditDaoMixin {
  AuditDao(super.db);

  Future<void> record({
    String? userId,
    String? username,
    required String action,
    String? entity,
    String? entityId,
    String? details,
  }) {
    return into(auditLogs).insert(
      AuditLogsCompanion.insert(
        userId: Value(userId),
        username: Value(username),
        action: action,
        entity: Value(entity),
        entityId: Value(entityId),
        details: Value(details),
      ),
    );
  }

  /// Eventos mais recentes, para o ecrã de auditoria (admin).
  Future<List<AuditLog>> recent({int limit = 200}) {
    return (select(auditLogs)
          ..orderBy([
            (a) => OrderingTerm(
                  expression: a.timestamp,
                  mode: OrderingMode.desc,
                ),
          ])
          ..limit(limit))
        .get();
  }

  /// Linhas ainda não copiadas para a nuvem.
  Future<List<AuditLog>> pendingSync({int limit = 500}) {
    return (select(auditLogs)
          ..where((a) => a.isSynced.equals(false))
          ..limit(limit))
        .get();
  }
}
