import 'package:drift/drift.dart';

import '../../../core/database/tables/sync_columns.dart';

/// Sexo biológico do paciente (relevante para referências clínicas).
enum PatientSex { feminino, masculino, outro }

/// Ficha de paciente.
class Patients extends Table with SyncColumns {
  /// Nº de processo, sequencial e legível (ex.: 42 → "0042"). Único.
  /// Gerado automaticamente ao criar o paciente.
  IntColumn get processNumber => integer()();

  TextColumn get fullName => text().withLength(min: 1, max: 160)();

  DateTimeColumn get dateOfBirth => dateTime().nullable()();

  /// Guardado como `PatientSex.name`.
  TextColumn get sex =>
      text().withLength(min: 1, max: 10).nullable()();

  /// Documento de identificação (BI, passaporte, …).
  TextColumn get idDocument => text().nullable()();

  /// NIF / número de contribuinte (para recibos).
  TextColumn get taxId => text().nullable()();

  TextColumn get phone => text().nullable()();
  TextColumn get phoneAlt => text().nullable()();
  TextColumn get email => text().nullable()();

  TextColumn get address => text().nullable()();
  TextColumn get city => text().nullable()();
  TextColumn get province => text().nullable()();

  /// Contacto de emergência.
  TextColumn get nextOfKinName => text().nullable()();
  TextColumn get nextOfKinPhone => text().nullable()();

  /// Dados clínicos de referência rápida.
  TextColumn get bloodType => text().nullable()();
  TextColumn get allergies => text().nullable()();
  TextColumn get chronicConditions => text().nullable()();

  TextColumn get notes => text().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {processNumber},
      ];
}
