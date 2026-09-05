import '../../../core/database/app_database.dart';

/// Uma consulta já com o nome do paciente e do médico resolvidos (evita
/// consultas extra na interface).
class AppointmentListItem {
  const AppointmentListItem({
    required this.appointment,
    required this.patientName,
    required this.doctorName,
  });

  final Appointment appointment;
  final String patientName;
  final String doctorName;
}
