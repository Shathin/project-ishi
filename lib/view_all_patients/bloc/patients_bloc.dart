import 'package:database_repo/patients_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'patients_event.dart';
part 'patients_state.dart';

class PatientsBloc extends Bloc<PatientsEvent, PatientsState> {
  final PatientsRepo patientsRepo;

  PatientsBloc({required this.patientsRepo}) : super(LoadingPatientsState());

  @override
  Stream<PatientsState> mapEventToState(PatientsEvent event) async* {
    if (event is LoadAllPatientsEvent) {
      yield* _mapLoadAllPatientsEventToState();
    } else if (event is LoadPatientsByNameEvent) {
      yield* _mapLoadPatientsByNameEventToState(event);
    } else if (event is LoadPatientsByAgeEvent) {
      yield* _mapLoadPatientsByAgeEventToState(event);
    } else if (event is LoadPatientsByGenderEvent) {
      yield* _mapLoadPatientsByGenderEventToState(event);
    } else if (event is CreateNewPatientEvent) {
      yield* _mapCreateNewPatientEventToState(event);
    } else if (event is UpdatePatientEvent) {
      yield* _mapUpdatePatientEventToState(event);
    } else if (event is PatientsLoadedEvent) {
      yield PatientsLoadedState(patients: event.patients);
    }
  }

  Stream<PatientsState> _mapLoadAllPatientsEventToState() async* {
    yield LoadingPatientsState();

    List<Patient>? patients = await patientsRepo.getAllPatients();

    add(PatientsLoadedEvent(patients: patients));
  }

  Stream<PatientsState> _mapLoadPatientsByNameEventToState(
      LoadPatientsByNameEvent event) async* {
    yield LoadingPatientsState();

    List<Patient>? patients = await patientsRepo.getPatientsByName(
      name: event.searchString,
    );

    add(PatientsLoadedEvent(patients: patients));
  }

  Stream<PatientsState> _mapLoadPatientsByAgeEventToState(
      LoadPatientsByAgeEvent event) async* {
    yield LoadingPatientsState();

    List<Patient>? patients = await patientsRepo.getPatientsByAge(
      age: event.searchAge,
    );

    add(PatientsLoadedEvent(patients: patients));
  }

  Stream<PatientsState> _mapLoadPatientsByGenderEventToState(
      LoadPatientsByGenderEvent event) async* {
    yield LoadingPatientsState();

    List<Patient>? patients = await patientsRepo.getPatientsByGender(
      gender: event.searchGender,
    );

    add(PatientsLoadedEvent(patients: patients));
  }

  Stream<PatientsState> _mapCreateNewPatientEventToState(
      CreateNewPatientEvent event) async* {
    yield LoadingPatientsState();

    await patientsRepo.createPatient(
      patient: event.patient,
    );

    add(LoadAllPatientsEvent());
  }

  Stream<PatientsState> _mapUpdatePatientEventToState(
      UpdatePatientEvent event) async* {
    yield LoadingPatientsState();

    await patientsRepo.updatePatient(
      oldPatient: event.oldPatient,
      updatedPatient: event.updatedPatient,
    );

    add(LoadAllPatientsEvent());
  }
}
