import 'package:bloc/bloc.dart';
import 'package:database_repo/patients_repo.dart';
import 'package:database_repo/records_repo.dart';

part 'manage_record_state.dart';
part 'manage_record_event.dart';

class ManageRecordBloc extends Bloc<ManageRecordEvent, ManageRecordState> {
  final PatientsRepo patientsRepo;
  final RecordsRepo recordsRepo;

  ManageRecordBloc({required this.patientsRepo, required this.recordsRepo})
      : super(LoadingManageRecordState());

  @override
  Stream<ManageRecordState> mapEventToState(ManageRecordEvent event) async* {
    if (event is LoadManageRecordEvent) {
      yield* _mapLoadManageRecordEventToState(event);
    } else if (event is UpdateRecordEvent) {
      yield* _mapUpdateRecordEventToState(event);
    } else if (event is DeleteRecordEvent) {
      yield* _mapDeleteRecordEventToState(event);
    } else if (event is ManageRecordLoadedEvent) {
      yield ManageRecordLoadedState(
        patient: event.patient,
        record: event.record,
      );
    }
  }

  Stream<ManageRecordState> _mapLoadManageRecordEventToState(
      LoadManageRecordEvent event) async* {
    yield LoadingManageRecordState();
    Record? record = await this.recordsRepo.getRecordByRID(rid: event.rid);

    if (record == null) {
      yield ManageRecordsErrorState(
        message: 'Error while loading record using RID',
      );
    } else {
      Patient? patient =
          await this.patientsRepo.getPatientByPID(pid: event.pid);

      if (patient == null) {
        yield ManageRecordsErrorState(
          message: 'Error while loading patient using PID',
        );
      } else {
        add(
          ManageRecordLoadedEvent(
            patient: patient,
            record: record,
          ),
        );
      }
    }
  }

  Stream<ManageRecordState> _mapUpdateRecordEventToState(
      UpdateRecordEvent event) async* {
    yield LoadingManageRecordState();

    await this.recordsRepo.updateRecord(
          oldRecord: event.oldRecord,
          updatedRecord: event.updatedRecord,
        );

    Record? record = await this.recordsRepo.getRecordByRID(
          rid: event.oldRecord.rid,
        );

    if (record == null) {
      yield ManageRecordsErrorState(
        message: 'Error while loading record using RID after update',
      );
    } else {
      Patient? patient = await this.patientsRepo.getPatientByPID(
            pid: event.patient.pid,
          );

      if (patient == null) {
        yield ManageRecordsErrorState(
          message: 'Error while loading patient using PID',
        );
      } else {
        add(
          ManageRecordLoadedEvent(
            patient: patient,
            record: record,
          ),
        );
      }
    }
  }

  Stream<ManageRecordState> _mapDeleteRecordEventToState(
      DeleteRecordEvent event) async* {
    yield LoadingManageRecordState();

    await this.recordsRepo.deleteRecord(deletedRecord: event.deletedRecord);

    Record? record = await this.recordsRepo.getRecordByRID(
          rid: event.deletedRecord.rid,
        );

    if (record != null) {
      yield ManageRecordsErrorState(
        message: 'Record still available after deletion',
      );
    } else {
      yield ManageRecordDeletedState();
    }
  }
}
