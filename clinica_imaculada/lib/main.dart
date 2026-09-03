import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';

import 'app/app.dart';
import 'app/providers.dart';
import 'core/auth/auth_service.dart';
import 'core/database/app_database.dart';
import 'core/database/daos/audit_dao.dart';
import 'core/database/database_key.dart';
import 'core/sync/sync_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _setupLogging();

  // 1. Chave de cifra da base de dados (criada no 1.º arranque, guardada no
  //    cofre seguro do sistema operativo).
  final encryptionKey = await DatabaseKey().getOrCreate();

  // 2. Base de dados local cifrada.
  final database = AppDatabase(encryptionKey);

  // 3. Regista o arranque na auditoria.
  await AuditDao(database).record(action: 'app_start');

  // 4. Serviço de sincronização (por agora, não fala com nenhuma nuvem).
  final SyncService sync = NoOpSyncService();
  await sync.start();

  // 5. Primeiro arranque? (ainda não há utilizadores)
  final hasUsers = await AuthService(
    usersDao: database.usersDao,
    auditDao: database.auditDao,
  ).hasAnyUser();

  runApp(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        syncServiceProvider.overrideWithValue(sync),
        initialHasUsersProvider.overrideWithValue(hasUsers),
      ],
      child: const ClinicaApp(),
    ),
  );
}

void _setupLogging() {
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen((record) {
    // ignore: avoid_print
    print('[${record.level.name}] ${record.loggerName}: ${record.message}');
  });
}
