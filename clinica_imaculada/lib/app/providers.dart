import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/auth/auth_service.dart';
import '../core/auth/session.dart';
import '../core/database/app_database.dart';
import '../core/database/daos/audit_dao.dart';
import '../core/database/daos/users_dao.dart';
import '../core/sync/sync_service.dart';
import '../core/sync/sync_status.dart';

/// Base de dados local. Fornecida por `override` em `main()`, depois de a
/// chave de cifra ser lida do cofre do sistema.
final appDatabaseProvider = Provider<AppDatabase>(
  (ref) => throw StateError('appDatabaseProvider não foi inicializado'),
);

/// Serviço de sincronização. Também fornecido por `override` em `main()`.
final syncServiceProvider = Provider<SyncService>(
  (ref) => throw StateError('syncServiceProvider não foi inicializado'),
);

/// Valor lido uma vez no arranque: já existe algum utilizador?
final initialHasUsersProvider = Provider<bool>(
  (ref) => throw StateError('initialHasUsersProvider não foi inicializado'),
);

final usersDaoProvider = Provider<UsersDao>(
  (ref) => ref.watch(appDatabaseProvider).usersDao,
);

final auditDaoProvider = Provider<AuditDao>(
  (ref) => ref.watch(appDatabaseProvider).auditDao,
);

final authServiceProvider = Provider<AuthService>(
  (ref) => AuthService(
    usersDao: ref.watch(usersDaoProvider),
    auditDao: ref.watch(auditDaoProvider),
  ),
);

/// Estado do serviço de sincronização (para o indicador na interface).
final syncStatusProvider = StreamProvider<SyncStatus>(
  (ref) => ref.watch(syncServiceProvider).statusStream,
);

/// Se já existe pelo menos um utilizador. Começa com o valor lido no arranque
/// e passa a `true` assim que o primeiro utilizador (admin) é criado.
class HasUsersController extends Notifier<bool> {
  @override
  bool build() => ref.watch(initialHasUsersProvider);

  void markUserCreated() => state = true;
}

final hasUsersProvider =
    NotifierProvider<HasUsersController, bool>(HasUsersController.new);

/// Sessão atual (null = sem sessão iniciada).
class SessionController extends Notifier<AppSession?> {
  @override
  AppSession? build() => null;

  void setSession(AppSession session) => state = session;

  Future<void> signOut() async {
    final current = state;
    state = null;
    if (current != null) {
      await ref.read(authServiceProvider).logout(current);
    }
  }
}

final sessionProvider =
    NotifierProvider<SessionController, AppSession?>(SessionController.new);
