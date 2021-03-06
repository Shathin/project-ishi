// ! Third party libraries
import 'package:logging_repo/logging.dart';
import 'package:sembast/sembast.dart';

// ! Models
import './models/models.dart';

/// Repository that provides operations associated with the patients collection
class PatientsRepo {
  final StoreRef _patientsStore;
  final Database _patientsDatabase;

  PatientsRepo({
    required Database patientsDatabase,
    required StoreRef patientsStore,
  })  : this._patientsDatabase = patientsDatabase,
        this._patientsStore = patientsStore;

  /// Getter to obtain the patient's [StoreRef] object
  StoreRef get patientsStore => this._patientsStore;

  /// Getter to obtain the patient's [Database] object
  Database get patientsDatabase => this._patientsDatabase;

  // * CREATE ===========================================================================

  /// Writes to a new patient record to the database
  Future<void> createPatient({
    required Patient patient,
  }) async {
    await this
        ._patientsStore
        .record(patient.pid)
        .add(this._patientsDatabase, patient.objectToMap());

    LoggingService.loggingService.log('createPatient');
  }

  // * READ =============================================================================

  /// Fetches a patient by patient id
  ///
  /// Returns [null] if none found
  Future<Patient?> getPatientByPID({required String pid}) async {
    final patientMap = await this
        ._patientsStore
        .record(pid)
        .get(this._patientsDatabase) as Map<String, dynamic>?;

    if (patientMap == null) return null;

    LoggingService.loggingService.log('getPatientByPID');

    return Patient.mapToObject(
      recordId: pid,
      patientMap: patientMap,
    );
  }

  /// Fetches a list of patients by name
  ///
  /// Returns [null] if none found
  Future<List<Patient>?> getPatientsByName({
    required String name,
  }) async {
    List<RecordSnapshot> recordSnapshotList = await this._patientsStore.find(
          this._patientsDatabase,
          finder: Finder(
            filter: Filter.matches('name', name),
          ),
        );

    LoggingService.loggingService.log('getPatientsByName');

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
  Future<List<Patient>?> getPatientsByAge({
    required int age,
  }) async {
    List<RecordSnapshot> recordSnapshotList = await this._patientsStore.find(
          this._patientsDatabase,
          finder: Finder(
            filter: Filter.equals('age', age),
          ),
        );

    LoggingService.loggingService.log('getPatientsByAge');

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
  Future<List<Patient>?> getPatientsByGender({
    required Gender gender,
  }) async {
    List<RecordSnapshot> recordSnapshotList = await this._patientsStore.find(
          this._patientsDatabase,
          finder: Finder(
            filter: Filter.equals('gender', gender.enumToString()),
          ),
        );

    LoggingService.loggingService.log('getPatientsByGender');

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
          this._patientsDatabase,
          finder: null,
        );

    LoggingService.loggingService.log('getAllPatients');

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
        .update(this._patientsDatabase, updatedPatient.objectToMap());

    LoggingService.loggingService.log('updatePatient');
  }

  // * DELETE ===========================================================================

  /// Deletes the patient record passed to this method as the argument
  Future<void> deletePatient({
    required Patient deletedPatient,
  }) async {
    await this
        ._patientsStore
        .record(deletedPatient.pid)
        .delete(this._patientsDatabase);

    LoggingService.loggingService.log('deletePatient');
  }

  /// Empties the patients database
  ///
  /// Use with caution! ???
  Future<void> emptyPatientsDatabase() async {
    await this._patientsStore.drop(this._patientsDatabase);
  }
}
