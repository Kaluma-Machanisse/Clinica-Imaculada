import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../patients/presentation/patient_picker_dialog.dart';
import 'anamnesis_providers.dart';

final _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');

class AnamnesisHomePage extends ConsumerWidget {
  const AnamnesisHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patient = ref.watch(selectedAnamnesisPatientProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.person_search),
                  label: Text(
                    patient == null
                        ? 'Selecionar paciente'
                        : patient.fullName,
                  ),
                  onPressed: () async {
                    final p = await showPatientPickerDialog(context);
                    if (p != null) {
                      ref.read(selectedAnamnesisPatientProvider.notifier).state = p;
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: patient == null
                    ? null
                    : () => context.go('/anamnese/novo'),
                icon: const Icon(Icons.add),
                label: const Text('Nova anamnese'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: patient == null
                ? const Center(
                    child: Text('Selecione um paciente para ver o histórico.'),
                  )
                : Consumer(
                    builder: (context, ref, _) {
                      final entriesAsync =
                          ref.watch(anamnesisByPatientProvider(patient.id));
                      return entriesAsync.when(
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (e, _) => Center(child: Text('Erro: $e')),
                        data: (entries) {
                          if (entries.isEmpty) {
                            return const Center(
                              child: Text('Sem registos de anamnese.'),
                            );
                          }
                          return ListView.builder(
                            itemCount: entries.length,
                            itemBuilder: (context, i) {
                              final e = entries[i];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: ListTile(
                                  title: Text(
                                    e.complaint?.isNotEmpty == true
                                        ? e.complaint!
                                        : '(sem queixa registada)',
                                  ),
                                  subtitle: Text(
                                    [
                                      _dateTimeFormat.format(e.createdAt),
                                      if (e.diagnosis != null &&
                                          e.diagnosis!.isNotEmpty)
                                        'Diagnóstico: ${e.diagnosis}',
                                    ].join('  ·  '),
                                  ),
                                  trailing: const Icon(Icons.chevron_right),
                                  onTap: () =>
                                      context.go('/anamnese/${e.id}/editar'),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
