/// Fase atual do serviço de sincronização, para mostrar na interface.
enum SyncPhase {
  /// Sem ligação à internet — a trabalhar só localmente.
  offline,

  /// Com ligação, sem nada pendente.
  idle,

  /// A enviar alterações locais para a nuvem.
  pushing,

  /// A trazer alterações da nuvem.
  pulling,

  /// A última tentativa falhou; será repetida.
  error,
}

/// Estado imutável do serviço de sincronização.
class SyncStatus {
  const SyncStatus({
    required this.phase,
    this.pendingChanges = 0,
    this.lastSyncAt,
    this.lastError,
  });

  final SyncPhase phase;

  /// Nº de registos locais ainda por enviar.
  final int pendingChanges;

  /// Momento da última sincronização completa com sucesso.
  final DateTime? lastSyncAt;

  /// Mensagem do último erro, se [phase] for [SyncPhase.error].
  final String? lastError;

  static const initial = SyncStatus(phase: SyncPhase.offline);

  SyncStatus copyWith({
    SyncPhase? phase,
    int? pendingChanges,
    DateTime? lastSyncAt,
    String? lastError,
  }) {
    return SyncStatus(
      phase: phase ?? this.phase,
      pendingChanges: pendingChanges ?? this.pendingChanges,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      lastError: lastError,
    );
  }
}
