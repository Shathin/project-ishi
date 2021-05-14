// ! File imports
import 'package:uuid/uuid.dart';

import 'gender.dart';

/// Class that represents a patient object
class Patient {
  /// Represents the key used to access the patient record in the database
  final String pid;

  /// Represents the name of the patient
  final String name;

  /// Represents the age of the patient
  final int? age;

  /// Represents the gender of the patient
  final Gender gender;

  /// Represents a list of references to the records that belong to this patient
  final List<String> recordReferences;

  /// Constructor to instantiate the [Patient] class
  Patient({
    required this.pid,
    required this.name,
    this.age,
    this.gender = Gender.Other,
    this.recordReferences = const <String>[],
  });

  /// Use this constructor while creating new [Patient] objects
  ///
  /// This constructor auto-generates a new [pid] using the UUID package
  /// and creates an empty [recordReferences] list
  Patient.create({
    required this.name,
    this.age,
    this.gender = Gender.Other,
  })  : this.pid = Uuid().v1(),
        this.recordReferences = const <String>[];

  /// Method to convert the [Patient] object into a map
  Map<String, dynamic> objectToMap() {
    Map<String, dynamic> patientMap = {
      "name": this.name,
      "gender": this.gender.enumToString(),
      "records": this.recordReferences,
    };

    if (age != null) patientMap["age"] = this.age;

    return patientMap;
  }

  /// Method to convert a map containing the patient record into a [Patient] object
  static Patient mapToObject({
    required String recordId,
    required Map<String, dynamic> patientMap,
  }) {
    return Patient(
      name: patientMap["name"],
      pid: recordId,
      gender: GenderStringInterconversion.stringToEnum(patientMap["gender"]),
      age: patientMap["age"],
      recordReferences: List.from(patientMap["records"]),
    );
  }

  /// Method that returns a copy of the current [Patient] object with a specified fields replaced by the arguments passed to this method
  Patient copyWith({
    String? name,
    int? age,
    Gender? gender,
    List<String>? recordReferences,
  }) =>
      Patient(
        name: name ?? this.name,
        age: age ?? this.age,
        gender: gender ?? this.gender,
        recordReferences: recordReferences ?? this.recordReferences,
        pid: this.pid,
      );

  @override
  String toString() {
    String patientToString = '';

    patientToString += "\n";
    patientToString += '${this.pid} : {';
    patientToString += '\n\t';

    patientToString += 'Name: ${this.name}';
    patientToString += '\n\t';

    patientToString += 'Gender: ${this.gender.enumToString()}';
    patientToString += '\n\t';

    if (this.age != null) {
      patientToString += 'Age: ${this.age}';
      patientToString += '\n\t';
    }

    patientToString += 'Records: [';
    for (String ref in this.recordReferences) {
      patientToString += '\n\t\t';
      patientToString += ref;
    }
    patientToString += '\n\t';
    patientToString += "]";

    patientToString += "\n";
    patientToString += "}";

    return patientToString;
  }
}
