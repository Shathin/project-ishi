import 'dart:math';
import "package:flutter_test/flutter_test.dart";
import "package:collection/collection.dart";

// ! Third party libraries
import "package:sembast/sembast.dart" as sembast;
import "package:sembast/sembast_io.dart" as sembastIO;

// ! File imports
import "package:database_repo/patients_repo.dart";
import 'package:database_repo/utils.dart';
import 'package:uuid/uuid.dart';

void main() async {
  group(
    "Testing Patients Repository 🩺",
    () {
      late PatientsRepo patientsRepo;
      late String databaseFile = "test.db";
      late sembast.Database patientsDatabase;
      late sembast.StoreRef patientsStore;
      late Map<String, dynamic> mockPatientsData;

      // ! Setting up the objects required for each test before the start of each test
      setUp(() async {
        patientsDatabase =
            await sembastIO.databaseFactoryIo.openDatabase(databaseFile);

        patientsStore = sembast.stringMapStoreFactory.store("patients");

        patientsRepo = PatientsRepo(
          patientsDatabase: patientsDatabase,
          patientsStore: patientsStore,
        );

        mockPatientsData = (await MockData.processMockData())['patients'] ?? {};
      });

      // ! Closing the database connection and deleting the database file after each test
      tearDown(() async {
        patientsDatabase.close();
        await sembastIO.databaseFactoryIo.deleteDatabase(databaseFile);
      });

      /// Initialize mock data in the database
      Future<void> initializeMockData() async {
        bool patientsInitStatus = await MockData.initializeMockPatientsData(
          patientsDatabase: patientsDatabase,
          patientsStore: patientsStore,
        );

        if (!patientsInitStatus)
          throw TestFailure(
            'Failure while initalizing mock patients data in the database!',
          );
      }

      /// A method that fetches all the patient records from the database and converts it into a map of the form {pid: patient}
      Future<Map<String, dynamic>> getAllPatientsFromDB() async {
        // * Fetch all the patients from the database
        final List<Patient>? allPatientsFromDB =
            await patientsRepo.getAllPatients();

        if (allPatientsFromDB == null)
          throw TestFailure(
            'Test failed while fetching all patient records from the database',
          );

        final Map<String, dynamic> allPatientsFromDBMap = {};
        allPatientsFromDB.forEach((patient) {
          allPatientsFromDBMap[patient.pid] = patient.objectToMap();
        });

        return allPatientsFromDBMap;
      }

      /// A method that fetches a the patient record from the database by searching for it using the pid
      Future<Map<String, dynamic>> getPatientFromDB({
        required String pid,
      }) async {
        // * Fetch the patient from the database
        final Patient? patientFromDB = await patientsRepo.getPatientByPID(
          pid: pid,
        );

        if (patientFromDB == null)
          throw TestFailure(
            'Test failed because no patient with PID $pid was found',
          );

        return patientFromDB.objectToMap();
      }

      group(
        "Test CREATE ➕",
        () {
          late Patient newPatient;
          setUp(
            () {
              // * Create a new patient
              newPatient = Patient.create(
                name: 'Monkey D. Luffy',
                gender: Gender.Male,
              );
            },
          );

          test(
            "Test [createPatient()] method for an empty database",
            () async {
              // ! The locally created patient must not exist in the database before invocation of [createPatient()] method
              expect(
                await patientsStore
                    .record(newPatient.pid)
                    .exists(patientsDatabase),
                false,
              );

              // ! The database must be empty before the invocation of [createPatient()] method
              expect(
                await patientsStore.count(patientsDatabase),
                0,
              );

              // * Invoke the [createPatient()] method
              await patientsRepo.createPatient(patient: newPatient);

              // ! The locally created patient must exist in the database after invocation of [createPatient()] method
              expect(
                await patientsStore
                    .record(newPatient.pid)
                    .exists(patientsDatabase),
                true,
              );

              // ! The locally created patient must match with the patient record in the database
              expect(
                DeepCollectionEquality.unordered().equals(
                  await patientsStore
                      .record(newPatient.pid)
                      .get(patientsDatabase) as Map<String, dynamic>,
                  newPatient.objectToMap(),
                ),
                true,
              );

              // ! The database must have only 1 record after the invocation of [createPatient()] method
              expect(
                await patientsStore.count(patientsDatabase),
                1,
              );
            },
          );

          test(
            "Test [createPatient()] method for a database that already has some records",
            () async {
              await initializeMockData();

              // ! The locally created patient must not exist in the database before invocation of [createPatient()] method
              expect(
                await patientsStore
                    .record(newPatient.pid)
                    .exists(patientsDatabase),
                false,
              );

              // ! The database must contain [mockPatientsData.keys.length] number of records before the invocation of [createPatient()] method
              expect(
                await patientsStore.count(patientsDatabase),
                mockPatientsData.keys.length,
              );

              // * Invoke the [createPatient()] method
              await patientsRepo.createPatient(patient: newPatient);

              // ! The locally created patient must exist in the database after invocation of [createPatient()] method
              expect(
                await patientsStore
                    .record(newPatient.pid)
                    .exists(patientsDatabase),
                true,
              );

              // ! The locally created patient must match with the patient record in the database
              expect(
                DeepCollectionEquality.unordered().equals(
                  await patientsStore
                      .record(newPatient.pid)
                      .get(patientsDatabase) as Map<String, dynamic>,
                  newPatient.objectToMap(),
                ),
                true,
              );

              // ! The database must contain [mockPatientsData.keys.length + 1] number of records before the invocation of [createPatient()] method
              expect(
                await patientsStore.count(patientsDatabase),
                mockPatientsData.keys.length + 1,
              );
            },
          );
        },
      );

      group(
        "Test READ 📖",
        () {
          group(
            'Test [getPatientByPID()] method',
            () {
              setUp(() async {
                await initializeMockData();
              });

              test(
                "Test for a pid that exists in the database",
                () async {
                  // * Fetch a random PID from the [mockPatientsData] map
                  String randomPID = mockPatientsData.keys.elementAt(
                      Random().nextInt(mockPatientsData.keys.length));
                  Map<String, dynamic> randomPatientMap =
                      mockPatientsData[randomPID];

                  // * Invoke the [getPatientByPID()] method to search for the [randomPID]
                  Patient? patient =
                      await patientsRepo.getPatientByPID(pid: randomPID);

                  if (patient == null)
                    throw TestFailure(
                      'Test failed because no patient with PID $randomPID was found',
                    );

                  // ! The patient fetched from the database must match the patient chosen from the [mockPatientsData] map
                  expect(
                    DeepCollectionEquality.unordered().equals(
                      patient.objectToMap(),
                      randomPatientMap,
                    ),
                    true,
                  );
                },
              );

              test(
                "Test for a pid that doesn't exist in the database",
                () async {
                  // * A random pid that doesn't exist in the database
                  String randomPID = Uuid().v1();

                  // * Invoke the [getPatientByPID()] method to search for the [randomPID]
                  Patient? patient = await patientsRepo.getPatientByPID(
                    pid: randomPID,
                  );

                  // ! No patient must be found
                  expect(
                    patient,
                    isNull,
                  );
                },
              );
            },
          );

          group(
            'Test [getPatientByName()] method',
            () {
              setUp(() async {
                await initializeMockData();
              });

              test(
                "Test for a name that exists in the database",
                () async {
                  // * Fetch a random name from the [mockData] map
                  int randomPatientIndex =
                      Random().nextInt(mockPatientsData.keys.length);
                  String randomPatientName = mockPatientsData[
                          mockPatientsData.keys.elementAt(randomPatientIndex)]
                      ['name'];

                  // * Check count of the exisitence of [randomAge] in the [mockPatientsData]
                  int count = 0;
                  mockPatientsData.forEach((key, value) {
                    if ((value["name"] as String).contains(randomPatientName))
                      count++;
                  });

                  // * Invoke the [getPatientByName()] method to search for the [randomPatientName]
                  List<Patient>? patients = await patientsRepo.getPatientByName(
                      name: randomPatientName);

                  if (patients == null)
                    throw TestFailure(
                      'Test failed because no patients by the name $randomPatientName were found',
                    );

                  // ! The count of the number of patients obtained as a result of the [getPatientByName()] method invocation must be the same as the count that was locally computed on the [mockPatientsData]
                  expect(
                    patients.length,
                    count,
                  );

                  // ! Each patient's name in the [patients] list must contain the [randomPatientName] substring
                  patients.forEach((patient) {
                    expect(
                      patient.name.contains(randomPatientName),
                      true,
                    );
                  });
                },
              );

              test(
                "Test for a name that doesn't exist in the database",
                () async {
                  // * A random name that doesn't exist in the database
                  String randomPatientName = "Monkey D Luffy";

                  // * Invoke the [getPatientByName()] method to search for the [randomPatientName]
                  List<Patient>? patients = await patientsRepo.getPatientByName(
                      name: randomPatientName);

                  // ! No patient must be found
                  expect(
                    patients,
                    isNull,
                  );
                },
              );
            },
          );
          group(
            'Test [getPatientByAge()] method',
            () {
              setUp(() async {
                await initializeMockData();
              });

              test(
                "Test for an age that exists in the database ",
                () async {
                  int randomAge = 21;

                  // * Check count of the exisitence of [randomAge] in the [mockPatientsData]
                  int count = 0;
                  mockPatientsData.forEach((key, value) {
                    if (value["age"] != null && value["age"] == 21) count++;
                  });

                  // * Invoke the [getPatientByAge()] method to search for the [randomAge]
                  List<Patient>? patients =
                      await patientsRepo.getPatientByAge(age: randomAge);

                  if (patients == null)
                    throw TestFailure(
                      'Test failed because no patients of age $randomAge were found',
                    );

                  // ! The length of the [patients] list must be at least 1
                  // ? (at least 1 ) because there can be multiple patients with the same age
                  expect(
                    patients.length >= 1,
                    true,
                  );

                  // ! The count of the number of patients obtained as a result of the [getPatientByAge()] method invocation must be the same as the count that was locally computed on the [mockPatientsData]
                  expect(
                    patients.length,
                    count,
                  );

                  // ! Each patient's age in the [patients] list must be equal to [randomAge]
                  patients.forEach((patient) {
                    expect(
                      patient.age,
                      randomAge,
                    );
                  });
                },
              );

              test(
                "Test method for an age that doesn't exist in the database ",
                () async {
                  // * This age doesn't exist because the range of age used during mock data generation was 15-30
                  int randomAge = 1;

                  // * Invoke the [getPatientByAge()] method to search for the [randomAge]
                  List<Patient>? patients =
                      await patientsRepo.getPatientByAge(age: randomAge);

                  // ! No patient must be found
                  expect(
                    patients,
                    isNull,
                  );
                },
              );
            },
          );
          group(
            'Test [getPatientByGender()] method',
            () {
              setUp(() async {
                await initializeMockData();
              });

              test(
                "Test for a gender that exists in the database ",
                () async {
                  Gender randomGender = Gender.Male;

                  // * Check count of the exisitence of [randomGender] in the [mockPatientsData]
                  int count = 0;
                  mockPatientsData.forEach((key, value) {
                    if (value["gender"] == Gender.Male.enumToString()) count++;
                  });

                  // * Invoke the [getPatientByGender()] method to search for the [randomAge]
                  List<Patient>? patients = await patientsRepo
                      .getPatientByGender(gender: randomGender);

                  if (patients == null)
                    throw TestFailure(
                      'Test failed because no patients of gender $randomGender were found',
                    );

                  // ! The length of the [patients] list must be at least 1
                  // ? (at least 1 ) because there can be multiple patients with the same gender
                  expect(
                    patients.length >= 1,
                    true,
                  );

                  // ! The count of the number of patients obtained as a result of the [getPatientByGender()] method invocation must be the same as the count that was locally computed on the [mockPatientsData]
                  expect(
                    patients.length,
                    count,
                  );

                  // ! Each patient's age in the [patients] list must be equal to [randomAge]
                  patients.forEach((patient) {
                    expect(
                      patient.gender,
                      randomGender,
                    );
                  });
                },
              );

              test(
                "Test for a gender that doesn't exist in the database ",
                () async {
                  // * This gender doesn't exist because the only three genders [Male, Female, Other] were used during mock data generation
                  Gender randomGender = Gender.PreferNotToSay;

                  // * Invoke the [getPatientByAge()] method to search for the [randomAge]
                  List<Patient>? patients = await patientsRepo
                      .getPatientByGender(gender: randomGender);

                  // ! No patient must be found
                  expect(
                    patients,
                    isNull,
                  );
                },
              );
            },
          );
          group(
            'Test [getAllPatients()] method',
            () {
              test(
                "Test for empty database ",
                () async {
                  List<Patient>? patients = await patientsRepo.getAllPatients();

                  // ! Since the database is empty, no data must exist and hence [getAllPatients()] must return null
                  expect(patients, isNull);
                },
              );

              test(
                "Test for a database with some mock data ",
                () async {
                  await initializeMockData();

                  List<Patient>? patients = await patientsRepo.getAllPatients();

                  if (patients == null)
                    throw TestFailure(
                      '[getAllPatients()] returned null for a database that is supposed to have records in it',
                    );

                  // ! The database must contain [mockPatientsData.keys.length] number of records since the [mockPatientsData] was used to initalize it
                  expect(patients.length, mockPatientsData.keys.length);

                  // ! The content from the database must match the [mockPatientsData]
                  patients.forEach(
                    (patient) {
                      expect(
                        DeepCollectionEquality.unordered().equals(
                          patient.objectToMap(),
                          mockPatientsData[patient.pid],
                        ),
                        true,
                      );
                    },
                  );
                },
              );
            },
          );
        },
      );

      group(
        "Test UPDATE ♻",
        () {
          group(
            'Test [updatePatient()] method for the only entry in the database',
            () {
              late Patient newPatient;
              setUp(() async {
                newPatient = Patient.create(
                  name: 'Monkey D Luffy',
                  gender: Gender.PreferNotToSay,
                );

                await patientsRepo.createPatient(patient: newPatient);
              });
              test(
                'Update only a single attribute -> "name"',
                () async {
                  final Patient updatedPatient = newPatient.copyWith(
                    name: 'Luffy',
                  );

                  // * Invoke updatePatient() method
                  await patientsRepo.updatePatient(
                    oldPatient: newPatient,
                    updatedPatient: updatedPatient,
                  );

                  // * Fetch the patient record from the db post update
                  final Map<String, dynamic> patientFromDB =
                      await getPatientFromDB(pid: newPatient.pid);

                  // ! The locally created new patient must not match with the patient stored in the database after update
                  expect(
                    DeepCollectionEquality.unordered().equals(
                      newPatient.objectToMap(),
                      patientFromDB,
                    ),
                    false,
                  );

                  // ! The locally updated patient must match the patient stored in the database after update
                  expect(
                    DeepCollectionEquality.unordered().equals(
                      updatedPatient.objectToMap(),
                      patientFromDB,
                    ),
                    true,
                  );
                },
              );
              test(
                'Update only a single attribute -> "age"',
                () async {
                  final Patient updatedPatient = newPatient.copyWith(
                    age: 19,
                  );

                  // * Invoke updatePatient() method
                  await patientsRepo.updatePatient(
                    oldPatient: newPatient,
                    updatedPatient: updatedPatient,
                  );

                  // * Fetch the patient record from the db post update
                  final Map<String, dynamic> patientFromDB =
                      await getPatientFromDB(pid: newPatient.pid);

                  // ! The locally created new patient must not match with the patient stored in the database after update
                  expect(
                    DeepCollectionEquality.unordered().equals(
                      newPatient.objectToMap(),
                      patientFromDB,
                    ),
                    false,
                  );

                  // ! The locally updated patient must match the patient stored in the database after update
                  expect(
                    DeepCollectionEquality.unordered().equals(
                      updatedPatient.objectToMap(),
                      patientFromDB,
                    ),
                    true,
                  );
                },
              );

              test(
                'Update only a single attribute -> "gender"',
                () async {
                  final Patient updatedPatient = newPatient.copyWith(
                    gender: Gender.Male,
                  );

                  // * Invoke updatePatient() method
                  await patientsRepo.updatePatient(
                    oldPatient: newPatient,
                    updatedPatient: updatedPatient,
                  );

                  // * Fetch the patient record from the db post update
                  final Map<String, dynamic> patientFromDB =
                      await getPatientFromDB(pid: newPatient.pid);

                  // ! The locally created new patient must not match with the patient stored in the database after update
                  expect(
                    DeepCollectionEquality.unordered().equals(
                      newPatient.objectToMap(),
                      patientFromDB,
                    ),
                    false,
                  );

                  // ! The locally updated patient must match the patient stored in the database after update
                  expect(
                    DeepCollectionEquality.unordered().equals(
                      updatedPatient.objectToMap(),
                      patientFromDB,
                    ),
                    true,
                  );
                },
              );

              test(
                'Update only a single attribute -> "records"',
                () async {
                  final Patient updatedPatient = newPatient.copyWith(
                    recordReferences: [
                      ...newPatient.recordReferences,
                      Uuid().v1()
                    ],
                  );

                  // * Invoke updatePatient() method
                  await patientsRepo.updatePatient(
                    oldPatient: newPatient,
                    updatedPatient: updatedPatient,
                  );

                  // * Fetch the patient record from the db post update
                  final Map<String, dynamic> patientFromDB =
                      await getPatientFromDB(pid: newPatient.pid);

                  // ! The locally created new patient must not match with the patient stored in the database after update
                  expect(
                    DeepCollectionEquality.unordered().equals(
                      newPatient.objectToMap(),
                      patientFromDB,
                    ),
                    false,
                  );

                  // ! The locally updated patient must match the patient stored in the database after update
                  expect(
                    DeepCollectionEquality.unordered().equals(
                      updatedPatient.objectToMap(),
                      patientFromDB,
                    ),
                    true,
                  );
                },
              );

              test(
                'Update only two attributes -> "name" and "age"',
                () async {
                  final Patient updatedPatient = newPatient.copyWith(
                    name: 'Luffy',
                    age: 19,
                  );

                  // * Invoke updatePatient() method
                  await patientsRepo.updatePatient(
                    oldPatient: newPatient,
                    updatedPatient: updatedPatient,
                  );

                  // * Fetch the patient record from the db post update
                  final Map<String, dynamic> patientFromDB =
                      await getPatientFromDB(pid: newPatient.pid);

                  // ! The locally created new patient must not match with the patient stored in the database after update
                  expect(
                    DeepCollectionEquality.unordered().equals(
                      newPatient.objectToMap(),
                      patientFromDB,
                    ),
                    false,
                  );

                  // ! The locally updated patient must match the patient stored in the database after update
                  expect(
                    DeepCollectionEquality.unordered().equals(
                      updatedPatient.objectToMap(),
                      patientFromDB,
                    ),
                    true,
                  );
                },
              );
            },
          );

          group(
            'Test [updatedPatient()] method for a database populated with mock data',
            () {
              late Patient samplePatient;
              setUp(
                () async {
                  await initializeMockData();

                  // * Fetch a random PID from the [mockData] map
                  String randomPID = mockPatientsData.keys.elementAt(
                      Random().nextInt(mockPatientsData.keys.length));

                  // * Invoke the [getPatientByPID()] method to search for the [randomPID]
                  Patient? patientFromDB =
                      await patientsRepo.getPatientByPID(pid: randomPID);

                  if (patientFromDB == null)
                    throw TestFailure(
                      'Group setup failed failed because no patient with PID $randomPID was found',
                    );

                  samplePatient = patientFromDB;
                },
              );

              test(
                'Update only a single attribute -> "name"',
                () async {
                  // * Create a [Patient] object with the updated attributes
                  final Patient updatedPatient = samplePatient.copyWith(
                    name: 'Luffy',
                  );

                  // * Get all patient records before update and modify the patient record in question
                  Map<String, dynamic> patientRecordsPreUpdate =
                      await getAllPatientsFromDB();
                  patientRecordsPreUpdate[samplePatient.pid] =
                      updatedPatient.objectToMap();

                  // * Invoke [updatePatient()] method
                  await patientsRepo.updatePatient(
                    oldPatient: samplePatient,
                    updatedPatient: updatedPatient,
                  );

                  // * Get all patient records post update
                  Map<String, dynamic> patientRecordsPostUpdate =
                      await getAllPatientsFromDB();

                  // * Get updated patient record from the database
                  Map<String, dynamic> patientFromDB =
                      await getPatientFromDB(pid: samplePatient.pid);

                  // ! The preupdated patient object must not match with the patient stored in the database after update
                  expect(
                    DeepCollectionEquality.unordered().equals(
                      samplePatient.objectToMap(),
                      patientFromDB,
                    ),
                    false,
                  );

                  // ! The locally updated patient must match the patient stored in the database after update
                  expect(
                    DeepCollectionEquality.unordered().equals(
                      updatedPatient.objectToMap(),
                      patientFromDB,
                    ),
                    true,
                  );

                  // ! Locally updated patient collection must match patient collection fetched from the database
                  // ? This extra check is done to make sure that any of the other records don't get updated during the update process
                  expect(
                    DeepCollectionEquality.unordered().equals(
                      patientRecordsPreUpdate,
                      patientRecordsPostUpdate,
                    ),
                    true,
                  );
                },
              );
              test(
                'Update only a single attribute -> "age"',
                () async {
                  final Patient updatedPatient = samplePatient.copyWith(
                    age: 19,
                  );

                  // * Get all patient records before update and modify the patient record in question
                  Map<String, dynamic> patientRecordsPreUpdate =
                      await getAllPatientsFromDB();
                  patientRecordsPreUpdate[samplePatient.pid] =
                      updatedPatient.objectToMap();

                  // * Invoke [updatePatient()] method
                  await patientsRepo.updatePatient(
                    oldPatient: samplePatient,
                    updatedPatient: updatedPatient,
                  );

                  // * Get all patient records post update
                  Map<String, dynamic> patientRecordsPostUpdate =
                      await getAllPatientsFromDB();

                  // * Get updated patient record from the database
                  Map<String, dynamic> patientFromDB =
                      await getPatientFromDB(pid: samplePatient.pid);

                  // ! The preupdated patient object must not match with the patient stored in the database after update
                  expect(
                    DeepCollectionEquality.unordered().equals(
                      samplePatient.objectToMap(),
                      patientFromDB,
                    ),
                    false,
                  );

                  // ! The locally updated patient must match the patient stored in the database after update
                  expect(
                    DeepCollectionEquality.unordered().equals(
                      updatedPatient.objectToMap(),
                      patientFromDB,
                    ),
                    true,
                  );

                  // ! Locally updated patient collection must match patient collection fetched from the database
                  // ? This extra check is done to make sure that any of the other records don't get updated during the update process
                  expect(
                    DeepCollectionEquality.unordered().equals(
                      patientRecordsPreUpdate,
                      patientRecordsPostUpdate,
                    ),
                    true,
                  );
                },
              );

              test(
                'Update only a single attribute -> "gender"',
                () async {
                  final Patient updatedPatient = samplePatient.copyWith(
                    gender: samplePatient.gender == Gender.Male
                        ? Gender.Female
                        : Gender.Male,
                  );

                  // * Get all patient records before update and modify the patient record in question
                  Map<String, dynamic> patientRecordsPreUpdate =
                      await getAllPatientsFromDB();
                  patientRecordsPreUpdate[samplePatient.pid] =
                      updatedPatient.objectToMap();

                  // * Invoke [updatePatient()] method
                  await patientsRepo.updatePatient(
                    oldPatient: samplePatient,
                    updatedPatient: updatedPatient,
                  );

                  // * Get all patient records post update
                  Map<String, dynamic> patientRecordsPostUpdate =
                      await getAllPatientsFromDB();

                  // * Get updated patient record from the database
                  Map<String, dynamic> patientFromDB =
                      await getPatientFromDB(pid: samplePatient.pid);

                  // ! The preupdated patient object must not match with the patient stored in the database after update
                  expect(
                    DeepCollectionEquality.unordered().equals(
                      samplePatient.objectToMap(),
                      patientFromDB,
                    ),
                    false,
                  );

                  // ! The locally updated patient must match the patient stored in the database after update
                  expect(
                    DeepCollectionEquality.unordered().equals(
                      updatedPatient.objectToMap(),
                      patientFromDB,
                    ),
                    true,
                  );

                  // ! Locally updated patient collection must match patient collection fetched from the database
                  // ? This extra check is done to make sure that any of the other records don't get updated during the update process
                  expect(
                    DeepCollectionEquality.unordered().equals(
                      patientRecordsPreUpdate,
                      patientRecordsPostUpdate,
                    ),
                    true,
                  );
                },
              );

              test(
                'Update only a single attribute -> "records"',
                () async {
                  final Patient updatedPatient = samplePatient.copyWith(
                    recordReferences: [
                      ...samplePatient.recordReferences,
                      Uuid().v1()
                    ],
                  );

                  // * Get all patient records before update and modify the patient record in question
                  Map<String, dynamic> patientRecordsPreUpdate =
                      await getAllPatientsFromDB();
                  patientRecordsPreUpdate[samplePatient.pid] =
                      updatedPatient.objectToMap();

                  // * Invoke [updatePatient()] method
                  await patientsRepo.updatePatient(
                    oldPatient: samplePatient,
                    updatedPatient: updatedPatient,
                  );

                  // * Get all patient records post update
                  Map<String, dynamic> patientRecordsPostUpdate =
                      await getAllPatientsFromDB();

                  // * Get updated patient record from the database
                  Map<String, dynamic> patientFromDB =
                      await getPatientFromDB(pid: samplePatient.pid);

                  // ! The preupdated patient object must not match with the patient stored in the database after update
                  expect(
                    DeepCollectionEquality.unordered().equals(
                      samplePatient.objectToMap(),
                      patientFromDB,
                    ),
                    false,
                  );

                  // ! The locally updated patient must match the patient stored in the database after update
                  expect(
                    DeepCollectionEquality.unordered().equals(
                      updatedPatient.objectToMap(),
                      patientFromDB,
                    ),
                    true,
                  );

                  // ! Locally updated patient collection must match patient collection fetched from the database
                  // ? This extra check is done to make sure that any of the other records don't get updated during the update process
                  expect(
                    DeepCollectionEquality.unordered().equals(
                      patientRecordsPreUpdate,
                      patientRecordsPostUpdate,
                    ),
                    true,
                  );
                },
              );

              test(
                'Update only two attributes -> "name" and "age"',
                () async {
                  final Patient updatedPatient = samplePatient.copyWith(
                    name: 'Luffy',
                    age: 19,
                  );

                  // * Get all patient records before update and modify the patient record in question
                  Map<String, dynamic> patientRecordsPreUpdate =
                      await getAllPatientsFromDB();
                  patientRecordsPreUpdate[samplePatient.pid] =
                      updatedPatient.objectToMap();

                  // * Invoke [updatePatient()] method
                  await patientsRepo.updatePatient(
                    oldPatient: samplePatient,
                    updatedPatient: updatedPatient,
                  );

                  // * Get all patient records post update
                  Map<String, dynamic> patientRecordsPostUpdate =
                      await getAllPatientsFromDB();

                  // * Get updated patient record from the database
                  Map<String, dynamic> patientFromDB =
                      await getPatientFromDB(pid: samplePatient.pid);

                  // ! The preupdated patient object must not match with the patient stored in the database after update
                  expect(
                    DeepCollectionEquality.unordered().equals(
                      samplePatient.objectToMap(),
                      patientFromDB,
                    ),
                    false,
                  );

                  // ! The locally updated patient must match the patient stored in the database after update
                  expect(
                    DeepCollectionEquality.unordered().equals(
                      updatedPatient.objectToMap(),
                      patientFromDB,
                    ),
                    true,
                  );

                  // ! Locally updated patient collection must match patient collection fetched from the database
                  // ? This extra check is done to make sure that any of the other records don't get updated during the update process
                  expect(
                    DeepCollectionEquality.unordered().equals(
                      patientRecordsPreUpdate,
                      patientRecordsPostUpdate,
                    ),
                    true,
                  );
                },
              );
            },
          );
        },
      );

      group(
        "Test DELETE 🗑",
        () {
          group(
            'Test [deletePatient()] method',
            () {
              test(
                'When only one record exists in the database',
                () async {
                  // * Create a new patient object
                  final Patient patient = Patient.create(
                    name: 'Monkey D Luffy',
                    gender: Gender.PreferNotToSay,
                  );
                  // * Write patient object to database
                  await patientsRepo.createPatient(patient: patient);

                  // ! Newly written patient object must have been successfully written to the db
                  expect(
                    await patientsStore
                        .record(patient.pid)
                        .exists(patientsDatabase),
                    true,
                  );

                  // * Delete the patient record from the database
                  await patientsRepo.deletePatient(deletedPatient: patient);

                  // ! The patient record [patient] must not exist in the db after invoking [deletePatient()] method
                  expect(
                    await patientsStore
                        .record(patient.pid)
                        .exists(patientsDatabase),
                    false,
                  );
                },
              );

              test(
                'When more than one record exists in the database (initialized with mock data)',
                () async {
                  await initializeMockData();

                  // * Fetch all patient records from the database
                  Map<String, dynamic> allPatientRecordsPreUpdate =
                      await getAllPatientsFromDB();

                  // * Randomly select a patient record
                  String randomPID = mockPatientsData.keys.elementAt(
                    Random().nextInt(
                      mockPatientsData.keys.length,
                    ),
                  );
                  final Patient randomPatient = Patient.mapToObject(
                    recordId: randomPID,
                    patientMap: allPatientRecordsPreUpdate[randomPID],
                  );

                  // ! Randomly selected patient must exist in the db
                  expect(
                    await patientsStore
                        .record(randomPatient.pid)
                        .exists(patientsDatabase),
                    true,
                  );

                  // * Delete the patient record from the database
                  await patientsRepo.deletePatient(
                      deletedPatient: randomPatient);

                  // ! The patient record [patient] must not exist in the db after invoking [deletePatient()] method
                  expect(
                    await patientsStore
                        .record(randomPatient.pid)
                        .exists(patientsDatabase),
                    false,
                  );
                },
              );
            },
          );

          group(
            'Test [emptyPatientsDatabase()] method',
            () {
              setUp(
                () async {
                  await initializeMockData();
                },
              );

              test(
                'Test for a database initialized with mock data',
                () async {
                  // ! Before invoking [emptyPatientsDatabase()] method the patients database must contain [mockPatientsData.keys.length] number of records
                  expect(
                    await patientsStore.count(patientsDatabase),
                    mockPatientsData.keys.length,
                  );

                  // * Invoke [emptyPatientsDatabase()] method
                  await patientsRepo.emptyPatientsDatabase();

                  // ! After invoking [emptyPatientsDatabase()] method the patients database must contain 0 records
                  expect(
                    await patientsStore.count(patientsDatabase),
                    0,
                  );
                },
              );
            },
          );
        },
      );
    },
  );
}
