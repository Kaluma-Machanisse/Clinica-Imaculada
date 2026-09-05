import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import '../data/appointment_list_item.dart';
import '../data/appointments_table.dart';
import '../domain/appointment_formatting.dart';
import 'appointment_providers.dart';

class AppointmentsListPage extends ConsumerWidget {
  const AppointmentsListPage({super.key});

  Future<void> _pickDay(BuildContext context, WidgetRef ref) async {
    final current = ref.read(selectedDayProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: const Locale('pt', 'PT'),
    );
    if (picked != null) {
      ref.read(selectedDayProvider.notifier).state =
          DateTime(picked.year, picked.month, picked.day);
    }
  }

  Future<void> _quickAction(
    BuildContext context,
    WidgetRef ref,
    Appointment appt,
    AppointmentStatus status,
  ) async {
    try {
      await ref.read(appointmentRepositoryProvider).setStatus(appt.id, status);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final day = ref.watch(selectedDayProvider);
    final apptsAsync = ref.watch(appointmentsByDayProvider);
    final isToday = formatDate(day) == formatDate(DateTime.now());

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => ref.read(selectedDayProvider.notifier).state =
                    day.subtract(const Duration(days: 1)),
              ),
              InkWell(
                onTap: () => _pickDay(context, ref),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        isToday ? 'Hoje · ${formatDate(day)}' : formatDate(day),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () => ref.read(selectedDayProvider.notifier).state =
                    day.add(const Duration(days: 1)),
              ),
              if (!isToday)
                TextButton(
                  onPressed: () {
                    final now = DateTime.now();
                    ref.read(selectedDayProvider.notifier).state =
                        DateTime(now.year, now.month, now.day);
                  },
                  child: const Text('Hoje'),
                ),
              const Spacer(),
              FilledButton.icon(
                onPressed: () => context.go('/consultas/novo'),
                icon: const Icon(Icons.add),
                label: const Text('Nova consulta'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: apptsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Erro: $e')),
              data: (items) {
                if (items.isEmpty) {
                  return const Center(child: Text('Sem consultas para este dia.'));
                }
                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, i) => _AppointmentTile(
                      item: items[i],
                      onQuickAction: (status) =>
                          _quickAction(context, ref, items[i].appointment, status),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AppointmentTile extends StatelessWidget {
  const _AppointmentTile({required this.item, required this.onQuickAction});

  final AppointmentListItem item;
  final void Function(AppointmentStatus) onQuickAction;

  @override
  Widget build(BuildContext context) {
    final a = item.appointment;
    final scheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: SizedBox(
        width: 56,
        child: Text(
          formatTime(a.scheduledAt),
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      title: Text(item.patientName),
      subtitle: Text(
        [
          'Dr(a). ${item.doctorName}',
          if (a.reason != null && a.reason!.isNotEmpty) a.reason!,
        ].join('  ·  '),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor(a.status, scheme).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              statusLabel(a.status),
              style: TextStyle(
                color: statusColor(a.status, scheme),
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
          PopupMenuButton<Object>(
            onSelected: (value) {
              if (value is AppointmentStatus) {
                onQuickAction(value);
              } else if (value == 'editar') {
                context.go('/consultas/${a.id}/editar');
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: AppointmentStatus.confirmada,
                child: Text('Confirmar'),
              ),
              PopupMenuItem(
                value: AppointmentStatus.emAtendimento,
                child: Text('Iniciar atendimento'),
              ),
              PopupMenuItem(
                value: AppointmentStatus.concluida,
                child: Text('Concluir'),
              ),
              PopupMenuItem(
                value: AppointmentStatus.faltou,
                child: Text('Marcar falta'),
              ),
              PopupMenuItem(
                value: AppointmentStatus.cancelada,
                child: Text('Cancelar'),
              ),
              PopupMenuDivider(),
              PopupMenuItem(value: 'editar', child: Text('Editar')),
            ],
          ),
        ],
      ),
    );
  }
}
