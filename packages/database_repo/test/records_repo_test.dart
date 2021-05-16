import 'dart:convert';
import 'dart:math';
import 'package:database_repo/src/template_repo/models/template_field_type.dart';
import 'package:database_repo/utils.dart';
import "package:flutter_test/flutter_test.dart";
import "package:collection/collection.dart";

// ! Third party libraries
import "package:sembast/sembast.dart" as sembast;
import "package:sembast/sembast_io.dart" as sembastIO;

// ! File imports
import "package:database_repo/records_repo.dart";
import "package:database_repo/patients_repo.dart";
import 'package:uuid/uuid.dart';

void main() {
  group(
    'Testing Records Repository 📚',
    () {
      late RecordsRepo recordsRepo;
      late PatientsRepo patientsRepo;

      String recordsDbFile = "records.db";
      String patientsDbFile = "patients.db";

      late sembast.Database recordsDatabase;
      late sembast.Database patientsDatabase;

      late sembast.StoreRef recordsStore;
      late sembast.StoreRef patientsStore;

      late Map<String, Map<String, dynamic>> mockDataMap;
      late Map<String, dynamic> mockPatientsData;
      late Map<String, dynamic> mockRecordsData;

      // ! Setting up the objects required for each test before the start of each test
      setUp(() async {
        await sembastIO.databaseFactoryIo.deleteDatabase(recordsDbFile);
        await sembastIO.databaseFactoryIo.deleteDatabase(patientsDbFile);

        recordsDatabase =
            await sembastIO.databaseFactoryIo.openDatabase(recordsDbFile);
        patientsDatabase =
            await sembastIO.databaseFactoryIo.openDatabase(patientsDbFile);

        recordsStore = sembast.stringMapStoreFactory.store("records");
        patientsStore = sembast.stringMapStoreFactory.store("patients");

        patientsRepo = PatientsRepo(
          patientsDatabase: patientsDatabase,
          patientsStore: patientsStore,
        );

        recordsRepo = RecordsRepo(
          recordsDatabase: recordsDatabase,
          recordsStore: recordsStore,
          patientsRepo: patientsRepo,
        );

        mockDataMap = await MockData.processMockData();

        mockPatientsData = mockDataMap['patients'] ?? {};
        mockRecordsData = mockDataMap['records'] ?? {};
      });

      // ! Closing the database connection and deleting the database file after each test
      tearDown(() async {
        recordsDatabase.close();
        patientsDatabase.close();
        await sembastIO.databaseFactoryIo.deleteDatabase(recordsDbFile);
        await sembastIO.databaseFactoryIo.deleteDatabase(patientsDbFile);
      });

      /// Initialize mock data in the database
      Future<void> initializeMockData() async {
        bool recordsInitStatus = await MockData.initializeMockRecordsData(
          recordsDatabase: recordsDatabase,
          recordsStore: recordsStore,
        );

        if (!recordsInitStatus)
          throw TestFailure(
            'Failure while initalizing mock records data in the database!',
          );

        bool patientsInitStatus = await MockData.initializeMockPatientsData(
          patientsDatabase: patientsDatabase,
          patientsStore: patientsStore,
        );

        if (!patientsInitStatus)
          throw TestFailure(
            'Failure while initalizing mock patients data in the database!',
          );
      }

      /// A method that fetches all the record objects from the database and converts it into a map of the form {rid: record}
      Future<Map<String, dynamic>> getAllRecordsFromDB() async {
        // * Fetch all the patients from the database
        final List<Record>? allRecordsFromDB =
            await recordsRepo.getAllRecords();

        if (allRecordsFromDB == null)
          throw TestFailure(
            'Test failed while fetching all record objects from the database',
          );

        final Map<String, dynamic> allRecordsFromDBMap = {};
        allRecordsFromDB.forEach((record) {
          allRecordsFromDBMap[record.rid] = record.objectToMap();
        });

        return allRecordsFromDBMap;
      }

      /// A method that fetches a the patient record from the database by searching for it using the rid
      Future<Map<String, dynamic>> getRecordFromDB({
        required String rid,
      }) async {
        // * Fetch the patient from the database
        final Record? record = await recordsRepo.getRecordByRID(
          rid: rid,
        );

        if (record == null)
          throw TestFailure(
            'Test failed because no record with RID $rid was found',
          );

        return record.objectToMap();
      }

      group(
        'Test CREATE ➕',
        () {
          late Patient newPatient;
          late Record newRecord;

          setUp(() async {
            newPatient = Patient.create(
              name: 'Monkey D Luffy',
              age: 19,
              gender: Gender.Male,
            );

            // * Write patient object to the database
            await patientsRepo.createPatient(patient: newPatient);

            newRecord = Record.create(
              pid: newPatient.pid,
              procedureCode: 'WANO',
              procedureName: 'Defeat Big Mom and Kaido',
              billedAmount: 1234567,
              paidAmount: 1234567,
              feeWaived: "No",
              dateOfProcedure: DateTime.now(),
              customFields: {
                "patientType": "Out-Patient",
                "wardVisit": [],
                "report": "https://dummyimage.com/287x406.png/dddddd/000000",
                "consultationNote": "Luffy ryuo haki go brr",
              },
            );
          });

          test(
            "Test [createRecord()] method for an empty database",
            () async {
              // ! The locally created record must not exists in the database before invocation of [createRecord()] metho
              expect(
                await recordsStore
                    .record(newRecord.rid)
                    .exists(recordsDatabase),
                false,
              );

              // ! The database must be empty before the invocation of [createRecord()] method
              expect(
                await recordsStore.count(recordsDatabase),
                0,
              );

              // * Invoke the [createRecord()] method
              await recordsRepo.createRecord(record: newRecord);

              // ! The locally created record must now exist in the database after invocation of [createRecord()] metho
              expect(
                await recordsStore
                    .record(newRecord.rid)
                    .exists(recordsDatabase),
                true,
              );

              // ! The locally created record must match with the record object in the database
              expect(
                DeepCollectionEquality.unordered().equals(
                  await recordsStore.record(newRecord.rid).get(recordsDatabase)
                      as Map<String, dynamic>,
                  newRecord.objectToMap(),
                ),
                true,
              );

              // ! The database must contain 1 record after the invocation of [createRecord()] method
              expect(
                await recordsStore.count(recordsDatabase),
                1,
              );
            },
          );

          test(
            'Test [createRecord()] method for a database that already has some records (initalized with mock data)',
            () async {
              await initializeMockData();

              // ! The locally created record must not exists in the database before invocation of [createRecord()] metho
              expect(
                await recordsStore
                    .record(newRecord.rid)
                    .exists(recordsDatabase),
                false,
              );

              // ! The database must contain [mockRecordsData.keys.length] number of records before the invocation of [createRecord()] method
              expect(
                await recordsStore.count(recordsDatabase),
                mockRecordsData.keys.length,
              );

              // * Invoke the [createRecord()] method
              await recordsRepo.createRecord(record: newRecord);

              // ! The locally created record must now exist in the database after invocation of [createRecord()] metho
              expect(
                await recordsStore
                    .record(newRecord.rid)
                    .exists(recordsDatabase),
                true,
              );

              // ! The locally created record must match with the record object in the database
              expect(
                DeepCollectionEquality.unordered().equals(
                  await recordsStore.record(newRecord.rid).get(recordsDatabase)
                      as Map<String, dynamic>,
                  newRecord.objectToMap(),
                ),
                true,
              );

              // ! The database must contain [mockRecordsData.keys.length + 1] number of records before the invocation of [createRecord()] method
              expect(
                await recordsStore.count(recordsDatabase),
                mockRecordsData.keys.length + 1,
              );
            },
          );
        },
      );

      group(
        'Test READ 📖',
        () {
          group(
            'Test [getRecordByRID()]',
            () {
              setUp(
                () async {
                  await initializeMockData();
                },
              );

              test(
                'Test for an RID that exists in the database',
                () async {
                  // * Fetch a random RID from the [mockRecordsData] map
                  String randomRID = mockRecordsData.keys
                      .elementAt(Random().nextInt(mockRecordsData.keys.length));
                  Map<String, dynamic> randomRecordMap =
                      mockRecordsData[randomRID];

                  // * Invoke the [getRecordByRID()] method to search for the [randomRID]
                  Record? record = await recordsRepo.getRecordByRID(
                    rid: randomRID,
                  );

                  if (record == null)
                    throw TestFailure(
                      'Test failed because no record with the RID $randomRID was found',
                    );

                  // ! The record fetched from the database must match the record chosen from the [mockRecordsData] map
                  expect(
                    DeepCollectionEquality.unordered().equals(
                      record.objectToMap(),
                      randomRecordMap,
                    ),
                    true,
                  );
                },
              );

              test(
                "Test for an RID that doesn't exist in the database",
                () async {
                  // * A random rid that doesn't exist in the database
                  String randomRID = Uuid().v1();

                  // * Invoke the [getRecordByRID()] method to search for the [randomRID]
                  Record? record = await recordsRepo.getRecordByRID(
                    rid: randomRID,
                  );

                  // ! No record must be found
                  expect(
                    record,
                    isNull,
                  );
                },
              );
            },
          );

          group(
            'Test [getRecordsByPID()]',
            () {
              setUp(
                () async {
                  await initializeMockData();
                },
              );

              test(
                'Test for a PID that exists in the database',
                () async {
                  // * Fetch a random PID from the [mockPatientData] map
                  String randomPID = mockPatientsData.keys.elementAt(
                      Random().nextInt(mockPatientsData.keys.length));

                  // * Check the count of existence of records having pid as [randomPID] in the [mockRecordsData]
                  int count = 0;
                  mockRecordsData.forEach((key, value) {
                    if (value['pid'] == randomPID) count++;
                  });

                  // * Invoke the [getRecordsByPID()] method to search for the records with pid as randomPID
                  List<Record>? records = await recordsRepo.getRecordsByPID(
                    pid: randomPID,
                  );

                  if (records == null)
                    throw TestFailure(
                      'Test failed because no records having pid as $randomPID were found',
                    );

                  // ! The count of the number of records obtained as a result of the [getRecordsByPID()] method invocation must be the same as the count that was locally computed on the [mockRecordsData]
                  expect(
                    records.length,
                    count,
                  );

                  // ! Each records's PID in the [records] list must have the pid as [randomPID]
                  records.forEach((record) {
                    expect(
                      record.pid.compareTo(randomPID) == 0,
                      true,
                    );
                  });
                },
              );

              test(
                "Test for a PID that doesn't exist in the database",
                () async {
                  // * A random pid that doesn't exist in the database
                  String randomPID = Uuid().v1();

                  // * Invoke the [getRecordByRID()] method to search for the [randomRID]
                  List<Record>? records = await recordsRepo.getRecordsByPID(
                    pid: randomPID,
                  );

                  // ! No records must be found
                  expect(
                    records,
                    isNull,
                  );
                },
              );
            },
          );

          group(
            'Test [getRecordsBetweenDate()]',
            () {
              setUp(
                () async {
                  await initializeMockData();
                },
              );

              test(
                'Test for a date range that contains data in the database',
                () async {
                  // * The date range for the "dateOfProcedure" field used during mock data generation was Dec 1, 2018 - Apr 30, 2021

                  // * The date range used for testing will be Dec 1, 2020 - Mar 30, 2021
                  DateTime start = DateTime(2020, 12, 1);
                  DateTime end = DateTime(2021, 3, 30);

                  // * Check the count of existence of records between the [start] and [end] date in the [mockRecordsData]
                  int count = 0;
                  mockRecordsData.forEach((key, value) {
                    DateTime recordDate = DateTime.parse(
                      value["dateOfProcedure"],
                    );

                    if (recordDate.isAfter(start) && recordDate.isBefore(end))
                      count++;
                  });

                  // * Invoke the [getRecordsBetweenDate()] method to search for the records between [start] and [end]
                  List<Record>? records =
                      await recordsRepo.getRecordsBetweenDate(
                    start: start,
                    end: end,
                  );

                  if (records == null)
                    throw TestFailure(
                      'Test failed because no records were found between the date range $start and $end',
                    );
                  // ! The count of the number of records obtained as a result of the [getRecordsBetweenDate()] method invocation must be the same as the count that was locally computed on the [mockRecordsData]
                  expect(
                    records.length,
                    count,
                  );

                  // ! Each records's "dateOfProcedure" in the [records] list must be between [start] and [end] date
                  records.forEach((record) {
                    expect(
                      record.dateOfProcedure.isAfter(start) &&
                          record.dateOfProcedure.isBefore(end),
                      true,
                    );
                  });
                },
              );

              test(
                "Test for a date range that doesn't contains data in the database",
                () async {
                  // * The date range for the "dateOfProcedure" field used during mock data generation was Dec 1, 2018 - Apr 30, 2021

                  // * The date range used for testing will be Dec 1, 2021 - Mar 30, 2022
                  DateTime start = DateTime(2021, 12, 1);
                  DateTime end = DateTime(2021, 3, 30);

                  // * Invoke the [getRecordsBetweenDate()] method to search for the records between [start] and [end]
                  List<Record>? records =
                      await recordsRepo.getRecordsBetweenDate(
                    start: start,
                    end: end,
                  );

                  // ! No records must be found
                  expect(
                    records,
                    isNull,
                  );
                },
              );
            },
          );

          group(
            'Test [getRecordsByFieldKeyValue()]',
            () {
              setUp(
                () async {
                  await initializeMockData();
                },
              );

              group(
                'Test for a {procedureCode: value} pair of type [TemplateFieldType.String]',
                () {
                  test(
                    'Test for when matching data exists in the database',
                    () async {
                      // * Fetch a random record from the [mockPatientData] map
                      String randomRID = mockRecordsData.keys.elementAt(
                          Random().nextInt(mockRecordsData.keys.length));
                      Map<String, dynamic> randomRecordMap =
                          mockRecordsData[randomRID];
                      // * Fetch the "procedureCode" of that record
                      String procedureCode = randomRecordMap["procedureCode"];
                      // * Take only a part of the procedure code -> This is done to emulate the 'contains' type search
                      procedureCode = procedureCode.substring(0, 2);

                      // * Check the count of existence of records having procedure code as [procedureCode] in the [mockRecordsData]
                      int count = 0;
                      mockRecordsData.forEach((key, value) {
                        if ((value['procedureCode'] as String)
                            .contains(procedureCode)) count++;
                      });

                      // * Invoke the [getRecordsByFieldKeyValue()] method to search for the records with "procedureCode" as [procedureCode]
                      List<Record>? records =
                          await recordsRepo.getRecordsByFieldKeyValue(
                        fieldType: TemplateFieldType.String,
                        fieldKey: "procedureCode",
                        fieldValue: procedureCode,
                      );

                      if (records == null)
                        throw TestFailure(
                          'Test failed because no records having procedure code as $procedureCode were found',
                        );

                      // ! The count of the number of records obtained as a result of the [getRecordsByFieldKeyValue()] method invocation must be the same as the count that was locally computed on the [mockRecordsData]
                      expect(
                        records.length,
                        count,
                      );

                      // ! Each records's procedure code in the [records] list must be contain [procedureCode]
                      records.forEach((record) {
                        expect(
                          record.procedureCode.contains(procedureCode),
                          true,
                        );
                      });
                    },
                  );

                  test(
                    "Test for when matching data doesn't exist in the database",
                    () async {
                      // * A procedure code that doesn't exist in the databae
                      String procedureCode = 'Wano';

                      // * Invoke the [getRecordsByFieldKeyValue()] method to search for the records with "procedureCode" as [procedureCode]
                      List<Record>? records =
                          await recordsRepo.getRecordsByFieldKeyValue(
                        fieldType: TemplateFieldType.String,
                        fieldKey: "procedureCode",
                        fieldValue: procedureCode,
                      );

                      // ! No records must be found
                      expect(
                        records,
                        isNull,
                      );
                    },
                  );
                },
              );

              group(
                'Test for a {billedAmount: fieldValue} pair of type [TemplateFieldType.Money]',
                () {
                  test(
                    'Test for when matching data exists in the database',
                    () async {
                      // * Fetch a random record from the [mockPatientData] map
                      String randomRID = mockRecordsData.keys.elementAt(
                          Random().nextInt(mockRecordsData.keys.length));
                      Map<String, dynamic> randomRecordMap =
                          mockRecordsData[randomRID];
                      // * Fetch the "billedAmount" of that record
                      double billedAmount =
                          randomRecordMap["billedAmount"].toDouble();

                      // * Check the count of existence of records having billed amount as less than or equal to [billedAmount] in the [mockRecordsData]
                      int count = 0;
                      mockRecordsData.forEach((key, value) {
                        if (value['billedAmount'].toDouble() >= billedAmount)
                          count++;
                      });

                      // * Invoke the [getRecordsByFieldKeyValue()] method to search for the records with "billedAmount" as [billedAmount]
                      List<Record>? records =
                          await recordsRepo.getRecordsByFieldKeyValue(
                        fieldType: TemplateFieldType.Money,
                        fieldKey: "billedAmount",
                        fieldValue: billedAmount.toString(),
                      );

                      if (records == null)
                        throw TestFailure(
                          'Test failed because no records having billedAmount less than or equal to $billedAmount were found',
                        );

                      // ! The count of the number of records obtained as a result of the [getRecordsByFieldKeyValue()] method invocation must be the same as the count that was locally computed on the [mockRecordsData]
                      expect(
                        records.length,
                        count,
                      );

                      // ! Each records's procedure code in the [records] list must be contain [procedureCode]
                      records.forEach((record) {
                        expect(
                          record.billedAmount >= billedAmount,
                          true,
                        );
                      });
                    },
                  );

                  test(
                    "Test for when matching data doesn't exists in the database",
                    () async {
                      // * The maximum value for the "billedAmount" used during mock data generation was 500000
                      double billedAmount = 600000;

                      // * Invoke the [getRecordsByFieldKeyValue()] method to search for the records with "billedAmount" as [billedAmount]
                      List<Record>? records =
                          await recordsRepo.getRecordsByFieldKeyValue(
                        fieldType: TemplateFieldType.Money,
                        fieldKey: "billedAmount",
                        fieldValue: billedAmount.toString(),
                      );

                      // ! No records must be found
                      expect(
                        records,
                        isNull,
                      );
                    },
                  );
                },
              );

              group(
                'Test for a {feeWaived?: value} pair of type [TemplateFieldType.Choice]',
                () {
                  test(
                    'Test for when matching data exists in the database',
                    () async {
                      // * Fetch a random record from the [mockPatientData] map
                      String randomRID = mockRecordsData.keys.elementAt(
                          Random().nextInt(mockRecordsData.keys.length));
                      Map<String, dynamic> randomRecordMap =
                          mockRecordsData[randomRID];
                      // * Fetch the "feeWaived?" of that record
                      String feeWaived = randomRecordMap["feeWaived?"];

                      // * Check the count of existence of records having fee waived ? equal to [feeWaived] in the [mockRecordsData]
                      int count = 0;
                      mockRecordsData.forEach((key, value) {
                        if ((value['feeWaived?'] as String)
                                .compareTo(feeWaived) ==
                            0) count++;
                      });

                      // * Invoke the [getRecordsByFieldKeyValue()] method to search for the records with "billedAmount" as [billedAmount]
                      List<Record>? records =
                          await recordsRepo.getRecordsByFieldKeyValue(
                        fieldType: TemplateFieldType.Choice,
                        fieldKey: "feeWaived?",
                        fieldValue: feeWaived,
                      );

                      if (records == null)
                        throw TestFailure(
                          'Test failed because no records having feeWaived? as $feeWaived were found',
                        );

                      // ! The count of the number of records obtained as a result of the [getRecordsByFieldKeyValue()] method invocation must be the same as the count that was locally computed on the [mockRecordsData]
                      expect(
                        records.length,
                        count,
                      );

                      // ! Each records's procedure code in the [records] list must be contain [procedureCode]
                      records.forEach((record) {
                        expect(
                          record.feeWaived.compareTo(feeWaived) == 0,
                          true,
                        );
                      });
                    },
                  );

                  test(
                    "Test for when matching data doesn't exists in the database",
                    () async {
                      String feeWaived =
                          "INVALID"; // * Adding an invalid string for fee waived

                      // * Invoke the [getRecordsByFieldKeyValue()] method to search for the records with "billedAmount" as [billedAmount]
                      List<Record>? records =
                          await recordsRepo.getRecordsByFieldKeyValue(
                        fieldType: TemplateFieldType.Choice,
                        fieldKey: "feeWaived?",
                        fieldValue: feeWaived,
                      );

                      // ! No records must be found
                      expect(
                        records,
                        isNull,
                      );
                    },
                  );
                },
              );

              group(
                'Test for a {dateOfProcedure: value} pair of type [TemplateFieldType.Timestamp]',
                () {
                  test(
                    'Test for when matching data exists in the database',
                    () async {
                      // * Fetch a random record from the [mockPatientData] map
                      String randomRID = mockRecordsData.keys.elementAt(
                          Random().nextInt(mockRecordsData.keys.length));
                      Map<String, dynamic> randomRecordMap =
                          mockRecordsData[randomRID];
                      // * Fetch the "dateOfProcedure" of that record
                      DateTime dateOfProcedure =
                          DateTime.parse(randomRecordMap["dateOfProcedure"]);
                      DateTime start = DateTime(
                        dateOfProcedure.year,
                        dateOfProcedure.month,
                        dateOfProcedure.day,
                        0,
                        0,
                        0,
                        000,
                      );
                      DateTime end = DateTime(
                        dateOfProcedure.year,
                        dateOfProcedure.month,
                        dateOfProcedure.day,
                        23,
                        59,
                        59,
                        999,
                      );

                      // * Check the count of existence of records having date of procedure on [dateOfProcedure] in the [mockRecordsData]
                      int count = 0;
                      mockRecordsData.forEach((key, value) {
                        DateTime val = DateTime.parse(value["dateOfProcedure"]);
                        if (val.isAfter(start) && val.isBefore(end)) count++;
                      });

                      // * Invoke the [dateOfProcedure()] method to search for the records with "dateOfProcedure" as [billedAmount]
                      List<Record>? records =
                          await recordsRepo.getRecordsByFieldKeyValue(
                        fieldType: TemplateFieldType.Timestamp,
                        fieldKey: "dateOfProcedure",
                        fieldValue: dateOfProcedure,
                      );

                      if (records == null)
                        throw TestFailure(
                          'Test failed because no records having dateOfProcedure on $dateOfProcedure were found',
                        );

                      // ! The count of the number of records obtained as a result of the [getRecordsByFieldKeyValue()] method invocation must be the same as the count that was locally computed on the [mockRecordsData]
                      expect(
                        records.length,
                        count,
                      );

                      // ! Each records's procedure code in the [records] list must be contain [procedureCode]
                      records.forEach((record) {
                        expect(
                          record.dateOfProcedure.isAfter(start) &&
                              record.dateOfProcedure.isBefore(end),
                          true,
                        );
                      });
                    },
                  );

                  test(
                    "Test for when matching data doesn't exists in the database",
                    () async {
                      // * The date range for the "dateOfProcedure" field used during mock data generation was Dec 1, 2018 - Apr 30, 2021

                      // * Setting a date in the year 20205
                      DateTime dateOfProcedure = DateTime(2025);

                      // * Invoke the [dateOfProcedure()] method to search for the records with "dateOfProcedure" as [billedAmount]
                      List<Record>? records =
                          await recordsRepo.getRecordsByFieldKeyValue(
                        fieldType: TemplateFieldType.Timestamp,
                        fieldKey: "dateOfProcedure",
                        fieldValue: dateOfProcedure,
                      );

                      // ! No records must be found
                      expect(
                        records,
                        isNull,
                      );
                    },
                  );
                },
              );
            },
          );

          group(
            'Test [getAllRecords()]',
            () {
              test(
                'Test for empty database',
                () async {
                  List<Record>? records = await recordsRepo.getAllRecords();

                  // ! Since the database is empty, no data must exist and hence [getAllRecords()] must return null
                  expect(records, isNull);
                },
              );

              test(
                "Test for a database with some mock data",
                () async {
                  await initializeMockData();

                  List<Record>? records = await recordsRepo.getAllRecords();

                  if (records == null)
                    throw TestFailure(
                      '[getAllRecords()] returned null for a database that is supposed to have records in it',
                    );

                  // ! The database must contain [mockRecordsData.keys.length] number of records since the [mockRecordsData] was used to initalize it
                  expect(records.length, mockRecordsData.keys.length);

                  // ! The content from the database must match the [mockPatientsData]
                  records.forEach(
                    (record) {
                      expect(
                        DeepCollectionEquality.unordered().equals(
                          record.objectToMap(),
                          mockRecordsData[record.rid],
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
        'Test UPDATE ♻',
        () {
          group(
            'Test [updateRecord()] method for the only entry in the database',
            () {
              late Record sampleRecord;

              setUp(
                () async {
                  sampleRecord = Record.create(
                    pid: Uuid().v1(), // Random ID sinc it is irrelavent
                    procedureCode: 'WANO',
                    procedureName: 'Defeat Big Mom and Kaido',
                    billedAmount: 1234567,
                    paidAmount: 1234567,
                    feeWaived: "No",
                    dateOfProcedure: DateTime.now(),
                    customFields: {
                      "patientType": "Out-Patient",
                      "wardVisit": [],
                      "report":
                          "https://dummyimage.com/287x406.png/dddddd/000000",
                      "consultationNote": "Luffy ryuo haki go brr",
                    },
                  );

                  await recordsStore.record(sampleRecord.rid).add(
                        recordsDatabase,
                        sampleRecord.objectToMap(),
                      );
                },
              );
              test(
                'Update a mandatory field ["procedureName"]',
                () async {
                  Record updatedRecord = sampleRecord.copyWith(
                    procedureName: "Become pirate king",
                  );

                  // * Invoke [updateRecord()] method
                  await recordsRepo.updateRecord(
                    oldRecord: sampleRecord,
                    updatedRecord: updatedRecord,
                  );

                  // * Fetch the record from the db post update
                  final Map<String, dynamic> recordFromDB =
                      await getRecordFromDB(rid: sampleRecord.rid);

                  // ! Locally created sample record must not match with the record stored in the database after update
                  expect(
                    DeepCollectionEquality.unordered().equals(
                      sampleRecord.objectToMap(),
                      recordFromDB,
                    ),
                    false,
                  );

                  // ! Locally updated record must match with the record stored in the database after updated
                  expect(
                    DeepCollectionEquality.unordered().equals(
                      updatedRecord.objectToMap(),
                      recordFromDB,
                    ),
                    true,
                  );
                },
              );

              test(
                'Update a custom field "wardVisit"',
                () async {
                  Map<String, dynamic> customFields =
                      json.decode(json.encode(sampleRecord.customFields));
                  (customFields['wardVisit'] as List)
                      .add(DateTime.now().toIso8601String());

                  Record updatedRecord = sampleRecord.copyWith(
                    customFields: customFields,
                  );

                  // * Invoke [updateRecord()] method
                  await recordsRepo.updateRecord(
                    oldRecord: sampleRecord,
                    updatedRecord: updatedRecord,
                  );

                  // * Fetch the record from the db post update
                  final Map<String, dynamic> recordFromDB =
                      await getRecordFromDB(rid: sampleRecord.rid);

                  // ! Locally created sample record must not match with the record stored in the database after update
                  expect(
                    DeepCollectionEquality.unordered().equals(
                      sampleRecord.objectToMap(),
                      recordFromDB,
                    ),
                    false,
                  );

                  // ! Locally updated record must match with the record stored in the database after updated
                  expect(
                    DeepCollectionEquality.unordered().equals(
                      updatedRecord.objectToMap(),
                      recordFromDB,
                    ),
                    true,
                  );
                },
              );
            },
          );

          group(
            'Test [updateRecord()] method for a database populated with mock data',
            () {
              late Record sampleRecord;
              setUp(() async {
                await initializeMockData();
                // * Fetch a random RID from the [mockRecordsData] map
                String randomRID = mockRecordsData.keys
                    .elementAt(Random().nextInt(mockRecordsData.keys.length));

                // * Invoke the [getRecordByRID()] method to search for the [randomPID]
                Record? recordFromDB =
                    await recordsRepo.getRecordByRID(rid: randomRID);

                if (recordFromDB == null)
                  throw TestFailure(
                    'Group setup failed failed because no record with RID $randomRID was found',
                  );

                sampleRecord = recordFromDB;
              });

              test(
                'Update a mandatory field ["procedureCode"]',
                () async {
                  Record updatedRecord = sampleRecord.copyWith(
                    procedureCode: "Kaizoku-O",
                  );

                  // * Get all records before update and modify the record in question
                  Map<String, dynamic> recordsPreUpdate =
                      await getAllRecordsFromDB();
                  recordsPreUpdate[sampleRecord.rid] =
                      updatedRecord.objectToMap();

                  // * Invoke [updateRecord()] method
                  await recordsRepo.updateRecord(
                    oldRecord: sampleRecord,
                    updatedRecord: updatedRecord,
                  );

                  // * Fetch the record from the db post update
                  final Map<String, dynamic> recordFromDB =
                      await getRecordFromDB(rid: sampleRecord.rid);

                  // * Get all records after update and modify the record in question
                  Map<String, dynamic> recordsPostUpdate =
                      await getAllRecordsFromDB();

                  // ! Locally created sample record must not match with the record stored in the database after update
                  expect(
                    DeepCollectionEquality.unordered().equals(
                      sampleRecord.objectToMap(),
                      recordFromDB,
                    ),
                    false,
                  );

                  // ! Locally updated record must match with the record stored in the database after updated
                  expect(
                    DeepCollectionEquality.unordered().equals(
                      updatedRecord.objectToMap(),
                      recordFromDB,
                    ),
                    true,
                  );

                  // ! Locally updated records collection must match records collection fetched from the database
                  // ? This extra check is done to make sure that any of the other records don't get updated during the update process
                  expect(
                    DeepCollectionEquality.unordered().equals(
                      recordsPreUpdate,
                      recordsPostUpdate,
                    ),
                    true,
                  );
                },
              );

              test(
                'Update a custom field "consultationNote"',
                () async {
                  Map<String, dynamic> customFields =
                      json.decode(json.encode(sampleRecord.customFields));
                  customFields["consultationNote"] =
                      "Zoro has Haoshoku no Haki too!";

                  Record updatedRecord = sampleRecord.copyWith(
                    customFields: customFields,
                  );

                  // * Get all records before update and modify the record in question
                  Map<String, dynamic> recordsPreUpdate =
                      await getAllRecordsFromDB();
                  recordsPreUpdate[sampleRecord.rid] =
                      updatedRecord.objectToMap();

                  // * Invoke [updateRecord()] method
                  await recordsRepo.updateRecord(
                    oldRecord: sampleRecord,
                    updatedRecord: updatedRecord,
                  );

                  // * Fetch the record from the db post update
                  final Map<String, dynamic> recordFromDB =
                      await getRecordFromDB(rid: sampleRecord.rid);

                  // * Get all records after update and modify the record in question
                  Map<String, dynamic> recordsPostUpdate =
                      await getAllRecordsFromDB();

                  // ! Locally created sample record must not match with the record stored in the database after update
                  expect(
                    DeepCollectionEquality.unordered().equals(
                      sampleRecord.objectToMap(),
                      recordFromDB,
                    ),
                    false,
                  );

                  // ! Locally updated record must match with the record stored in the database after updated
                  expect(
                    DeepCollectionEquality.unordered().equals(
                      updatedRecord.objectToMap(),
                      recordFromDB,
                    ),
                    true,
                  );

                  // ! Locally updated records collection must match records collection fetched from the database
                  // ? This extra check is done to make sure that any of the other records don't get updated during the update process
                  expect(
                    DeepCollectionEquality.unordered().equals(
                      recordsPreUpdate,
                      recordsPostUpdate,
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
        'Test DELETE 🗑',
        () {
          group(
            'Test [deleteRecord()] method',
            () {
              test(
                'When there is only one record in the database',
                () async {
                  Patient patient = Patient.create(
                    name: 'Monkey D Luffy',
                    age: 19,
                    gender: Gender.Male,
                  );

                  // * Write patient object to the database
                  await patientsRepo.createPatient(patient: patient);

                  Record record = Record.create(
                    pid: patient.pid,
                    procedureCode: 'WANO',
                    procedureName: 'Defeat Big Mom and Kaido',
                    billedAmount: 1234567,
                    paidAmount: 1234567,
                    feeWaived: "No",
                    dateOfProcedure: DateTime.now(),
                    customFields: {
                      "patientType": "Out-Patient",
                      "wardVisit": [],
                      "report":
                          "https://dummyimage.com/287x406.png/dddddd/000000",
                      "consultationNote": "Luffy ryuo haki go brr",
                    },
                  );

                  // * Write record object to the database
                  await recordsRepo.createRecord(record: record);

                  // ! Newly written record object must exist have been successfully been written to the db
                  expect(
                    await recordsStore
                        .record(record.rid)
                        .exists(recordsDatabase),
                    true,
                  );

                  // ! Newly written patient object must have been successfully written to the db
                  expect(
                    await patientsStore
                        .record(patient.pid)
                        .exists(patientsDatabase),
                    true,
                  );

                  // * Delete the record from the database
                  await recordsRepo.deleteRecord(deletedRecord: record);

                  // ! The record object must not exist in the db after invoking [deletePatient()] method
                  expect(
                    await recordsStore
                        .record(record.rid)
                        .exists(recordsDatabase),
                    false,
                  );
                },
              );

              test(
                'When there is more than one record in the database (initialized with mock data)',
                () async {
                  await initializeMockData();

                  // * Fetch all records from the database pre deletion
                  Map<String, dynamic> recordsPreDelete =
                      await getAllRecordsFromDB();

                  // * Randomly select a record
                  String randomRID = mockRecordsData.keys.elementAt(
                    Random().nextInt(
                      mockRecordsData.keys.length,
                    ),
                  );
                  Record record = Record.mapToObject(
                    rid: randomRID,
                    recordMap: recordsPreDelete[randomRID],
                  );

                  // ! Randomly select record must exist in the db
                  expect(
                    await recordsStore
                        .record(record.rid)
                        .exists(recordsDatabase),
                    true,
                  );

                  // * Delete the record from the database
                  await recordsRepo.deleteRecord(deletedRecord: record);

                  // ! The record object must not exist in the db after invoking [deletePatient()] method
                  expect(
                    await recordsStore
                        .record(record.rid)
                        .exists(recordsDatabase),
                    false,
                  );
                },
              );
            },
          );

          group(
            'Test [emptyRecordsDatabase()] method',
            () {
              setUp(
                () async {
                  await initializeMockData();
                },
              );

              test(
                'Test for a database initialized with mock data',
                () async {
                  // ! Before invoking [emptyRecordsDatabase()] method the records database must contain [mockRecordsData.keys.length] number of records
                  expect(
                    await recordsStore.count(recordsDatabase),
                    mockRecordsData.keys.length,
                  );

                  // * Invoke [emptyPatientsDatabase()] method
                  await recordsRepo.emptyRecordsDatabase();

                  // ! After invoking [emptyRecordsDatabase()] method the records database must contain 0 records
                  expect(
                    await patientsStore.count(recordsDatabase),
                    0,
                  );
                },
              );
            },
          );
        },
      );

      group(
        'Test COMPUTE 🔣',
        () {
          group(
            'Test [computePercentFeeWaived()] method',
            () {
              test(
                'Test for empty database',
                () async {
                  Map<String, double>? percentFeeWaived =
                      await recordsRepo.computePercentFeeWaived();

                  // ! Expect null value from [computePercentFeeWaived()] when there is no data in the db to perform the computation on
                  expect(percentFeeWaived, isNull);
                },
              );

              test(
                'Test for database containing mock data',
                () async {
                  await initializeMockData();

                  double recordCount = mockRecordsData.keys.length.toDouble();
                  double yesCount = 0;
                  double noCount = 0;
                  double partiallyCount = 0;

                  mockRecordsData.forEach((key, record) {
                    if (record["feeWaived?"] == "Yes")
                      yesCount++;
                    else if (record["feeWaived?"] == "No")
                      noCount++;
                    else
                      partiallyCount++;
                  });

                  Map<String, dynamic> result = {
                    "Yes": yesCount / recordCount,
                    "No": noCount / recordCount,
                    "Partially": partiallyCount / recordCount,
                    "total": recordCount,
                  };

                  Map<String, double>? percentFeeWaived =
                      await recordsRepo.computePercentFeeWaived();

                  // ! Locally computed result and result obtained from [computePercentFeeWaived()] must match
                  expect(
                    DeepCollectionEquality.unordered().equals(
                      result,
                      percentFeeWaived,
                    ),
                    true,
                  );
                },
              );
            },
          );

          group(
            'Test [computeAmountTotal()] method',
            () {
              test(
                'Test for empty database',
                () async {
                  Map<String, double>? percentAmount =
                      await recordsRepo.computeAmountTotal();

                  // ! Expect null value from [computePercentFeeWaived()] when there is no data in the db to perform the computation on
                  expect(percentAmount, isNull);
                },
              );

              test(
                'Test for database containing mock data',
                () async {
                  await initializeMockData();

                  double totalBilledAmount = 0;
                  double totalPaidAmount = 0;
                  double totalUnpaidAmount = 0;

                  mockRecordsData.forEach((key, record) {
                    totalBilledAmount += record["billedAmount"];
                    totalPaidAmount += record["paidAmount"];
                  });

                  totalUnpaidAmount = totalBilledAmount - totalPaidAmount;

                  Map<String, dynamic> result = {
                    "totalBilled": totalBilledAmount,
                    "totalPaid": totalPaidAmount,
                    "totalUnpaidAmount": totalUnpaidAmount,
                    "percentageUnpaid": totalUnpaidAmount / totalBilledAmount,
                    "percentagePaid": totalPaidAmount / totalBilledAmount,
                  };

                  Map<String, double>? percentAmount =
                      await recordsRepo.computeAmountTotal();

                  // ! Locally computed result and result obtained from [computePercentFeeWaived()] must match
                  expect(
                    DeepCollectionEquality.unordered().equals(
                      result,
                      percentAmount,
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
}
