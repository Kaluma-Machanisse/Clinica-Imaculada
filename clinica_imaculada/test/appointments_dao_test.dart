@TestOn('vm')
library;

import 'package:clinica_imaculada/core/database/app_database.dart';
import 'package:clinica_imaculada/features/appointments/data/appointments_table.dart';
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
      const PatientsCompanion(fullName: Value('Paciente Teste')),
    );
    patientId = patient.id;

    await db.usersDao.insertUser(UsersCompanion.insert(
      fullName: 'Dr(a). Teste',
      username: 'medico.teste',
      passwordHash: 'x',
      role: 'medico',
    ));
    final created = await db.usersDao.findByUsername('medico.teste');
    doctorId = created!.id;
  });

  tearDown(() => db.close());

  test('cria consulta e aparece na agenda do dia com nomes resolvidos', () async {
    final day = DateTime(2026, 1, 15, 9, 30);
    await db.appointmentsDao.create(AppointmentsCompanion.insert(
      patientId: patientId,
      doctorId: doctorId,
      scheduledAt: day,
    ));

    final items = await db.appointmentsDao.watchByDay(DateTime(2026, 1, 15)).first;
    expect(items, hasLength(1));
    expect(items.single.patientName, 'Paciente Teste');
    expect(items.single.doctorName, 'Dr(a). Teste');
    expect(items.single.appointment.status, 'agendada');
  });

  test('não aparece em dias diferentes', () async {
    await db.appointmentsDao.create(AppointmentsCompanion.insert(
      patientId: patientId,
      doctorId: doctorId,
      scheduledAt: DateTime(2026, 1, 15, 9, 30),
    ));

    final other = await db.appointmentsDao.watchByDay(DateTime(2026, 1, 16)).first;
    expect(other, isEmpty);
  });

  test('alterar estado reflete-se na consulta', () async {
    final appt = await db.appointmentsDao.create(AppointmentsCompanion.insert(
      patientId: patientId,
      doctorId: doctorId,
      scheduledAt: DateTime(2026, 1, 15, 9, 30),
    ));

    await db.appointmentsDao.setStatus(appt.id, AppointmentStatus.confirmada);
    final updated = await db.appointmentsDao.getById(appt.id);
    expect(updated!.status, 'confirmada');
  });

  test('apagamento lógico remove da agenda', () async {
    final appt = await db.appointmentsDao.create(AppointmentsCompanion.insert(
      patientId: patientId,
      doctorId: doctorId,
      scheduledAt: DateTime(2026, 1, 15, 9, 30),
    ));

    await db.appointmentsDao.softDelete(appt.id);
    final items = await db.appointmentsDao.watchByDay(DateTime(2026, 1, 15)).first;
    expect(items, isEmpty);
  });
}
