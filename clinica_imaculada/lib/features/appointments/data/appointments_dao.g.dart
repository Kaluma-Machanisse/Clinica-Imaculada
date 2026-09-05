// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appointments_dao.dart';

// ignore_for_file: type=lint
mixin _$AppointmentsDaoMixin on DatabaseAccessor<AppDatabase> {
  $PatientsTable get patients => attachedDatabase.patients;
  $UsersTable get users => attachedDatabase.users;
  $AppointmentsTable get appointments => attachedDatabase.appointments;
  AppointmentsDaoManager get managers => AppointmentsDaoManager(this);
}

class AppointmentsDaoManager {
  final _$AppointmentsDaoMixin _db;
  AppointmentsDaoManager(this._db);
  $$PatientsTableTableManager get patients =>
      $$PatientsTableTableManager(_db.attachedDatabase, _db.patients);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db.attachedDatabase, _db.users);
  $$AppointmentsTableTableManager get appointments =>
      $$AppointmentsTableTableManager(_db.attachedDatabase, _db.appointments);
}
