import 'dart:async';

import 'package:logging/logging.dart';

import 'connectivity_monitor.dart';
import 'sync_status.dart';

/// Contrato do serviço de sincronização com a nuvem.
///
/// A aplicação nunca depende deste serviço para funcionar: ele apenas copia,
/// em segundo plano, os dados locais para a nuvem e traz alterações remotas
/// quando há ligação. Toda a implementação concreta (ex.: Supabase) fica atrás
/// desta interface.
abstract class SyncService {
  /// Estado atual, para a interface mostrar (ícone, "última sincronização", …).
  Stream<SyncStatus> get statusStream;

  SyncStatus get currentStatus;

  /// Começa a observar a rede e a sincronizar automaticamente.
  Future<void> start();

  /// Pára a sincronização automática.
  Future<void> stop();

  /// Força uma sincronização imediata (ação manual do utilizador).
  /// Não lança exceção: erros ficam refletidos em [currentStatus].
  Future<void> syncNow();

  Future<void> dispose();
}

/// Implementação "vazia": não fala com nenhuma nuvem.
///
/// É a usada até o módulo de sincronização ser implementado (passo 8 do
/// roteiro). Mantém o estado como [SyncPhase.offline]/[SyncPhase.idle]
/// consoante a ligação, para a interface já poder mostrar o indicador.
class NoOpSyncService implements SyncService {
  NoOpSyncService({ConnectivityMonitor? connectivity})
      : _connectivity = connectivity ?? ConnectivityMonitor();

  final ConnectivityMonitor _connectivity;
  final _log = Logger('NoOpSyncService');
  final _controller = StreamController<SyncStatus>.broadcast();
  StreamSubscription<bool>? _connSub;

  SyncStatus _status = SyncStatus.initial;

  @override
  SyncStatus get currentStatus => _status;

  @override
  Stream<SyncStatus> get statusStream => _controller.stream;

  void _emit(SyncStatus status) {
    _status = status;
    if (!_controller.isClosed) _controller.add(status);
  }

  @override
  Future<void> start() async {
    final online = await _connectivity.isOnline();
    _emit(_status.copyWith(
      phase: online ? SyncPhase.idle : SyncPhase.offline,
    ));
    _connSub = _connectivity.onlineChanges().listen((online) {
      _emit(_status.copyWith(
        phase: online ? SyncPhase.idle : SyncPhase.offline,
      ));
    });
    _log.info('Sincronização com a nuvem ainda não implementada '
        '(a funcionar apenas localmente).');
  }

  @override
  Future<void> stop() async {
    await _connSub?.cancel();
    _connSub = null;
  }

  @override
  Future<void> syncNow() async {
    _log.fine('syncNow() ignorado: nenhuma nuvem configurada.');
  }

  @override
  Future<void> dispose() async {
    await stop();
    await _controller.close();
  }
}
