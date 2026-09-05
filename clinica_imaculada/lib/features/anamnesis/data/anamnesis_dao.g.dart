// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'anamnesis_dao.dart';

// ignore_for_file: type=lint
mixin _$AnamnesisDaoMixin on DatabaseAccessor<AppDatabase> {
  $PatientsTable get patients => attachedDatabase.patients;
  $UsersTable get users => attachedDatabase.users;
  $AppointmentsTable get appointments => attachedDatabase.appointments;
  $AnamnesisEntriesTable get anamnesisEntries =>
      attachedDatabase.anamnesisEntries;
  AnamnesisDaoManager get managers => AnamnesisDaoManager(this);
}

class AnamnesisDaoManager {
  final _$AnamnesisDaoMixin _db;
  AnamnesisDaoManager(this._db);
  $$PatientsTableTableManager get patients =>
      $$PatientsTableTableManager(_db.attachedDatabase, _db.patients);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db.attachedDatabase, _db.users);
  $$AppointmentsTableTableManager get appointments =>
      $$AppointmentsTableTableManager(_db.attachedDatabase, _db.appointments);
  $$AnamnesisEntriesTableTableManager get anamnesisEntries =>
      $$AnamnesisEntriesTableTableManager(
        _db.attachedDatabase,
        _db.anamnesisEntries,
      );
}
