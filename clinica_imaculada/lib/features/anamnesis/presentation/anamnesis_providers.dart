import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/database/app_database.dart';
import '../data/anamnesis_dao.dart';
import '../data/anamnesis_repository.dart';

final anamnesisDaoProvider = Provider<AnamnesisDao>(
  (ref) => ref.watch(appDatabaseProvider).anamnesisDao,
);

final anamnesisRepositoryProvider = Provider<AnamnesisRepository>((ref) {
  final session = ref.watch(sessionProvider);
  if (session == null) throw StateError('Sem sessão iniciada.');
  return AnamnesisRepository(
    dao: ref.watch(anamnesisDaoProvider),
    audit: ref.watch(auditDaoProvider),
    session: session,
  );
});

/// Paciente selecionado no ecrã de Anamnese (partilhado entre lista e form).
final selectedAnamnesisPatientProvider = StateProvider<Patient?>((ref) => null);

final anamnesisByPatientProvider =
    StreamProvider.autoDispose.family<List<AnamnesisEntry>, String>(
  (ref, patientId) =>
      ref.watch(anamnesisRepositoryProvider).watchByPatient(patientId),
);
