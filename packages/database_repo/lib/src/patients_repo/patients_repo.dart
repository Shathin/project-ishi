// ! Third party libraries
import 'package:sembast/sembast.dart';

// ! Models
import './models/models.dart';

/// Repository that provides operations associated with the patients collection
class PatientsRepo {
  final StoreRef _patientsStore;
  final Database _database;

  PatientsRepo({required Database database})
      : this._database = database,
        this._patientsStore = stringMapStoreFactory.store('patients');

  // * CREATE ===========================================================================

  /// Writes to a new patient record to the database
  Future<void> createPatient({
    required Patient patient,
  }) async {
    await this
        ._patientsStore
        .record(patient.pid)
        .add(this._database, patient.objectToMap());
  }

  // * READ =============================================================================

  /// Fetches a list of patients by patient id
  ///
  /// Returns [null] if none found
  Future<Patient?> getPatientByPID({required String pid}) async {
    final patientMap = await this._patientsStore.record(pid).get(this._database)
        as Map<String, dynamic>?;

    if (patientMap == null) return null;

    return Patient.mapToObject(
      recordId: pid,
      patientMap: patientMap,
    );
  }

  /// Fetches a list of patients by name
  ///
  /// Returns [null] if none found
  Future<List<Patient>?> getPatientByName({
    required String name,
  }) async {
    List<RecordSnapshot> recordSnapshotList = await this._patientsStore.find(
          this._database,
          finder: Finder(
            filter: Filter.matches('name', name),
          ),
        );

    if (recordSnapshotList.isEmpty) return null;

    List<Patient> patientList = <Patient>[];

    recordSnapshotList.forEach((snapshot) {
      patientList.add(Patient.mapToObject(
        recordId: snapshot.key,
        patientMap: snapshot.value,
      ));
    });

    return patientList;
  }

  /// Fetches a list of patients by age
  ///
  /// Returns [null] if none found
  Future<List<Patient>?> getPatientByAge({
    required int age,
  }) async {
    List<RecordSnapshot> recordSnapshotList = await this._patientsStore.find(
          this._database,
          finder: Finder(
            filter: Filter.equals('age', age),
          ),
        );

    if (recordSnapshotList.isEmpty) return null;

    List<Patient> patientList = <Patient>[];

    recordSnapshotList.forEach((snapshot) {
      patientList.add(Patient.mapToObject(
        recordId: snapshot.key,
        patientMap: snapshot.value,
      ));
    });

    return patientList;
  }

  /// Fetches a list of patients by gender
  ///
  /// Returns [null] if none found
  Future<List<Patient>?> getPatientByGender({
    required Gender gender,
  }) async {
    List<RecordSnapshot> recordSnapshotList = await this._patientsStore.find(
          this._database,
          finder: Finder(
            filter: Filter.equals('gender', gender.enumToString()),
          ),
        );

    if (recordSnapshotList.isEmpty) return null;

    List<Patient> patientList = <Patient>[];

    recordSnapshotList.forEach((snapshot) {
      patientList.add(Patient.mapToObject(
        recordId: snapshot.key,
        patientMap: snapshot.value,
      ));
    });

    return patientList;
  }

  /// Fetches all the patient records from the database
  ///
  /// Returns [null] is no records exist
  Future<List<Patient>?> getAllPatients() async {
    List<RecordSnapshot> recordSnapshotList = await this._patientsStore.find(
          this._database,
        );

    if (recordSnapshotList.isEmpty) return null;

    List<Patient> patientList = <Patient>[];

    recordSnapshotList.forEach((snapshot) {
      patientList.add(Patient.mapToObject(
        recordId: snapshot.key,
        patientMap: snapshot.value,
      ));
    });

    return patientList;
  }

  // * UPDATE ===========================================================================

  /// Updates the [oldPatient] record with the [updatedPatient] object supplied to this method as the argument
  Future<void> updatePatient({
    required Patient oldPatient,
    required Patient updatedPatient,
  }) async {
    await this
        ._patientsStore
        .record(updatedPatient.pid)
        .update(this._database, updatedPatient.objectToMap());
  }

  // * DELETE ===========================================================================

  /// Deletes the patient record passed to this method as the argument
  Future<void> deletePatient({
    required Patient deletedPatient,
  }) async {
    await this._patientsStore.record(deletedPatient.pid).delete(this._database);
  }
}
