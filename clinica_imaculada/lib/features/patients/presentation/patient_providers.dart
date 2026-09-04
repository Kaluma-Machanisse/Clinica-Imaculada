import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/database/app_database.dart';
import '../data/patient_repository.dart';
import '../data/patients_dao.dart';

final patientsDaoProvider = Provider<PatientsDao>(
  (ref) => ref.watch(appDatabaseProvider).patientsDao,
);

/// Repositório de pacientes ligado à sessão atual (para o controlo de acesso).
final patientRepositoryProvider = Provider<PatientRepository>((ref) {
  final session = ref.watch(sessionProvider);
  if (session == null) {
    throw StateError('Sem sessão iniciada.');
  }
  return PatientRepository(
    dao: ref.watch(patientsDaoProvider),
    audit: ref.watch(auditDaoProvider),
    session: session,
  );
});

/// Texto de pesquisa da lista de pacientes.
final patientSearchQueryProvider = StateProvider<String>((ref) => '');

/// Lista reativa de pacientes, já filtrada pela pesquisa.
final patientsListProvider = StreamProvider.autoDispose<List<Patient>>((ref) {
  final query = ref.watch(patientSearchQueryProvider);
  return ref.watch(patientRepositoryProvider).watchList(query: query);
});

/// Um paciente pelo id (para os ecrãs de detalhe/edição).
final patientByIdProvider =
    FutureProvider.autoDispose.family<Patient?, String>((ref, id) {
  return ref.watch(patientRepositoryProvider).getById(id);
});
