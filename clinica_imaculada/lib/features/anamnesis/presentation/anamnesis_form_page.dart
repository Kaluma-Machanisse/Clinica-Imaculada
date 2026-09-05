import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/database/app_database.dart';
import '../../appointments/presentation/appointment_providers.dart';
import '../../patients/presentation/patient_providers.dart';
import 'anamnesis_providers.dart';

class AnamnesisFormPage extends ConsumerStatefulWidget {
  const AnamnesisFormPage({super.key, this.entryId});

  /// `null` → criar novo registo para o paciente selecionado; caso
  /// contrário, editar o registo com este id.
  final String? entryId;

  bool get isEditing => entryId != null;

  @override
  ConsumerState<AnamnesisFormPage> createState() => _AnamnesisFormPageState();
}

class _AnamnesisFormPageState extends ConsumerState<AnamnesisFormPage> {
  final _complaint = TextEditingController();
  final _history = TextEditingController();
  final _physicalExam = TextEditingController();
  final _vitalSigns = TextEditingController();
  final _diagnosis = TextEditingController();
  final _plan = TextEditingController();

  Patient? _patient;
  String? _appointmentId;

  bool _loading = false;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      _load();
    } else {
      _patient = ref.read(selectedAnamnesisPatientProvider);
    }
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final entry = await ref.read(anamnesisRepositoryProvider).getById(widget.entryId!);
    if (entry != null) {
      _complaint.text = entry.complaint ?? '';
      _history.text = entry.history ?? '';
      _physicalExam.text = entry.physicalExam ?? '';
      _vitalSigns.text = entry.vitalSigns ?? '';
      _diagnosis.text = entry.diagnosis ?? '';
      _plan.text = entry.plan ?? '';
      _appointmentId = entry.appointmentId;
      _patient = await ref.read(patientRepositoryProvider).getById(entry.patientId);
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() {
    _complaint.dispose();
    _history.dispose();
    _physicalExam.dispose();
    _vitalSigns.dispose();
    _diagnosis.dispose();
    _plan.dispose();
    super.dispose();
  }

  String? _n(TextEditingController c) {
    final t = c.text.trim();
    return t.isEmpty ? null : t;
  }

  Future<void> _save() async {
    setState(() => _error = null);
    final patient = _patient;
    if (patient == null) {
      setState(() => _error = 'Nenhum paciente selecionado.');
      return;
    }
    final session = ref.read(sessionProvider);
    if (session == null) return;

    setState(() => _saving = true);
    try {
      final repo = ref.read(anamnesisRepositoryProvider);
      if (widget.isEditing) {
        await repo.update(
          widget.entryId!,
          AnamnesisEntriesCompanion(
            appointmentId: Value(_appointmentId),
            complaint: Value(_n(_complaint)),
            history: Value(_n(_history)),
            physicalExam: Value(_n(_physicalExam)),
            vitalSigns: Value(_n(_vitalSigns)),
            diagnosis: Value(_n(_diagnosis)),
            plan: Value(_n(_plan)),
          ),
        );
      } else {
        await repo.create(
          AnamnesisEntriesCompanion.insert(
            patientId: patient.id,
            doctorId: session.userId,
            appointmentId: Value(_appointmentId),
            complaint: Value(_n(_complaint)),
            history: Value(_n(_history)),
            physicalExam: Value(_n(_physicalExam)),
            vitalSigns: Value(_n(_vitalSigns)),
            diagnosis: Value(_n(_diagnosis)),
            plan: Value(_n(_plan)),
          ),
        );
      }
      if (mounted) context.go('/anamnese');
    } catch (e) {
      setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_patient == null) {
      return const Center(
        child: Text('Nenhum paciente selecionado. Volte e escolha um paciente.'),
      );
    }

    return Column(
      children: [
        Material(
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.isEditing ? 'Editar anamnese' : 'Nova anamnese',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        _patient!.fullName,
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => context.go('/anamnese'),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: const Text('Guardar'),
                ),
              ],
            ),
          ),
        ),
        if (_error != null)
          Container(
            width: double.infinity,
            color: Theme.of(context).colorScheme.errorContainer,
            padding: const EdgeInsets.all(12),
            child: Text(_error!),
          ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Consumer(
                builder: (context, ref, _) {
                  final apptsAsync =
                      ref.watch(appointmentsByPatientProvider(_patient!.id));
                  return apptsAsync.when(
                    loading: () => const SizedBox.shrink(),
                    error: (e, _) => const SizedBox.shrink(),
                    data: (appts) {
                      if (appts.isEmpty) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: DropdownButtonFormField<String?>(
                          initialValue: _appointmentId,
                          decoration: const InputDecoration(
                            labelText: 'Consulta associada (opcional)',
                          ),
                          items: [
                            const DropdownMenuItem(value: null, child: Text('—')),
                            for (final a in appts)
                              DropdownMenuItem(
                                value: a.appointment.id,
                                child: Text(
                                  '${a.appointment.scheduledAt.day.toString().padLeft(2, '0')}/'
                                  '${a.appointment.scheduledAt.month.toString().padLeft(2, '0')} · '
                                  'Dr(a). ${a.doctorName}',
                                ),
                              ),
                          ],
                          onChanged: (v) => setState(() => _appointmentId = v),
                        ),
                      );
                    },
                  );
                },
              ),
              _field(_complaint, 'Queixa principal', maxLines: 2),
              _field(_history, 'História da doença atual', maxLines: 3),
              _field(_vitalSigns, 'Sinais vitais (TA, FC, FR, Temp, SpO2, peso...)'),
              _field(_physicalExam, 'Exame físico', maxLines: 3),
              _field(_diagnosis, 'Diagnóstico', maxLines: 2),
              _field(_plan, 'Conduta / plano terapêutico', maxLines: 3),
            ],
          ),
        ),
      ],
    );
  }

  Widget _field(TextEditingController c, String label, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: c,
        decoration: InputDecoration(labelText: label),
        maxLines: maxLines,
      ),
    );
  }
}
