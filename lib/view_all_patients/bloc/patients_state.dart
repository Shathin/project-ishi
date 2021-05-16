part of 'patients_bloc.dart';

abstract class PatientsState {}

/// Represents the state of loading the patient objects from the database
class LoadingPatientsState extends PatientsState {}

/// Represents the state of successful completion of loading the patient objects from the database
class PatientsLoadedState extends PatientsState {
  List<Patient>? patients;

  PatientsLoadedState({required this.patients});
}
