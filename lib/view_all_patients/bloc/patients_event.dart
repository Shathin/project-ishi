part of 'patients_bloc.dart';

abstract class PatientsEvent {}

/// Represents the event of loading the all the patient objects from the database
class LoadAllPatientsEvent extends PatientsEvent {}

/// Represents the event of loading the patients having the [searchString] as the name from the database
class LoadPatientsByNameEvent extends PatientsEvent {
  final String searchString;

  LoadPatientsByNameEvent({required this.searchString});
}

/// Represents the event of loading the patients having the [searchAge] as their age from the database
class LoadPatientsByAgeEvent extends PatientsEvent {
  final int searchAge;

  LoadPatientsByAgeEvent({required this.searchAge});
}

/// Represents the event of loading the patients having the [searchGender] as their gender from the database
class LoadPatientsByGenderEvent extends PatientsEvent {
  final Gender searchGender;

  LoadPatientsByGenderEvent({required this.searchGender});
}

/// Represents the event of successful loading of the patient objects from the database
class PatientsLoadedEvent extends PatientsEvent {
  List<Patient>? patients;

  PatientsLoadedEvent({required this.patients});
}

/// Represents the event of creating a new patient object and storing it in the database
class CreateNewPatientEvent extends PatientsEvent {
  Patient patient;

  CreateNewPatientEvent({required this.patient});
}

/// Represents the event of updating a object and storing it in the database
class UpdatePatientEvent extends PatientsEvent {
  Patient oldPatient;
  Patient updatedPatient;

  UpdatePatientEvent({
    required this.oldPatient,
    required this.updatedPatient,
  });
}
