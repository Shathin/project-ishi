import 'package:bloc/bloc.dart';
import 'package:database_repo/patients_repo.dart';
import 'package:database_repo/records_repo.dart';

part 'manage_patient_event.dart';
part 'manage_patient_state.dart';

class ManagePatientBloc extends Bloc<ManagePatientEvent, ManagePatientState> {
  final RecordsRepo recordsRepo;
  final PatientsRepo patientsRepo;

  ManagePatientBloc({
    required this.recordsRepo,
    required this.patientsRepo,
  }) : super(LoadingManagePatientState());

  @override
  Stream<ManagePatientState> mapEventToState(ManagePatientEvent event) async* {
    if (event is LoadManagePatientEvent) {
      yield* _mapLoadManagePatientEventToState(event);
    } else if (event is CreateNewRecordEvent) {
      yield* _mapCreateNewRecordEventToState(event);
    } else if (event is UpdateRecordEvent) {
      yield* _mapUpdateRecordEventToState(event);
    } else if (event is DeleteRecordEvent) {
      yield* _mapDeleteRecordEventToState(event);
    } else if (event is DeletePatientEvent) {
      yield* _mapDeletePatientEventToState(event);
    } else if (event is UpdatePatientEvent) {
      yield* _mapUpdatePatientEventToState(event);
    } else if (event is ManagePatientLoadedEvent) {
      yield ManagePatientLoadedState(
        patient: event.patient,
        records: event.records,
      );
    }
  }

  Stream<ManagePatientState> _mapLoadManagePatientEventToState(
      LoadManagePatientEvent event) async* {
    yield LoadingManagePatientState();

    Patient? patient = await this.patientsRepo.getPatientByPID(pid: event.pid);

    if (patient == null) {
      yield ManagePatientsErrorState(
        message: 'Error loading patient with PID: ${event.pid}',
      );
    } else {
      List<Record>? records = await this.recordsRepo.getRecordsByPID(
            pid: event.pid,
            sortByDateOfProcedure: true,
          );

      add(
        ManagePatientLoadedEvent(
          patient: patient,
          records: records ?? [],
        ),
      );
    }
  }

  Stream<ManagePatientState> _mapCreateNewRecordEventToState(
      CreateNewRecordEvent event) async* {
    yield LoadingManagePatientState();

    await this.recordsRepo.createRecord(record: event.newRecord);

    Patient? patient = await this.patientsRepo.getPatientByPID(
          pid: event.oldPatient.pid,
        );

    if (patient == null) {
      yield ManagePatientsErrorState(
        message:
            'Error loading patient with PID: ${event.oldPatient.pid} after "Create New Record" event!',
      );
    } else {
      List<Record>? records = await this.recordsRepo.getRecordsByPID(
            pid: patient.pid,
          );

      if (records == null) {
        yield ManagePatientsErrorState(
          message:
              'Error loading records after "Create New Record" event! No records were found!',
        );
      } else {
        if (records.length != event.oldPatient.recordReferences.length + 1) {
          yield ManagePatientsErrorState(
            message:
                'Error loading records after "Create New Record" event! Number of records prior to creation and post creation are equal, suggesting that no records was inserted!',
          );
        } else {
          add(
            ManagePatientLoadedEvent(
              patient: patient,
              records: records,
            ),
          );
        }
      }
    }
  }

  Stream<ManagePatientState> _mapUpdateRecordEventToState(
      UpdateRecordEvent event) async* {
    yield LoadingManagePatientState();

    await this.recordsRepo.updateRecord(
          oldRecord: event.oldRecord,
          updatedRecord: event.updatedRecord,
        );

    Patient? patientFromDB = await this.patientsRepo.getPatientByPID(
          pid: event.oldPatient.pid,
        );

    if (patientFromDB == null) {
      yield ManagePatientsErrorState(
        message:
            'Error loading patient with PID: ${event.oldPatient.pid} after "Update Record" event!',
      );
    } else {
      List<Record>? records = await this.recordsRepo.getRecordsByPID(
            pid: patientFromDB.pid,
          );

      if (records == null) {
        yield ManagePatientsErrorState(
          message:
              'Error loading records after "Update Record" event! No records were found!',
        );
      } else {
        if (records.length != event.oldPatient.recordReferences.length) {
          yield ManagePatientsErrorState(
            message:
                'Error loading records after "Update Record" event! Number of records prior to update and post update are not equal, suggesting that some record(s) have been deleted!',
          );
        } else {
          add(
            ManagePatientLoadedEvent(
              patient: patientFromDB,
              records: records,
            ),
          );
        }
      }
    }
  }

  Stream<ManagePatientState> _mapDeleteRecordEventToState(
      DeleteRecordEvent event) async* {
    yield LoadingManagePatientState();

    await this.recordsRepo.deleteRecord(deletedRecord: event.deletedRecord);

    Patient? patientFromDB = await this.patientsRepo.getPatientByPID(
          pid: event.oldPatient.pid,
        );

    if (patientFromDB == null) {
      yield ManagePatientsErrorState(
        message:
            'Error loading patient with PID: ${event.oldPatient.pid} after "Delete Record" event!',
      );
    } else {
      List<Record>? records = await this.recordsRepo.getRecordsByPID(
            pid: patientFromDB.pid,
          );

      if (records == null) {
        if (event.oldPatient.recordReferences.length - 1 != 0) {
          yield ManagePatientsErrorState(
            message: 'No records were expected after "Delete Record" event!',
          );
        } else {
          add(
            ManagePatientLoadedEvent(
              patient: patientFromDB,
              records: [],
            ),
          );
        }
      } else {
        if (records.length != event.oldPatient.recordReferences.length - 1) {
          yield ManagePatientsErrorState(
            message:
                'Error loading records after "Delete Record" event! Number of records prior to deletion and post deletion either match or differ by a greater than one suggesting that either no deletion occurred or more than one records were deleted!',
          );
        } else {
          add(
            ManagePatientLoadedEvent(
              patient: patientFromDB,
              records: records,
            ),
          );
        }
      }
    }
  }

  Stream<ManagePatientState> _mapDeletePatientEventToState(
      DeletePatientEvent event) async* {
    for (Record deletedRecord in event.deletedRecords) {
      await this.recordsRepo.deleteRecord(deletedRecord: deletedRecord);
    }

    await this.patientsRepo.deletePatient(deletedPatient: event.deletedPatient);

    yield PatientDeletedState();
  }

  Stream<ManagePatientState> _mapUpdatePatientEventToState(
      UpdatePatientEvent event) async* {
    yield LoadingManagePatientState();

    await this.patientsRepo.updatePatient(
          oldPatient: event.oldPatient,
          updatedPatient: event.updatedPatient,
        );

    Patient? patient = await this.patientsRepo.getPatientByPID(
          pid: event.oldPatient.pid,
        );

    if (patient == null) {
      yield ManagePatientsErrorState(
        message:
            'Error loading patient with PID: ${patient?.pid} after "Update Patient" event!',
      );
    } else {
      add(
        ManagePatientLoadedEvent(
          patient: patient,
          records: event.oldRecords,
        ),
      );
    }
  }
}
