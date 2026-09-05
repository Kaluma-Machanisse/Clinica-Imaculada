import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/tables/sync_columns.dart';
import 'anamnesis_table.dart';

part 'anamnesis_dao.g.dart';

@DriftAccessor(tables: [AnamnesisEntries])
class AnamnesisDao extends DatabaseAccessor<AppDatabase>
    with _$AnamnesisDaoMixin {
  AnamnesisDao(super.db);

  /// Histórico de anamneses de um paciente, mais recente primeiro.
  Stream<List<AnamnesisEntry>> watchByPatient(String patientId) {
    return (select(anamnesisEntries)
          ..where((a) =>
              a.patientId.equals(patientId) & a.isDeleted.equals(false))
          ..orderBy([
            (a) => OrderingTerm(
                  expression: a.createdAt,
                  mode: OrderingMode.desc,
                ),
          ]))
        .watch();
  }

  Future<AnamnesisEntry?> getById(String id) =>
      (select(anamnesisEntries)..where((a) => a.id.equals(id)))
          .getSingleOrNull();

  Future<AnamnesisEntry> create(AnamnesisEntriesCompanion entry) {
    return into(anamnesisEntries).insertReturning(
      entry.copyWith(
        updatedAt: Value(DateTime.now()),
        syncState: const Value(SyncStates.pending),
      ),
    );
  }

  Future<void> updateAnamnesis(String id, AnamnesisEntriesCompanion changes) {
    return (update(anamnesisEntries)..where((a) => a.id.equals(id))).write(
      changes.copyWith(
        updatedAt: Value(DateTime.now()),
        syncState: const Value(SyncStates.pending),
      ),
    );
  }
}
