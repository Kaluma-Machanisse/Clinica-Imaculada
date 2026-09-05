import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/tables/sync_columns.dart';
import '../../../core/database/tables/users.dart';
import '../../patients/data/patients_table.dart';
import 'appointment_list_item.dart';
import 'appointments_table.dart';

part 'appointments_dao.g.dart';

@DriftAccessor(tables: [Appointments, Patients, Users])
class AppointmentsDao extends DatabaseAccessor<AppDatabase>
    with _$AppointmentsDaoMixin {
  AppointmentsDao(super.db);

  Stream<List<AppointmentListItem>> _watchJoined(
    Expression<bool> Function() where,
  ) {
    final query = select(appointments).join([
      innerJoin(patients, patients.id.equalsExp(appointments.patientId)),
      innerJoin(users, users.id.equalsExp(appointments.doctorId)),
    ])
      ..where(appointments.isDeleted.equals(false) & where())
      ..orderBy([OrderingTerm(expression: appointments.scheduledAt)]);

    return query.watch().map(
          (rows) => rows
              .map((row) => AppointmentListItem(
                    appointment: row.readTable(appointments),
                    patientName: row.readTable(patients).fullName,
                    doctorName: row.readTable(users).fullName,
                  ))
              .toList(),
        );
  }

  /// Consultas de um dia (data local, sem hora).
  Stream<List<AppointmentListItem>> watchByDay(DateTime day) {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    return _watchJoined(
      () =>
          appointments.scheduledAt.isBiggerOrEqualValue(start) &
          appointments.scheduledAt.isSmallerThanValue(end),
    );
  }

  /// Todas as consultas (passadas e futuras) de um paciente, mais recentes
  /// primeiro.
  Stream<List<AppointmentListItem>> watchByPatient(String patientId) {
    final query = select(appointments).join([
      innerJoin(patients, patients.id.equalsExp(appointments.patientId)),
      innerJoin(users, users.id.equalsExp(appointments.doctorId)),
    ])
      ..where(appointments.isDeleted.equals(false) &
          appointments.patientId.equals(patientId))
      ..orderBy([
        OrderingTerm(
          expression: appointments.scheduledAt,
          mode: OrderingMode.desc,
        ),
      ]);
    return query.watch().map(
          (rows) => rows
              .map((row) => AppointmentListItem(
                    appointment: row.readTable(appointments),
                    patientName: row.readTable(patients).fullName,
                    doctorName: row.readTable(users).fullName,
                  ))
              .toList(),
        );
  }

  Future<Appointment?> getById(String id) =>
      (select(appointments)..where((a) => a.id.equals(id))).getSingleOrNull();

  Future<Appointment> create(AppointmentsCompanion entry) {
    return into(appointments).insertReturning(
      entry.copyWith(
        updatedAt: Value(DateTime.now()),
        syncState: const Value(SyncStates.pending),
      ),
    );
  }

  Future<void> updateAppointment(String id, AppointmentsCompanion changes) {
    return (update(appointments)..where((a) => a.id.equals(id))).write(
      changes.copyWith(
        updatedAt: Value(DateTime.now()),
        syncState: const Value(SyncStates.pending),
      ),
    );
  }

  Future<void> setStatus(String id, AppointmentStatus status) {
    return (update(appointments)..where((a) => a.id.equals(id))).write(
      AppointmentsCompanion(
        status: Value(status.name),
        updatedAt: Value(DateTime.now()),
        syncState: const Value(SyncStates.pending),
      ),
    );
  }

  Future<void> softDelete(String id) {
    return (update(appointments)..where((a) => a.id.equals(id))).write(
      AppointmentsCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(DateTime.now()),
        syncState: const Value(SyncStates.pending),
      ),
    );
  }
}
