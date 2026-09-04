import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/patient_formatting.dart';
import 'patient_providers.dart';

class PatientsListPage extends ConsumerStatefulWidget {
  const PatientsListPage({super.key});

  @override
  ConsumerState<PatientsListPage> createState() => _PatientsListPageState();
}

class _PatientsListPageState extends ConsumerState<PatientsListPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.text = ref.read(patientSearchQueryProvider);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final patientsAsync = ref.watch(patientsListProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Pesquisar por nome, telefone ou nº de processo',
                    prefixIcon: const Icon(Icons.search),
                    isDense: true,
                    suffixIcon: _searchController.text.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              ref
                                  .read(patientSearchQueryProvider.notifier)
                                  .state = '';
                              setState(() {});
                            },
                          ),
                  ),
                  onChanged: (v) {
                    ref.read(patientSearchQueryProvider.notifier).state = v;
                    setState(() {});
                  },
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: () => context.go('/pacientes/novo'),
                icon: const Icon(Icons.person_add_alt_1),
                label: const Text('Novo paciente'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: patientsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Erro: $e')),
              data: (patients) {
                if (patients.isEmpty) {
                  return const Center(
                    child: Text('Sem pacientes para mostrar.'),
                  );
                }
                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: ListView.separated(
                    itemCount: patients.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final p = patients[i];
                      final age = ageFromDob(p.dateOfBirth);
                      final subtitleParts = <String>[
                        patientSexLabel(p.sex),
                        if (age != null) '$age anos',
                        if (p.phone != null && p.phone!.isNotEmpty) p.phone!,
                      ];
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(
                            p.fullName.isNotEmpty
                                ? p.fullName.characters.first.toUpperCase()
                                : '?',
                          ),
                        ),
                        title: Text(p.fullName),
                        subtitle: Text(subtitleParts.join('  ·  ')),
                        trailing: Text(
                          'Proc. ${formatProcessNumber(p.processNumber)}',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        onTap: () => context.go('/pacientes/${p.id}'),
                      );
                    },
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
