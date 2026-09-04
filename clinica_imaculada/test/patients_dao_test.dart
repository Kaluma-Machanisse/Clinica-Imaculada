@TestOn('vm')
library;

import 'package:clinica_imaculada/core/database/app_database.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  PatientsCompanion nome(String n) =>
      PatientsCompanion(fullName: Value(n));

  test('atribui números de processo sequenciais', () async {
    final a = await db.patientsDao.createPatient(nome('Ana'));
    final b = await db.patientsDao.createPatient(nome('Bruno'));
    final c = await db.patientsDao.createPatient(nome('Carla'));

    expect(a.processNumber, 1);
    expect(b.processNumber, 2);
    expect(c.processNumber, 3);
  });

  test('pesquisa por nome, telefone e nº de processo', () async {
    await db.patientsDao.createPatient(PatientsCompanion(
      fullName: const Value('Maria Silva'),
      phone: const Value('810000001'),
    ));
    await db.patientsDao.createPatient(PatientsCompanion(
      fullName: const Value('João Santos'),
      phone: const Value('890000009'),
    ));

    expect((await db.patientsDao.watchList(query: 'silva').first).length, 1);
    expect((await db.patientsDao.watchList(query: '89000').first).single.fullName,
        'João Santos');
    // '2' = nº de processo do 2.º paciente (João); nenhum telefone contém '2'.
    expect((await db.patientsDao.watchList(query: '2').first).single.fullName,
        'João Santos');
    expect((await db.patientsDao.watchList(query: 'xyz').first), isEmpty);
  });

  test('apagamento lógico remove da lista mas mantém a linha', () async {
    final p = await db.patientsDao.createPatient(nome('Teste'));
    await db.patientsDao.softDelete(p.id);

    expect(await db.patientsDao.watchList().first, isEmpty);
    final row = await db.patientsDao.getById(p.id);
    expect(row, isNotNull);
    expect(row!.isDeleted, isTrue);
    expect(row.syncState, 'pending');
  });

  test('atualização marca syncState como pendente', () async {
    final p = await db.patientsDao.createPatient(nome('Antes'));
    await db.patientsDao.updatePatient(
      p.id,
      const PatientsCompanion(fullName: Value('Depois')),
    );
    final row = await db.patientsDao.getById(p.id);
    expect(row!.fullName, 'Depois');
    expect(row.syncState, 'pending');
  });
}
