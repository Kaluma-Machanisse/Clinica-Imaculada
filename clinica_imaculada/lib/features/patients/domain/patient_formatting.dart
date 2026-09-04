import 'package:intl/intl.dart';

import '../data/patients_table.dart';

final _dateFormat = DateFormat('dd/MM/yyyy');

/// Nº de processo formatado com zeros à esquerda (ex.: 42 → "0042").
String formatProcessNumber(int n) => n.toString().padLeft(4, '0');

String formatDate(DateTime? d) => d == null ? '—' : _dateFormat.format(d);

/// Idade em anos a partir da data de nascimento.
int? ageFromDob(DateTime? dob, {DateTime? now}) {
  if (dob == null) return null;
  final ref = now ?? DateTime.now();
  var age = ref.year - dob.year;
  if (ref.month < dob.month ||
      (ref.month == dob.month && ref.day < dob.day)) {
    age--;
  }
  return age < 0 ? null : age;
}

String formatDobWithAge(DateTime? dob) {
  if (dob == null) return '—';
  final age = ageFromDob(dob);
  return age == null ? _dateFormat.format(dob) : '${_dateFormat.format(dob)} ($age anos)';
}

PatientSex? patientSexFromName(String? name) {
  if (name == null) return null;
  for (final s in PatientSex.values) {
    if (s.name == name) return s;
  }
  return null;
}

String patientSexLabel(String? name) {
  return switch (patientSexFromName(name)) {
    PatientSex.feminino => 'Feminino',
    PatientSex.masculino => 'Masculino',
    PatientSex.outro => 'Outro',
    null => '—',
  };
}
