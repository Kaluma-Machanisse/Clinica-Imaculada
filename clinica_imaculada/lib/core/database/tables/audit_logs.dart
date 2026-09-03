import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

/// Registo de auditoria: quem fez o quê, quando e sobre que dados.
///
/// Tabela apenas de escrita e leitura (nunca editada nem apagada pela
/// aplicação). Essencial para dados clínicos: permite saber quem consultou ou
/// alterou o processo de um paciente.
///
/// Não usa [SyncColumns] porque as linhas são imutáveis; tem apenas os campos
/// mínimos para poder ser copiada para a nuvem.
class AuditLogs extends Table {
  TextColumn get id => text().clientDefault(() => const Uuid().v4())();

  /// Momento do evento.
  DateTimeColumn get timestamp =>
      dateTime().withDefault(currentDateAndTime)();

  /// `id` do utilizador que executou a ação (pode ser nulo em eventos de
  /// sistema, como o arranque).
  TextColumn get userId => text().nullable()();

  /// `username` no momento do evento (guardado à parte para o registo
  /// permanecer legível mesmo que o utilizador seja alterado).
  TextColumn get username => text().nullable()();

  /// Ação: login, logout, login_failed, create, update, delete, view, print,
  /// export, ...
  TextColumn get action => text().withLength(min: 1, max: 40)();

  /// Entidade afetada (ex.: patient, appointment, payment, user).
  TextColumn get entity => text().nullable()();

  /// `id` do registo afetado.
  TextColumn get entityId => text().nullable()();

  /// Detalhe livre (ex.: campos alterados, motivo, resumo).
  TextColumn get details => text().nullable()();

  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
