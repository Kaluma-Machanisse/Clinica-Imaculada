import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/tables/sync_columns.dart';
import 'patients_table.dart';

part 'patients_dao.g.dart';

@DriftAccessor(tables: [Patients])
class PatientsDao extends DatabaseAccessor<AppDatabase> with _$PatientsDaoMixin {
  PatientsDao(super.db);

  /// Lista reativa de pacientes não apagados, opcionalmente filtrada por
  /// [query] (nome, telefone ou nº de processo). Ordenada por nome.
  Stream<List<Patient>> watchList({String query = '', int limit = 200}) {
    final q = query.trim().toLowerCase();
    final select = this.select(patients)
      ..where((p) => p.isDeleted.equals(false))
      ..orderBy([(p) => OrderingTerm(expression: p.fullName)])
      ..limit(limit);

    if (q.isNotEmpty) {
      final asNumber = int.tryParse(q);
      select.where((p) {
        var expr = p.fullName.lower().contains(q) |
            p.phone.lower().contains(q) |
            p.phoneAlt.lower().contains(q);
        if (asNumber != null) {
          expr = expr | p.processNumber.equals(asNumber);
        }
        return expr;
      });
    }
    return select.watch();
  }

  Future<Patient?> getById(String id) =>
      (select(patients)..where((p) => p.id.equals(id))).getSingleOrNull();

  Future<int> countActive() async {
    final c = patients.id.count();
    final row = await (selectOnly(patients)
          ..addColumns([c])
          ..where(patients.isDeleted.equals(false)))
        .getSingle();
    return row.read(c) ?? 0;
  }

  /// Cria um paciente, atribuindo o próximo nº de processo dentro de uma
  /// transação (evita duplicados).
  Future<Patient> createPatient(PatientsCompanion entry) {
    return transaction(() async {
      final maxExpr = patients.processNumber.max();
      final row =
          await (selectOnly(patients)..addColumns([maxExpr])).getSingle();
      final next = (row.read(maxExpr) ?? 0) + 1;

      final toInsert = entry.copyWith(
        processNumber: Value(next),
        updatedAt: Value(DateTime.now()),
        syncState: const Value(SyncStates.pending),
      );
      return into(patients).insertReturning(toInsert);
    });
  }

  Future<void> updatePatient(String id, PatientsCompanion changes) {
    return (update(patients)..where((p) => p.id.equals(id))).write(
      changes.copyWith(
        updatedAt: Value(DateTime.now()),
        syncState: const Value(SyncStates.pending),
      ),
    );
  }

  /// Apagamento lógico (a linha só é removida de vez após sincronizar).
  Future<void> softDelete(String id) {
    return (update(patients)..where((p) => p.id.equals(id))).write(
      PatientsCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(DateTime.now()),
        syncState: const Value(SyncStates.pending),
      ),
    );
  }
}
