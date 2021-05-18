part of 'manage_record_bloc.dart';

abstract class ManageRecordState {}

/// Represents the state of loading the patient and the corresponding record object
class LoadingManageRecordState extends ManageRecordState {}

/// Represents the state of successful loading of the patient and the corresponding record object
class ManageRecordLoadedState extends ManageRecordState {
  Patient patient;
  Record record;

  ManageRecordLoadedState({
    required this.patient,
    required this.record,
  });
}

/// Represents a state of error
///
/// Access the [message] variable to get the error message
class ManageRecordsErrorState extends ManageRecordState {
  String message;

  ManageRecordsErrorState({required this.message});
}

/// Represents the state of deletion of a record
class ManageRecordDeletedState extends ManageRecordState {}
