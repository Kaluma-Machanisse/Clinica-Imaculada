import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/appointments_table.dart';

final _timeFormat = DateFormat('HH:mm');
final _dateFormat = DateFormat('dd/MM/yyyy');

String formatTime(DateTime dt) => _timeFormat.format(dt);
String formatDate(DateTime dt) => _dateFormat.format(dt);

AppointmentStatus statusFromName(String name) {
  return AppointmentStatus.values.firstWhere(
    (s) => s.name == name,
    orElse: () => AppointmentStatus.agendada,
  );
}

String statusLabel(String name) {
  return switch (statusFromName(name)) {
    AppointmentStatus.agendada => 'Agendada',
    AppointmentStatus.confirmada => 'Confirmada',
    AppointmentStatus.emAtendimento => 'Em atendimento',
    AppointmentStatus.concluida => 'Concluída',
    AppointmentStatus.cancelada => 'Cancelada',
    AppointmentStatus.faltou => 'Faltou',
  };
}

Color statusColor(String name, ColorScheme scheme) {
  return switch (statusFromName(name)) {
    AppointmentStatus.agendada => scheme.secondary,
    AppointmentStatus.confirmada => scheme.primary,
    AppointmentStatus.emAtendimento => scheme.tertiary,
    AppointmentStatus.concluida => Colors.green,
    AppointmentStatus.cancelada => scheme.error,
    AppointmentStatus.faltou => scheme.error,
  };
}
