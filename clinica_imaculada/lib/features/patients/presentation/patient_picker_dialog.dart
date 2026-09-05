import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import 'patient_providers.dart';

/// Diálogo de pesquisa e seleção de paciente, reutilizado pelos módulos de
/// Consultas e Anamnese.
Future<Patient?> showPatientPickerDialog(BuildContext context) {
  return showDialog<Patient>(
    context: context,
    builder: (_) => const _PatientPickerDialog(),
  );
}

class _PatientPickerDialog extends ConsumerStatefulWidget {
  const _PatientPickerDialog();

  @override
  ConsumerState<_PatientPickerDialog> createState() =>
      _PatientPickerDialogState();
}

class _PatientPickerDialogState extends ConsumerState<_PatientPickerDialog> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final patientsAsync = ref.watch(patientsDaoProvider);

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 560),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Selecionar paciente',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Pesquisar por nome, telefone ou nº de processo',
                  prefixIcon: Icon(Icons.search),
                  isDense: true,
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: StreamBuilder<List<Patient>>(
                  stream: patientsAsync.watchList(query: _query),
                  builder: (context, snapshot) {
                    final patients = snapshot.data ?? const [];
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (patients.isEmpty) {
                      return const Center(child: Text('Nenhum paciente encontrado.'));
                    }
                    return ListView.builder(
                      itemCount: patients.length,
                      itemBuilder: (context, i) {
                        final p = patients[i];
                        return ListTile(
                          title: Text(p.fullName),
                          subtitle: Text(p.phone ?? ''),
                          onTap: () => Navigator.pop(context, p),
                        );
                      },
                    );
                  },
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
