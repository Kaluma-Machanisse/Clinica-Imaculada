import '../../../core/auth/permissions.dart';
import '../../../core/auth/session.dart';
import '../../../core/common/errors.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/daos/audit_dao.dart';
import 'patients_dao.dart';

/// Ponto único de acesso aos pacientes.
///
/// Aplica o controlo de permissões na camada de dados (além da navegação) e
/// regista as operações na auditoria.
class PatientRepository {
  PatientRepository({
    required this.dao,
    required this.audit,
    required this.session,
  });

  final PatientsDao dao;
  final AuditDao audit;
  final AppSession session;

  void _guard() {
    if (!session.can(AppSection.pacientes)) {
      throw const AccessDeniedException(
        'O seu perfil não tem acesso ao módulo de Pacientes.',
      );
    }
  }

  Stream<List<Patient>> watchList({String query = ''}) {
    _guard();
    return dao.watchList(query: query);
  }

  Future<Patient?> getById(String id) {
    _guard();
    return dao.getById(id);
  }

  Future<Patient> create(PatientsCompanion entry) async {
    _guard();
    final patient = await dao.createPatient(entry);
    await audit.record(
      userId: session.userId,
      username: session.username,
      action: 'create',
      entity: 'patient',
      entityId: patient.id,
      details: 'processo ${patient.processNumber} · ${patient.fullName}',
    );
    return patient;
  }

  Future<void> update(String id, PatientsCompanion changes) async {
    _guard();
    await dao.updatePatient(id, changes);
    await audit.record(
      userId: session.userId,
      username: session.username,
      action: 'update',
      entity: 'patient',
      entityId: id,
    );
  }

  Future<void> delete(String id) async {
    _guard();
    final patient = await dao.getById(id);
    await dao.softDelete(id);
    await audit.record(
      userId: session.userId,
      username: session.username,
      action: 'delete',
      entity: 'patient',
      entityId: id,
      details: patient == null
          ? null
          : 'processo ${patient.processNumber} · ${patient.fullName}',
    );
  }

  Future<void> logView(String id) async {
    _guard();
    await audit.record(
      userId: session.userId,
      username: session.username,
      action: 'view',
      entity: 'patient',
      entityId: id,
    );
  }
}
