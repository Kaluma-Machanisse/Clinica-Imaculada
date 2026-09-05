import 'package:drift/drift.dart';

import '../../../core/database/tables/sync_columns.dart';
import '../../../core/database/tables/users.dart';
import '../../patients/data/patients_table.dart';

/// Estado de uma consulta marcada.
enum AppointmentStatus {
  agendada,
  confirmada,
  emAtendimento,
  concluida,
  cancelada,
  faltou,
}

class Appointments extends Table with SyncColumns {
  TextColumn get patientId =>
      text().references(Patients, #id, onDelete: KeyAction.restrict)();

  /// Médico responsável (utilizador com perfil `medico`).
  TextColumn get doctorId =>
      text().references(Users, #id, onDelete: KeyAction.restrict)();

  DateTimeColumn get scheduledAt => dateTime()();

  IntColumn get durationMinutes => integer().withDefault(const Constant(30))();

  /// Guardado como `AppointmentStatus.name`.
  TextColumn get status => text()
      .withLength(min: 1, max: 20)
      .withDefault(const Constant('agendada'))();

  TextColumn get reason => text().nullable()();
  TextColumn get notes => text().nullable()();
}
