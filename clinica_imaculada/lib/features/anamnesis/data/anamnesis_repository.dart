import '../../../core/auth/permissions.dart';
import '../../../core/auth/session.dart';
import '../../../core/common/errors.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/daos/audit_dao.dart';
import 'anamnesis_dao.dart';

class AnamnesisRepository {
  AnamnesisRepository({
    required this.dao,
    required this.audit,
    required this.session,
  });

  final AnamnesisDao dao;
  final AuditDao audit;
  final AppSession session;

  void _guard() {
    if (!session.can(AppSection.anamnese)) {
      throw const AccessDeniedException(
        'O seu perfil não tem acesso ao módulo de Anamnese.',
      );
    }
  }

  Stream<List<AnamnesisEntry>> watchByPatient(String patientId) {
    _guard();
    return dao.watchByPatient(patientId);
  }

  Future<AnamnesisEntry?> getById(String id) {
    _guard();
    return dao.getById(id);
  }

  Future<AnamnesisEntry> create(AnamnesisEntriesCompanion entry) async {
    _guard();
    final created = await dao.create(entry);
    await audit.record(
      userId: session.userId,
      username: session.username,
      action: 'create',
      entity: 'anamnesis',
      entityId: created.id,
      details: 'paciente ${created.patientId}',
    );
    return created;
  }

  Future<void> update(String id, AnamnesisEntriesCompanion changes) async {
    _guard();
    await dao.updateAnamnesis(id, changes);
    await audit.record(
      userId: session.userId,
      username: session.username,
      action: 'update',
      entity: 'anamnesis',
      entityId: id,
    );
  }
}
