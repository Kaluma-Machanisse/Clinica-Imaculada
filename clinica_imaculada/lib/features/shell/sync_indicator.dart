import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/providers.dart';
import '../../core/sync/sync_status.dart';

/// Pequeno indicador na barra superior: mostra o estado da sincronização.
class SyncIndicator extends ConsumerWidget {
  const SyncIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(syncStatusProvider).valueOrNull ??
        SyncStatus.initial;

    final (IconData icon, String label, Color? color) = switch (status.phase) {
      SyncPhase.offline => (
          Icons.cloud_off_outlined,
          'Offline',
          Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      SyncPhase.idle => (Icons.cloud_done_outlined, 'Sincronizado', null),
      SyncPhase.pushing => (Icons.cloud_upload_outlined, 'A enviar…', null),
      SyncPhase.pulling => (Icons.cloud_download_outlined, 'A receber…', null),
      SyncPhase.error => (
          Icons.cloud_off_outlined,
          'Erro de sincronização',
          Theme.of(context).colorScheme.error,
        ),
    };

    final last = status.lastSyncAt;
    final tooltip = StringBuffer(label);
    if (last != null) {
      tooltip.write('\nÚltima: ${DateFormat('dd/MM HH:mm').format(last)}');
    }
    if (status.pendingChanges > 0) {
      tooltip.write('\nPendentes: ${status.pendingChanges}');
    }

    return Tooltip(
      message: tooltip.toString(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: color, fontSize: 12)),
        ],
      ),
    );
  }
}
