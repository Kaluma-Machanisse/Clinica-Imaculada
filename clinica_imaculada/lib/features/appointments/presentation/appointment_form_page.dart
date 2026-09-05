import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/database/app_database.dart';
import '../../patients/presentation/patient_picker_dialog.dart';
import '../../patients/presentation/patient_providers.dart';
import '../data/appointments_table.dart';
import '../domain/appointment_formatting.dart';
import 'appointment_providers.dart';

class AppointmentFormPage extends ConsumerStatefulWidget {
  const AppointmentFormPage({super.key, this.appointmentId});

  final String? appointmentId;

  bool get isEditing => appointmentId != null;

  @override
  ConsumerState<AppointmentFormPage> createState() =>
      _AppointmentFormPageState();
}

class _AppointmentFormPageState extends ConsumerState<AppointmentFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _reason = TextEditingController();
  final _notes = TextEditingController();
  final _duration = TextEditingController(text: '30');

  Patient? _patient;
  User? _doctor;
  DateTime _date = DateTime.now();
  TimeOfDay _time = TimeOfDay.now();
  AppointmentStatus _status = AppointmentStatus.agendada;

  bool _loading = false;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final repo = ref.read(appointmentRepositoryProvider);
    final appt = await repo.getById(widget.appointmentId!);
    if (appt != null) {
      final p = await ref.read(patientRepositoryProvider).getById(appt.patientId);
      final doctors = await ref.read(doctorsProvider.future);
      _patient = p;
      final matches = doctors.where((d) => d.id == appt.doctorId);
      _doctor = matches.isEmpty ? null : matches.first;
      _date = DateTime(
          appt.scheduledAt.year, appt.scheduledAt.month, appt.scheduledAt.day);
      _time = TimeOfDay.fromDateTime(appt.scheduledAt);
      _duration.text = appt.durationMinutes.toString();
      _reason.text = appt.reason ?? '';
      _notes.text = appt.notes ?? '';
      _status = statusFromName(appt.status);
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() {
    _reason.dispose();
    _notes.dispose();
    _duration.dispose();
    super.dispose();
  }

  Future<void> _pickPatient() async {
    final p = await showPatientPickerDialog(context);
    if (p != null) setState(() => _patient = p);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: const Locale('pt', 'PT'),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _save() async {
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) return;
    if (_patient == null) {
      setState(() => _error = 'Selecione o paciente.');
      return;
    }
    if (_doctor == null) {
      setState(() => _error = 'Selecione o médico.');
      return;
    }

    final scheduledAt = DateTime(
      _date.year,
      _date.month,
      _date.day,
      _time.hour,
      _time.minute,
    );
    final duration = int.tryParse(_duration.text.trim()) ?? 30;
    final reason = _reason.text.trim();
    final notes = _notes.text.trim();

    setState(() => _saving = true);
    try {
      final repo = ref.read(appointmentRepositoryProvider);
      if (widget.isEditing) {
        await repo.update(
          widget.appointmentId!,
          AppointmentsCompanion(
            patientId: Value(_patient!.id),
            doctorId: Value(_doctor!.id),
            scheduledAt: Value(scheduledAt),
            durationMinutes: Value(duration),
            status: Value(_status.name),
            reason: Value(reason.isEmpty ? null : reason),
            notes: Value(notes.isEmpty ? null : notes),
          ),
        );
      } else {
        await repo.create(
          AppointmentsCompanion.insert(
            patientId: _patient!.id,
            doctorId: _doctor!.id,
            scheduledAt: scheduledAt,
            durationMinutes: Value(duration),
            reason: Value(reason.isEmpty ? null : reason),
            notes: Value(notes.isEmpty ? null : notes),
          ),
        );
      }
      if (mounted) context.go('/consultas');
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
    final doctorsAsync = ref.watch(doctorsProvider);

    return Column(
      children: [
        Material(
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Text(
                  widget.isEditing ? 'Editar consulta' : 'Nova consulta',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => context.go('/consultas'),
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
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(_patient?.fullName ?? 'Selecionar paciente *'),
                  leading: const Icon(Icons.person_outline),
                  trailing: OutlinedButton(
                    onPressed: _pickPatient,
                    child: Text(_patient == null ? 'Escolher' : 'Alterar'),
                  ),
                ),
                const SizedBox(height: 8),
                doctorsAsync.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (e, _) => Text('Erro ao carregar médicos: $e'),
                  data: (doctors) => DropdownButtonFormField<User>(
                    initialValue: _doctor != null &&
                            doctors.any((d) => d.id == _doctor!.id)
                        ? _doctor
                        : null,
                    decoration: const InputDecoration(labelText: 'Médico *'),
                    items: [
                      for (final d in doctors)
                        DropdownMenuItem(value: d, child: Text(d.fullName)),
                    ],
                    onChanged: (v) => setState(() => _doctor = v),
                    validator: (v) => v == null ? 'Selecione o médico.' : null,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: _pickDate,
                        child: InputDecorator(
                          decoration: const InputDecoration(labelText: 'Data'),
                          child: Text(DateFormat('dd/MM/yyyy').format(_date)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: _pickTime,
                        child: InputDecorator(
                          decoration: const InputDecoration(labelText: 'Hora'),
                          child: Text(_time.format(context)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 120,
                      child: TextFormField(
                        controller: _duration,
                        decoration:
                            const InputDecoration(labelText: 'Duração (min)'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _reason,
                  decoration: const InputDecoration(labelText: 'Motivo da consulta'),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _notes,
                  decoration: const InputDecoration(labelText: 'Notas'),
                  maxLines: 3,
                ),
                if (widget.isEditing) ...[
                  const SizedBox(height: 8),
                  DropdownButtonFormField<AppointmentStatus>(
                    initialValue: _status,
                    decoration: const InputDecoration(labelText: 'Estado'),
                    items: [
                      for (final s in AppointmentStatus.values)
                        DropdownMenuItem(value: s, child: Text(statusLabel(s.name))),
                    ],
                    onChanged: (v) =>
                        setState(() => _status = v ?? AppointmentStatus.agendada),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
