import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

/// Observa o estado da ligação de rede.
///
/// Nota: `connectivity_plus` indica se existe uma interface de rede ativa, não
/// se a internet está mesmo acessível. O serviço de sincronização deve, ainda
/// assim, tratar falhas de pedido como "offline" e voltar a tentar.
class ConnectivityMonitor {
  ConnectivityMonitor({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  Future<bool> isOnline() async {
    final results = await _connectivity.checkConnectivity();
    return _hasConnection(results);
  }

  /// Emite `true`/`false` sempre que o estado da ligação muda.
  Stream<bool> onlineChanges() {
    return _connectivity.onConnectivityChanged.map(_hasConnection).distinct();
  }

  static bool _hasConnection(List<ConnectivityResult> results) {
    return results.isNotEmpty &&
        results.any((r) => r != ConnectivityResult.none);
  }
}
