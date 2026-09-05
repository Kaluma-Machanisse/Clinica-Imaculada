@TestOn('vm')
library;

import 'package:clinica_imaculada/core/database/app_database.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late String patientId;
  late String doctorId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());

    final patient = await db.patientsDao.createPatient(
      const PatientsCompanion(fullName: Value('Paciente Anamnese')),
    );
    patientId = patient.id;

    await db.usersDao.insertUser(UsersCompanion.insert(
      fullName: 'Dr(a). Anamnese',
      username: 'medico.anamnese',
      passwordHash: 'x',
      role: 'medico',
    ));
    doctorId = (await db.usersDao.findByUsername('medico.anamnese'))!.id;
  });

  tearDown(() => db.close());

  test('cria e lista anamneses de um paciente, mais recente primeiro', () async {
    await db.anamnesisDao.create(AnamnesisEntriesCompanion.insert(
      patientId: patientId,
      doctorId: doctorId,
      complaint: const Value('Febre'),
      createdAt: Value(DateTime(2026, 1, 1, 8)),
    ));
    await db.anamnesisDao.create(AnamnesisEntriesCompanion.insert(
      patientId: patientId,
      doctorId: doctorId,
      complaint: const Value('Tosse'),
      createdAt: Value(DateTime(2026, 1, 2, 8)),
    ));

    final entries = await db.anamnesisDao.watchByPatient(patientId).first;
    expect(entries, hasLength(2));
    expect(entries.first.complaint, 'Tosse');
  });

  test('atualização marca sync_state pendente', () async {
    final entry = await db.anamnesisDao.create(AnamnesisEntriesCompanion.insert(
      patientId: patientId,
      doctorId: doctorId,
    ));
    await db.anamnesisDao.updateAnamnesis(
      entry.id,
      const AnamnesisEntriesCompanion(diagnosis: Value('Gripe')),
    );
    final updated = await db.anamnesisDao.getById(entry.id);
    expect(updated!.diagnosis, 'Gripe');
    expect(updated.syncState, 'pending');
  });
}
