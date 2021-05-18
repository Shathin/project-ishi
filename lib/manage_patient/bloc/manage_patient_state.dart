part of 'manage_patient_bloc.dart';

abstract class ManagePatientState {}

/// Represents the state of loading the patient and the corresponding record objects
class LoadingManagePatientState extends ManagePatientState {}

/// Represents the state of successful loading of the patient and the corresponding record objects
class ManagePatientLoadedState extends ManagePatientState {
  Patient patient;
  List<Record> records;

  ManagePatientLoadedState({
    required this.patient,
    this.records = const <Record>[],
  });
}

/// Represents a state of error
///
/// Access the [message] variable to get the error message
class ManagePatientsErrorState extends ManagePatientState {
  String message;

  ManagePatientsErrorState({required this.message});
}

/// Represents the state of deletion of a patient
class PatientDeletedState extends ManagePatientState {}
