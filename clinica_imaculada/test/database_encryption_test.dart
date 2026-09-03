@TestOn('vm')
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

/// Verifica que a base de dados local fica mesmo cifrada em disco.
///
/// Depende do build hook `sqlite3 -> source: sqlite3mc` definido no pubspec.
void main() {
  test('build com cifra ativa (sqlite3mc)', () {
    final db = sqlite3.openInMemory();
    addTearDown(db.close);
    final isSqlite3mc = db.select('PRAGMA cipher;').isNotEmpty;
    final isSqlcipher = db.select('PRAGMA cipher_version;').isNotEmpty;
    expect(
      isSqlite3mc || isSqlcipher,
      isTrue,
      reason: 'a build de SQLite não suporta cifra',
    );
  });

  test('a base de dados fica cifrada e exige a chave', () {
    final dir = Directory.systemTemp.createTempSync('clinica_db_test');
    addTearDown(() => dir.deleteSync(recursive: true));
    final path = '${dir.path}/enc.db';
    const key =
        "x'000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f'";

    // 1. Cria a base cifrada e escreve dados.
    final db = sqlite3.open(path);
    db.execute('PRAGMA key = "$key";');
    db
      ..execute('CREATE TABLE t (v TEXT);')
      ..execute("INSERT INTO t (v) VALUES ('SEGREDO_CLINICO');");
    db.close();

    // 2. Em disco: sem cabeçalho SQLite e sem o texto em claro.
    final bytes = File(path).readAsBytesSync();
    final head = String.fromCharCodes(bytes.take(16).toList());
    expect(head.startsWith('SQLite format 3'), isFalse,
        reason: 'o ficheiro não está cifrado (cabeçalho SQLite visível)');
    expect(String.fromCharCodes(bytes).contains('SEGREDO_CLINICO'), isFalse,
        reason: 'os dados apareceram em claro no ficheiro');

    // 3. Abrir sem a chave falha ao ler.
    final noKey = sqlite3.open(path);
    expect(
      () => noKey.select('SELECT * FROM sqlite_master;'),
      throwsA(isA<SqliteException>()),
    );
    noKey.close();

    // 4. Com a chave certa, os dados estão lá.
    final ok = sqlite3.open(path);
    ok.execute('PRAGMA key = "$key";');
    expect(ok.select('SELECT v FROM t;').single['v'], 'SEGREDO_CLINICO');
    ok.close();
  });
}
