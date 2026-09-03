import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

/// Estados possíveis de sincronização de uma linha com a nuvem.
class SyncStates {
  const SyncStates._();

  /// Alterada localmente, ainda não enviada para a nuvem.
  static const String pending = 'pending';

  /// Igual à cópia da nuvem.
  static const String synced = 'synced';

  /// Falha ao sincronizar; será tentada novamente.
  static const String error = 'error';
}

/// Colunas comuns a todas as tabelas, necessárias para a sincronização
/// offline-first e para o apagamento lógico (soft delete).
///
/// - [id]           identificador global (UUID v4), gerado no cliente.
/// - [createdAt]     momento de criação.
/// - [updatedAt]     momento da última alteração (base da resolução de conflitos
///                   "last-write-wins").
/// - [isDeleted]     apagamento lógico; a linha nunca é removida fisicamente
///                   enquanto não estiver sincronizada.
/// - [syncState]     ver [SyncStates].
mixin SyncColumns on Table {
  TextColumn get id => text().clientDefault(() => const Uuid().v4())();

  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();

  BoolColumn get isDeleted =>
      boolean().withDefault(const Constant(false))();

  TextColumn get syncState =>
      text().withLength(min: 1, max: 16).withDefault(const Constant('pending'))();

  @override
  Set<Column> get primaryKey => {id};
}
