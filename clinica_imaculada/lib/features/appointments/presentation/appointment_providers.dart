import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/auth/user_role.dart';
import '../../../core/database/app_database.dart';
import '../data/appointment_list_item.dart';
import '../data/appointment_repository.dart';
import '../data/appointments_dao.dart';

final appointmentsDaoProvider = Provider<AppointmentsDao>(
  (ref) => ref.watch(appDatabaseProvider).appointmentsDao,
);

final appointmentRepositoryProvider = Provider<AppointmentRepository>((ref) {
  final session = ref.watch(sessionProvider);
  if (session == null) throw StateError('Sem sessão iniciada.');
  return AppointmentRepository(
    dao: ref.watch(appointmentsDaoProvider),
    audit: ref.watch(auditDaoProvider),
    session: session,
  );
});

/// Dia selecionado na agenda (só data, sem hora).
final selectedDayProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

final appointmentsByDayProvider =
    StreamProvider.autoDispose<List<AppointmentListItem>>((ref) {
  final day = ref.watch(selectedDayProvider);
  return ref.watch(appointmentRepositoryProvider).watchByDay(day);
});

final appointmentsByPatientProvider = StreamProvider.autoDispose
    .family<List<AppointmentListItem>, String>((ref, patientId) {
  return ref.watch(appointmentRepositoryProvider).watchByPatient(patientId);
});

/// Médicos ativos, para o seletor de consultas/anamnese.
final doctorsProvider = FutureProvider.autoDispose<List<User>>((ref) {
  return ref.watch(usersDaoProvider).listActiveByRole(UserRole.medico.name);
});
