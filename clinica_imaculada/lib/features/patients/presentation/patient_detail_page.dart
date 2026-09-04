import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import '../domain/patient_formatting.dart';
import 'patient_providers.dart';

class PatientDetailPage extends ConsumerStatefulWidget {
  const PatientDetailPage({super.key, required this.id});

  final String id;

  @override
  ConsumerState<PatientDetailPage> createState() => _PatientDetailPageState();
}

class _PatientDetailPageState extends ConsumerState<PatientDetailPage> {
  @override
  void initState() {
    super.initState();
    // Regista a consulta da ficha na auditoria (uma vez).
    Future.microtask(
      () => ref.read(patientRepositoryProvider).logView(widget.id),
    );
  }

  Future<void> _confirmDelete(Patient p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remover paciente'),
        content: Text(
          'Remover "${p.fullName}" (processo '
          '${formatProcessNumber(p.processNumber)})?\n\n'
          'O registo deixa de aparecer nas listas. O histórico em auditoria '
          'é mantido.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(patientRepositoryProvider).delete(widget.id);
      if (mounted) context.go('/pacientes');
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(patientByIdProvider(widget.id));

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Erro: $e')),
      data: (p) {
        if (p == null) {
          return const Center(child: Text('Paciente não encontrado.'));
        }
        return Column(
          children: [
            Material(
              elevation: 1,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.go('/pacientes'),
                      icon: const Icon(Icons.arrow_back),
                      tooltip: 'Voltar à lista',
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.fullName,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(
                            'Processo ${formatProcessNumber(p.processNumber)}',
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () =>
                          context.go('/pacientes/${p.id}/editar'),
                      icon: const Icon(Icons.edit),
                      label: const Text('Editar'),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => _confirmDelete(p),
                      icon: const Icon(Icons.delete_outline),
                      tooltip: 'Remover',
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _Group('Identificação', {
                    'Nome completo': p.fullName,
                    'Data de nascimento': formatDobWithAge(p.dateOfBirth),
                    'Sexo': patientSexLabel(p.sex),
                    'Documento de identificação': p.idDocument,
                    'NIF': p.taxId,
                  }),
                  _Group('Contactos', {
                    'Telefone': p.phone,
                    'Telefone alternativo': p.phoneAlt,
                    'Email': p.email,
                    'Morada': p.address,
                    'Cidade': p.city,
                    'Província': p.province,
                    'Emergência (nome)': p.nextOfKinName,
                    'Emergência (telefone)': p.nextOfKinPhone,
                  }),
                  _Group('Clínico', {
                    'Grupo sanguíneo': p.bloodType,
                    'Alergias': p.allergies,
                    'Doenças crónicas': p.chronicConditions,
                  }),
                  _Group('Notas', {
                    'Observações': p.notes,
                  }),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Group extends StatelessWidget {
  const _Group(this.title, this.fields);

  final String title;
  final Map<String, String?> fields;

  @override
  Widget build(BuildContext context) {
    final entries = fields.entries
        .map((e) => (e.key, (e.value == null || e.value!.trim().isEmpty)
            ? '—'
            : e.value!.trim()))
        .toList();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 8),
            for (final (label, value) in entries)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 200,
                      child: Text(
                        label,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Expanded(child: Text(value)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
