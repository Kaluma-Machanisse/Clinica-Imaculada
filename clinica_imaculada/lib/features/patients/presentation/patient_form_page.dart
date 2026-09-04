import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/database/app_database.dart';
import '../data/patients_table.dart';
import '../domain/patient_formatting.dart';
import 'patient_providers.dart';

class PatientFormPage extends ConsumerStatefulWidget {
  const PatientFormPage({super.key, this.patientId});

  /// `null` → criar novo paciente; caso contrário, editar.
  final String? patientId;

  bool get isEditing => patientId != null;

  @override
  ConsumerState<PatientFormPage> createState() => _PatientFormPageState();
}

class _PatientFormPageState extends ConsumerState<PatientFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _fullName = TextEditingController();
  final _idDocument = TextEditingController();
  final _taxId = TextEditingController();
  final _phone = TextEditingController();
  final _phoneAlt = TextEditingController();
  final _email = TextEditingController();
  final _address = TextEditingController();
  final _city = TextEditingController();
  final _province = TextEditingController();
  final _kinName = TextEditingController();
  final _kinPhone = TextEditingController();
  final _bloodType = TextEditingController();
  final _allergies = TextEditingController();
  final _chronic = TextEditingController();
  final _notes = TextEditingController();

  DateTime? _dob;
  PatientSex? _sex;

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
    final p = await ref.read(patientRepositoryProvider).getById(widget.patientId!);
    if (p != null) {
      _fullName.text = p.fullName;
      _idDocument.text = p.idDocument ?? '';
      _taxId.text = p.taxId ?? '';
      _phone.text = p.phone ?? '';
      _phoneAlt.text = p.phoneAlt ?? '';
      _email.text = p.email ?? '';
      _address.text = p.address ?? '';
      _city.text = p.city ?? '';
      _province.text = p.province ?? '';
      _kinName.text = p.nextOfKinName ?? '';
      _kinPhone.text = p.nextOfKinPhone ?? '';
      _bloodType.text = p.bloodType ?? '';
      _allergies.text = p.allergies ?? '';
      _chronic.text = p.chronicConditions ?? '';
      _notes.text = p.notes ?? '';
      _dob = p.dateOfBirth;
      _sex = patientSexFromName(p.sex);
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() {
    for (final c in [
      _fullName, _idDocument, _taxId, _phone, _phoneAlt, _email, _address,
      _city, _province, _kinName, _kinPhone, _bloodType, _allergies, _chronic,
      _notes,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _n(TextEditingController c) {
    final t = c.text.trim();
    return t.isEmpty ? null : t;
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(now.year - 30),
      firstDate: DateTime(1900),
      lastDate: now,
      locale: const Locale('pt', 'PT'),
      helpText: 'Data de nascimento',
    );
    if (picked != null) setState(() => _dob = picked);
  }

  Future<void> _save() async {
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) return;

    final companion = PatientsCompanion(
      fullName: Value(_fullName.text.trim()),
      dateOfBirth: Value(_dob),
      sex: Value(_sex?.name),
      idDocument: Value(_n(_idDocument)),
      taxId: Value(_n(_taxId)),
      phone: Value(_n(_phone)),
      phoneAlt: Value(_n(_phoneAlt)),
      email: Value(_n(_email)),
      address: Value(_n(_address)),
      city: Value(_n(_city)),
      province: Value(_n(_province)),
      nextOfKinName: Value(_n(_kinName)),
      nextOfKinPhone: Value(_n(_kinPhone)),
      bloodType: Value(_n(_bloodType)),
      allergies: Value(_n(_allergies)),
      chronicConditions: Value(_n(_chronic)),
      notes: Value(_n(_notes)),
    );

    setState(() => _saving = true);
    try {
      final repo = ref.read(patientRepositoryProvider);
      if (widget.isEditing) {
        await repo.update(widget.patientId!, companion);
        if (mounted) context.go('/pacientes/${widget.patientId}');
      } else {
        final created = await repo.create(companion);
        if (mounted) context.go('/pacientes/${created.id}');
      }
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

    return Column(
      children: [
        _Header(
          title: widget.isEditing ? 'Editar paciente' : 'Novo paciente',
          onCancel: () => context.go(
            widget.isEditing ? '/pacientes/${widget.patientId}' : '/pacientes',
          ),
          onSave: _saving ? null : _save,
          saving: _saving,
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
                const _SectionTitle('Identificação'),
                _field(_fullName, 'Nome completo *', validator: (v) =>
                    (v == null || v.trim().length < 2)
                        ? 'Indique o nome.'
                        : null),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: _pickDob,
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Data de nascimento',
                          ),
                          child: Text(
                            _dob == null
                                ? '—'
                                : DateFormat('dd/MM/yyyy').format(_dob!),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<PatientSex>(
                        initialValue: _sex,
                        decoration: const InputDecoration(labelText: 'Sexo'),
                        items: const [
                          DropdownMenuItem(
                              value: PatientSex.feminino, child: Text('Feminino')),
                          DropdownMenuItem(
                              value: PatientSex.masculino,
                              child: Text('Masculino')),
                          DropdownMenuItem(
                              value: PatientSex.outro, child: Text('Outro')),
                        ],
                        onChanged: (v) => setState(() => _sex = v),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: _field(_idDocument, 'Documento de identificação')),
                    const SizedBox(width: 12),
                    Expanded(child: _field(_taxId, 'NIF')),
                  ],
                ),
                const SizedBox(height: 8),
                const _SectionTitle('Contactos'),
                Row(
                  children: [
                    Expanded(child: _field(_phone, 'Telefone')),
                    const SizedBox(width: 12),
                    Expanded(child: _field(_phoneAlt, 'Telefone alternativo')),
                  ],
                ),
                _field(_email, 'Email', keyboardType: TextInputType.emailAddress),
                _field(_address, 'Morada'),
                Row(
                  children: [
                    Expanded(child: _field(_city, 'Cidade')),
                    const SizedBox(width: 12),
                    Expanded(child: _field(_province, 'Província')),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: _field(_kinName, 'Contacto de emergência (nome)')),
                    const SizedBox(width: 12),
                    Expanded(child: _field(_kinPhone, 'Contacto de emergência (telefone)')),
                  ],
                ),
                const SizedBox(height: 8),
                const _SectionTitle('Clínico'),
                _field(_bloodType, 'Grupo sanguíneo'),
                _field(_allergies, 'Alergias', maxLines: 2),
                _field(_chronic, 'Doenças crónicas', maxLines: 2),
                const SizedBox(height: 8),
                const _SectionTitle('Notas'),
                _field(_notes, 'Observações', maxLines: 4),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _field(
    TextEditingController c,
    String label, {
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: c,
        decoration: InputDecoration(labelText: label),
        validator: validator,
        keyboardType: keyboardType,
        maxLines: maxLines,
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.onCancel,
    required this.onSave,
    required this.saving,
  });

  final String title;
  final VoidCallback onCancel;
  final VoidCallback? onSave;
  final bool saving;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const Spacer(),
            TextButton(onPressed: onCancel, child: const Text('Cancelar')),
            const SizedBox(width: 8),
            FilledButton.icon(
              onPressed: onSave,
              icon: saving
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
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}
