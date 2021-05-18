part of 'manage_patient_bloc.dart';

abstract class ManagePatientEvent {}

/// Represents the event of loading the patient and the corresponding records from the database
class LoadManagePatientEvent extends ManagePatientEvent {
  String pid;

  LoadManagePatientEvent({required this.pid});
}

/// Represents the event of successfully loading the patient and the corresponding records from the database
class ManagePatientLoadedEvent extends ManagePatientEvent {
  Patient patient;
  List<Record> records;

  ManagePatientLoadedEvent({
    required this.patient,
    this.records = const <Record>[],
  });
}

/// Represents the event of adding a new record under the patient
class CreateNewRecordEvent extends ManagePatientEvent {
  Patient oldPatient;
  Record newRecord;

  CreateNewRecordEvent({
    required this.oldPatient,
    required this.newRecord,
  });
}

/// Represents the event of updating a record
class UpdateRecordEvent extends ManagePatientEvent {
  Patient oldPatient;

  Record oldRecord;
  Record updatedRecord;

  UpdateRecordEvent({
    required this.oldPatient,
    required this.oldRecord,
    required this.updatedRecord,
  });
}

/// Represents the event of deleting a record
class DeleteRecordEvent extends ManagePatientEvent {
  Patient oldPatient;

  Record deletedRecord;

  DeleteRecordEvent({
    required this.oldPatient,
    required this.deletedRecord,
  });
}

/// Represents the event of deleting the patient (and all their records)
class DeletePatientEvent extends ManagePatientEvent {
  Patient deletedPatient;
  List<Record> deletedRecords;

  DeletePatientEvent({
    required this.deletedPatient,
    this.deletedRecords = const <Record>[],
  });
}

/// Represents the event of updating a patient
class UpdatePatientEvent extends ManagePatientEvent {
  List<Record> oldRecords;

  Patient oldPatient;
  Patient updatedPatient;

  UpdatePatientEvent({
    required this.oldRecords,
    required this.oldPatient,
    required this.updatedPatient,
  });
}
