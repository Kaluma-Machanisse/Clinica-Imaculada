import 'package:drift/drift.dart';

import '../../../core/database/tables/sync_columns.dart';
import '../../../core/database/tables/users.dart';
import '../../appointments/data/appointments_table.dart';
import '../../patients/data/patients_table.dart';

/// Registo de anamnese (avaliação clínica) de um paciente.
///
/// Normalmente ligado a uma consulta, mas [appointmentId] é opcional para
/// permitir registar avaliações sem marcação prévia (ex.: urgência).
class AnamnesisEntries extends Table with SyncColumns {
  TextColumn get patientId =>
      text().references(Patients, #id, onDelete: KeyAction.restrict)();

  TextColumn get appointmentId =>
      text().nullable().references(Appointments, #id, onDelete: KeyAction.setNull)();

  TextColumn get doctorId =>
      text().references(Users, #id, onDelete: KeyAction.restrict)();

  /// Queixa principal.
  TextColumn get complaint => text().nullable()();

  /// História da doença atual.
  TextColumn get history => text().nullable()();

  /// Exame físico.
  TextColumn get physicalExam => text().nullable()();

  /// Sinais vitais (texto livre por agora: TA, FC, FR, Temp, SpO2, peso, altura).
  TextColumn get vitalSigns => text().nullable()();

  TextColumn get diagnosis => text().nullable()();

  /// Conduta / plano terapêutico.
  TextColumn get plan => text().nullable()();
}
