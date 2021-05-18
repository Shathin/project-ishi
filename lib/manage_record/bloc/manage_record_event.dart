part of 'manage_record_bloc.dart';

abstract class ManageRecordEvent {}

/// Represents the event of loading the patient and the corresponding record from the database

class LoadManageRecordEvent extends ManageRecordEvent {
  String pid;
  String rid;

  LoadManageRecordEvent({required this.pid, required this.rid});
}

/// Represents the event of successfully loading the patient and the corresponding record from the database
class ManageRecordLoadedEvent extends ManageRecordEvent {
  Patient patient;
  Record record;

  ManageRecordLoadedEvent({
    required this.patient,
    required this.record,
  });
}

/// Represents the event of updating a record
class UpdateRecordEvent extends ManageRecordEvent {
  Patient patient;
  Record oldRecord;
  Record updatedRecord;

  UpdateRecordEvent({
    required this.patient,
    required this.oldRecord,
    required this.updatedRecord,
  });
}

/// Represents the event of deleting a record
class DeleteRecordEvent extends ManageRecordEvent {
  Record deletedRecord;

  DeleteRecordEvent({
    required this.deletedRecord,
  });
}
