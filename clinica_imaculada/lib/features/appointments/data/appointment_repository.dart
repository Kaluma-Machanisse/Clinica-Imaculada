import '../../../core/auth/permissions.dart';
import '../../../core/auth/session.dart';
import '../../../core/common/errors.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/daos/audit_dao.dart';
import 'appointment_list_item.dart';
import 'appointments_dao.dart';
import 'appointments_table.dart';

class AppointmentRepository {
  AppointmentRepository({
    required this.dao,
    required this.audit,
    required this.session,
  });

  final AppointmentsDao dao;
  final AuditDao audit;
  final AppSession session;

  void _guard() {
    if (!session.can(AppSection.consultas)) {
      throw const AccessDeniedException(
        'O seu perfil não tem acesso ao módulo de Consultas.',
      );
    }
  }

  Stream<List<AppointmentListItem>> watchByDay(DateTime day) {
    _guard();
    return dao.watchByDay(day);
  }

  Stream<List<AppointmentListItem>> watchByPatient(String patientId) {
    _guard();
    return dao.watchByPatient(patientId);
  }

  Future<Appointment?> getById(String id) {
    _guard();
    return dao.getById(id);
  }

  Future<Appointment> create(AppointmentsCompanion entry) async {
    _guard();
    final appt = await dao.create(entry);
    await audit.record(
      userId: session.userId,
      username: session.username,
      action: 'create',
      entity: 'appointment',
      entityId: appt.id,
      details: 'consulta em ${appt.scheduledAt}',
    );
    return appt;
  }

  Future<void> update(String id, AppointmentsCompanion changes) async {
    _guard();
    await dao.updateAppointment(id, changes);
    await audit.record(
      userId: session.userId,
      username: session.username,
      action: 'update',
      entity: 'appointment',
      entityId: id,
    );
  }

  Future<void> setStatus(String id, AppointmentStatus status) async {
    _guard();
    await dao.setStatus(id, status);
    await audit.record(
      userId: session.userId,
      username: session.username,
      action: 'update',
      entity: 'appointment',
      entityId: id,
      details: 'estado -> ${status.name}',
    );
  }

  Future<void> cancel(String id) async {
    _guard();
    await dao.setStatus(id, AppointmentStatus.cancelada);
    await audit.record(
      userId: session.userId,
      username: session.username,
      action: 'update',
      entity: 'appointment',
      entityId: id,
      details: 'estado -> cancelada',
    );
  }

  Future<void> delete(String id) async {
    _guard();
    await dao.softDelete(id);
    await audit.record(
      userId: session.userId,
      username: session.username,
      action: 'delete',
      entity: 'appointment',
      entityId: id,
    );
  }
}
