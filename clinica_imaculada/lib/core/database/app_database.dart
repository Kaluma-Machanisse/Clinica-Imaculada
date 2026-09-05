import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../features/anamnesis/data/anamnesis_dao.dart';
import '../../features/anamnesis/data/anamnesis_table.dart';
import '../../features/appointments/data/appointments_dao.dart';
import '../../features/appointments/data/appointments_table.dart';
import '../../features/patients/data/patients_dao.dart';
import '../../features/patients/data/patients_table.dart';
import 'daos/audit_dao.dart';
import 'daos/users_dao.dart';
import 'database_key.dart';
import 'tables/audit_logs.dart';
import 'tables/users.dart';

part 'app_database.g.dart';

/// Base de dados local da aplicação (SQLite cifrado em disco).
///
/// Toda a leitura e escrita da aplicação passa por aqui. A cópia para a nuvem
/// é feita à parte pelo serviço de sincronização, sem bloquear estas operações.
@DriftDatabase(
  tables: [Users, AuditLogs, Patients, Appointments, AnamnesisEntries],
  daos: [UsersDao, AuditDao, PatientsDao, AppointmentsDao, AnamnesisDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(String encryptionKeyHex)
      : super(_openConnection(encryptionKeyHex));

  /// Construtor para testes: recebe um executor já pronto (ex.: em memória).
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(patients);
          }
          if (from < 3) {
            await m.createTable(appointments);
            await m.createTable(anamnesisEntries);
          }
        },
        beforeOpen: (details) async {
          // Garante integridade referencial em todas as ligações.
          await customStatement('PRAGMA foreign_keys = ON;');
        },
      );

  static QueryExecutor _openConnection(String encryptionKeyHex) {
    final keyLiteral = pragmaKeyLiteral(encryptionKeyHex);

    return driftDatabase(
      name: 'clinica_imaculada',
      native: DriftNativeOptions(
        databaseDirectory: getApplicationSupportDirectory,
        setup: (db) {
          // Confirma que a build com cifra está ativa ANTES de escrever
          // qualquer dado. `PRAGMA cipher` responde na build "sqlite3mc";
          // `PRAGMA cipher_version` responde na build "sqlcipher".
          final hasCipher = db.select('PRAGMA cipher;').isNotEmpty ||
              db.select('PRAGMA cipher_version;').isNotEmpty;
          if (!hasCipher) {
            throw StateError(
              'A base de dados não seria cifrada: a build com cifra '
              '("sqlite3mc") não está ativa. Verifique a secção "hooks" do '
              'pubspec.yaml. Arranque interrompido para não gravar dados '
              'clínicos em claro.',
            );
          }

          // A chave TEM de ser aplicada antes de qualquer leitura/escrita.
          db.execute('PRAGMA key = "$keyLiteral";');
        },
      ),
    );
  }
}
