import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:collection/collection.dart';

// ! Third party libraries
import 'package:sembast/sembast.dart' as sembast;
import 'package:sembast/sembast_io.dart' as sembastIO;

// ! File imports
import 'package:database_repo/template_repo.dart';

void main() {
  group('Testing Template Repository 🔨', () {
    late TemplateRepo templateRepo;
    late String databaseFile = 'test.db';
    late sembast.Database templateDatabase;
    late sembast.StoreRef templateStore;

    // ! Setting up the objects required for each test before the start of each test
    setUp(() async {
      await sembastIO.databaseFactoryIo.deleteDatabase(databaseFile);

      templateDatabase =
          await sembastIO.databaseFactoryIo.openDatabase(databaseFile);

      templateStore = sembast.stringMapStoreFactory.store('template');

      templateRepo = TemplateRepo(
        templateDatabase: templateDatabase,
        templateStore: templateStore,
      );
    });

    // ! Closing the database connection and deleting the database file after each test
    tearDown(() async {
      templateDatabase.close();
      await sembastIO.databaseFactoryIo.deleteDatabase(databaseFile);
    });

    group(
      'Test template initalization 🚀',
      () {
        test(
          'Test for template collection before intialization',
          () async {
            // ! Template store must not have any records in it
            expect(await templateStore.count(templateDatabase), 0);
          },
        );

        test(
          'Test the [initializeTemplate()] method for proper template collection initialization',
          () async {
            // * Invoke the [initializeTemplate()] method to initialize the template store with the [baseTemplate]
            await templateRepo.initializeTemplate();

            // ! Number of records in the template must equal to the number of entries in the [baseTemplate]
            expect(
              await templateStore.count(templateDatabase),
              baseTemplate.keys.length,
            );

            // * Fetch tempate from the database using the [database] object
            List<sembast.RecordSnapshot<dynamic, dynamic>> recordSnapshotList =
                await templateStore.find(templateDatabase);
            Map<String, Map<String, dynamic>> templateMap = {};
            recordSnapshotList.forEach((sembast.RecordSnapshot snapshot) {
              templateMap[snapshot.key] = snapshot.value;
            });
            final templateFromDB =
                Template.mapToObject(templateMap: templateMap);

            // * Convert [baseTemplate] into [Template] object
            final baseTemplateObj =
                Template.mapToObject(templateMap: baseTemplate);

            // ! Compare the template stored in the database with the [baseTemplate] for proper initalization
            expect(
              DeepCollectionEquality.unordered().equals(
                templateFromDB.objectToMap(),
                baseTemplateObj.objectToMap(),
              ),
              true,
            );
          },
        );
      },
    );

    group(
      'Test CREATE ➕',
      () {
        setUp(
          () async {
            // * Invoke the [initializeTemplate()] method to initialize the template store with the [baseTemplate]
            await templateRepo.initializeTemplate();
          },
        );

        test(
          'Test [createNewField()] method by adding a new field ("Height") belonging to the "Patient Details" category',
          () async {
            // * Create new field
            final TemplateField newTemplateField = TemplateField(
              fieldName: 'Height',
              category: TemplateFieldCategory.PatientDetails,
              type: TemplateFieldType.Number,
              sequence: 2,
            );

            // ! New field must not exist in the database before invoking [createNewField()] method
            expect(
              await templateStore
                  .record(newTemplateField.fieldKey)
                  .exists(templateDatabase),
              false,
            );

            // * Write the new field to the database using the [createNewField()] method
            await templateRepo.createNewField(newField: newTemplateField);

            // ! New field must exist in the database after invoking [createNewField()] method
            expect(
              await templateStore
                  .record(newTemplateField.fieldKey)
                  .exists(templateDatabase),
              true,
            );

            // * Fetch the newly created field from the database
            final TemplateField storedTemplate = TemplateField.mapToObject(
              templateFieldMap: await templateStore
                  .record(newTemplateField.fieldKey)
                  .get(templateDatabase) as Map<String, dynamic>,
            );

            // ! The field inserted into the database must match the field created locally
            expect(
              DeepCollectionEquality.unordered().equals(
                newTemplateField.objectToMap(),
                storedTemplate.objectToMap(),
              ),
              true,
            );
          },
        );

        test(
          'Test [createNewField()] method by adding a new field ("Surgeon Name") belonging to the "Procedure Details" category',
          () async {
            // * Create new field
            final TemplateField newTemplateField = TemplateField(
              fieldName: 'Surgeon Name',
              category: TemplateFieldCategory.ProcedureDetails,
              type: TemplateFieldType.String,
              sequence: 10,
            );

            // ! New field must not exist in the database before invoking [createNewField()] method
            expect(
              await templateStore
                  .record(newTemplateField.fieldKey)
                  .exists(templateDatabase),
              false,
            );

            // * Write the new field to the database using the [createNewField()] method
            await templateRepo.createNewField(newField: newTemplateField);

            // ! New field must exist in the database after invoking [createNewField()] method
            expect(
              await templateStore
                  .record(newTemplateField.fieldKey)
                  .exists(templateDatabase),
              true,
            );

            // * Fetch the newly created field from the database
            final TemplateField storedTemplate = TemplateField.mapToObject(
              templateFieldMap: await templateStore
                  .record(newTemplateField.fieldKey)
                  .get(templateDatabase) as Map<String, dynamic>,
            );

            // ! The field inserted into the database must match the field created locally
            expect(
              DeepCollectionEquality.unordered().equals(
                newTemplateField.objectToMap(),
                storedTemplate.objectToMap(),
              ),
              true,
            );
          },
        );
      },
    );

    group(
      'Test READ 📖',
      () {
        setUp(
          () async {
            // * Invoke the [initializeTemplate()] method to initialize the template store with the [baseTemplate]
            await templateRepo.initializeTemplate();
          },
        );

        test(
          'Test if [readTemplate()] method returns a template that matches the base template after template collection initialization',
          () async {
            // * Converting the [baseTemplate] into a [Template] object
            final Template baseTemplateObject = Template.mapToObject(
              templateMap: baseTemplate,
            );

            // * Fetching the template stored in the DB using the [readTemplate()] method
            final Template templateFromDB = await templateRepo.readTemplate();

            // ! Compare the template stored in the database fetched via [readTemplate()] method with the [baseTemplate]
            expect(
              DeepCollectionEquality.unordered().equals(
                templateFromDB.objectToMap(),
                baseTemplateObject.objectToMap(),
              ),
              true,
            );
          },
        );

        test(
          'Test [readTemplate()] method after deletion of the only field ("patientType") belonging to the "Patient Details" category',
          () async {
            // * Read the "patientType" field from the database
            final TemplateField deletedField = TemplateField.mapToObject(
              templateFieldMap: await templateStore
                  .record('patientType')
                  .get(templateDatabase) as Map<String, dynamic>,
            );

            // * Invoked the [deleteField()] method for the mandatory field "patientType"
            await templateRepo.deleteField(deletedField: deletedField);

            final Map<String, dynamic> updatedBaseTemplate =
                json.decode(json.encode(baseTemplate));
            updatedBaseTemplate.remove('patientType');

            // * Converting the [updatedBaseTemplate] into a [Template] object
            final Template baseTemplateObject =
                Template.mapToObject(templateMap: updatedBaseTemplate);

            // * Fetching the template stored in the DB using the [readTemplate()] method
            final Template templateFromDB = await templateRepo.readTemplate();

            // ! Compare the template stored in the database fetched via [readTemplate()] method with the [baseTemplate]
            expect(
              DeepCollectionEquality.unordered().equals(
                templateFromDB.objectToMap(),
                baseTemplateObject.objectToMap(),
              ),
              true,
            );
          },
        );

        test(
          'Test [readTemplate()] method after deletion of the a field ("wardVisit") belonging to the "Procedure Details" category',
          () async {
            // * Read the "wardVisit" field from the database
            final TemplateField deletedField = TemplateField.mapToObject(
              templateFieldMap: await templateStore
                  .record('wardVisit')
                  .get(templateDatabase) as Map<String, dynamic>,
            );

            // * Invoked the [deleteField()] method for the mandatory field "wardVisit"
            await templateRepo.deleteField(deletedField: deletedField);

            Map<String, dynamic> updatedBaseTemplate =
                json.decode(json.encode(baseTemplate));
            updatedBaseTemplate.remove('wardVisit');

            // * Reorder field sequence after deletion
            updatedBaseTemplate = updatedBaseTemplate.map((key, value) {
              if (value['sequence'] > deletedField.sequence) {
                final updatedValue = {...value as Map<String, dynamic>};
                updatedValue['sequence'] -= 1;
                return MapEntry(key, updatedValue);
              }
              return MapEntry(key, value);
            });

            // * Converting the [updatedBaseTemplate] into a [Template] object
            final Template baseTemplateObject =
                Template.mapToObject(templateMap: updatedBaseTemplate);

            // * Fetching the template stored in the DB using the [readTemplate()] method
            final Template templateFromDB = await templateRepo.readTemplate();

            // ! Compare the template stored in the database fetched via [readTemplate()] method with the [baseTemplate]
            expect(
              DeepCollectionEquality.unordered().equals(
                templateFromDB.objectToMap(),
                baseTemplateObject.objectToMap(),
              ),
              true,
            );
          },
        );

        test(
          'Test [readField()] method for a field that exists',
          () async {
            final String fieldName = "Procedure Code";

            final TemplateField? templateField =
                await templateRepo.readField(fieldName: fieldName);

            // ! The template field will be fetched from the database and hence will not be null
            expect(templateField, isNotNull);
          },
        );

        test(
          'Test [readField()] method for a field that does not exist',
          () async {
            final String fieldName = "Proc Code";

            final TemplateField? templateField =
                await templateRepo.readField(fieldName: fieldName);

            // ! The template field won't be fetched from the database and hence will be null
            expect(templateField, isNull);
          },
        );
      },
    );

    group(
      'Test UPDATE ♻',
      () {
        setUp(
          () async {
            // * Invoke the [initializeTemplate()] method to initialize the template store with the [baseTemplate]
            await templateRepo.initializeTemplate();
          },
        );

        group(
          'Test [updateField()] method ✍ ',
          () {
            test(
              'Change a single attribute -> the "name", of a non-mandatory field ("Ward Visit") (belonging to "Procedure Details") to "Ward Visit Timestamp"',
              () async {
                final TemplateField? oldField = await templateRepo.readField(
                  fieldName: 'Ward Visit',
                );

                if (oldField == null)
                  throw TestFailure(
                    "Tried to read a field that doesn't exist in the database",
                  );

                final TemplateField updatedField =
                    oldField.copyWith(fieldName: "Ward Visit Timestamp");

                // * Invoke the [updateField()] method
                await templateRepo.updateField(
                  oldField: oldField,
                  updatedField: updatedField,
                );

                // * Fetch the version of the field from the database
                final TemplateField? updatedTemplateFromDB =
                    await templateRepo.readField(
                  fieldName: updatedField.fieldName,
                );

                if (updatedTemplateFromDB == null)
                  throw TestFailure(
                    "Tried to read a field that doesn't exist in the database",
                  );

                // ! Locally updated field must match the field freshly fetched from the database after update
                expect(
                  DeepCollectionEquality.unordered().equals(
                      updatedField.objectToMap(),
                      updatedTemplateFromDB.objectToMap()),
                  true,
                );
              },
            );

            test(
              'Change a single attribute -> the "name", of a non-mandatory field ("Patient Type") (belonging to "Patients Details") to "Hopsitalization Type"',
              () async {
                final TemplateField? oldField = await templateRepo.readField(
                  fieldName: 'Patient Type',
                );

                if (oldField == null)
                  throw TestFailure(
                    "Tried to read a field that doesn't exist in the database",
                  );

                final TemplateField updatedField =
                    oldField.copyWith(fieldName: "Hopsitalization Type");

                // * Invoke the [updateField()] method
                await templateRepo.updateField(
                  oldField: oldField,
                  updatedField: updatedField,
                );

                final TemplateField? updatedTemplateFromDB =
                    await templateRepo.readField(
                  fieldName: updatedField.fieldName,
                );

                if (updatedTemplateFromDB == null)
                  throw TestFailure(
                    "Tried to read a field that doesn't exist in the database",
                  );

                // ! Locally updated field must match the field freshly fetched from the database after update
                expect(
                  DeepCollectionEquality.unordered().equals(
                      updatedField.objectToMap(),
                      updatedTemplateFromDB.objectToMap()),
                  true,
                );
              },
            );

            test(
              'Change a single attribute -> the "type", of a non-mandatory field ("Consultation Note") (belonging to "Procedure Details") from "Large Text" to "Number"',
              () async {
                final TemplateField? oldField = await templateRepo.readField(
                  fieldName: 'Consultation Note',
                );

                if (oldField == null)
                  throw TestFailure(
                    "Tried to read a field that doesn't exist in the database",
                  );

                final TemplateField updatedField =
                    oldField.copyWith(type: TemplateFieldType.Number);

                // * Invoke the [updateField()] method
                await templateRepo.updateField(
                  oldField: oldField,
                  updatedField: updatedField,
                );

                final TemplateField? updatedTemplateFromDB =
                    await templateRepo.readField(
                  fieldName: updatedField.fieldName,
                );

                if (updatedTemplateFromDB == null)
                  throw TestFailure(
                    "Tried to read a field that doesn't exist in the database",
                  );

                // ! Locally updated field must match the field freshly fetched from the database after update
                expect(
                  DeepCollectionEquality.unordered().equals(
                      updatedField.objectToMap(),
                      updatedTemplateFromDB.objectToMap()),
                  true,
                );
              },
            );

            test(
              'Change a single attribute -> the "type", of a non-mandatory field ("Patient Type") (belonging to "Patients Details") to "String"',
              () async {
                final TemplateField? oldField = await templateRepo.readField(
                  fieldName: 'Patient Type',
                );

                if (oldField == null)
                  throw TestFailure(
                    "Tried to read a field that doesn't exist in the database",
                  );

                final TemplateField updatedField =
                    oldField.copyWith(type: TemplateFieldType.String);

                // * Invoke the [updateField()] method
                await templateRepo.updateField(
                  oldField: oldField,
                  updatedField: updatedField,
                );

                final TemplateField? updatedTemplateFromDB =
                    await templateRepo.readField(
                  fieldName: updatedField.fieldName,
                );

                if (updatedTemplateFromDB == null)
                  throw TestFailure(
                    "Tried to read a field that doesn't exist in the database",
                  );

                // ! Locally updated field must match the field freshly fetched from the database after update
                expect(
                  DeepCollectionEquality.unordered().equals(
                      updatedField.objectToMap(),
                      updatedTemplateFromDB.objectToMap()),
                  true,
                );
              },
            );

            test(
              'Change a single attribute -> the "category", of a non-mandatory field ("Consultation Note") (belonging to "Procedure Details") from "Procedure Details" to "Patient Details"',
              () async {
                final TemplateField? oldField = await templateRepo.readField(
                  fieldName: 'Consultation Note',
                );

                if (oldField == null)
                  throw TestFailure(
                    "Tried to read a field that doesn't exist in the database",
                  );

                final TemplateField updatedField = oldField.copyWith(
                  category: TemplateFieldCategory.PatientDetails,
                );

                // * Compute the new sequence number of the moved field
                int sequence = 0;
                baseTemplate.forEach((key, value) {
                  if (value['category'] == updatedField.category.enumToString())
                    sequence++;
                });
                sequence++;

                // * Invoke the [updateField()] method
                await templateRepo.updateField(
                  oldField: oldField,
                  updatedField: updatedField,
                );

                final TemplateField? updatedTemplateFromDB =
                    await templateRepo.readField(
                  fieldName: updatedField.fieldName,
                );

                if (updatedTemplateFromDB == null)
                  throw TestFailure(
                    "Tried to read a field that doesn't exist in the database",
                  );

                // ! Locally updated field must match the field freshly fetched from the database after update
                expect(
                  DeepCollectionEquality.unordered().equals(
                      updatedField.copyWith(sequence: sequence).objectToMap(),
                      updatedTemplateFromDB.objectToMap()),
                  true,
                );
              },
            );

            test(
              'Change a single attribute -> the "category", of a non-mandatory field ("Patient Type") (belonging to "Patients Details") from "Patient Details" to "Procedure Details"',
              () async {
                final TemplateField? oldField = await templateRepo.readField(
                  fieldName: 'Patient Type',
                );

                if (oldField == null)
                  throw TestFailure(
                    "Tried to read a field that doesn't exist in the database",
                  );

                final TemplateField updatedField = oldField.copyWith(
                  category: TemplateFieldCategory.ProcedureDetails,
                );

                // * Compute the new sequence number of the moved field
                int sequence = 0;
                baseTemplate.forEach((key, value) {
                  if (value['category'] == updatedField.category.enumToString())
                    sequence++;
                });
                sequence++;

                // * Invoke the [updateField()] method
                await templateRepo.updateField(
                  oldField: oldField,
                  updatedField: updatedField,
                );

                final TemplateField? updatedTemplateFromDB =
                    await templateRepo.readField(
                  fieldName: updatedField.fieldName,
                );

                if (updatedTemplateFromDB == null)
                  throw TestFailure(
                    "Tried to read a field that doesn't exist in the database",
                  );

                // ! Locally updated field must match the field freshly fetched from the database after update
                expect(
                  DeepCollectionEquality.unordered().equals(
                      updatedField.copyWith(sequence: sequence).objectToMap(),
                      updatedTemplateFromDB.objectToMap()),
                  true,
                );
              },
            );

            test(
              'Change two attributes -> the name and type, of a non-mandatory field ("Consultation Note") (belonging to "Procedure Details") to "Notes" and "String" respectively',
              () async {
                final TemplateField? oldField = await templateRepo.readField(
                  fieldName: 'Consultation Note',
                );

                if (oldField == null)
                  throw TestFailure(
                    "Tried to read a field that doesn't exist in the database",
                  );

                final TemplateField updatedField = oldField.copyWith(
                  fieldName: "Notes",
                  type: TemplateFieldType.String,
                );

                // * Invoke the [updateField()] method
                await templateRepo.updateField(
                  oldField: oldField,
                  updatedField: updatedField,
                );

                final TemplateField? updatedTemplateFromDB =
                    await templateRepo.readField(
                  fieldName: updatedField.fieldName,
                );

                if (updatedTemplateFromDB == null)
                  throw TestFailure(
                    "Tried to read a field that doesn't exist in the database",
                  );

                // ! Locally updated field must match the field freshly fetched from the database after update
                expect(
                  DeepCollectionEquality.unordered().equals(
                      updatedField.objectToMap(),
                      updatedTemplateFromDB.objectToMap()),
                  true,
                );
              },
            );

            test(
              'Change two attributes -> the name and type, of a non-mandatory field ("Patient Type") (belonging to "Patients Details") to "Hospitalization Type" and "Number" respectively',
              () async {
                final TemplateField? oldField = await templateRepo.readField(
                  fieldName: 'Patient Type',
                );

                if (oldField == null)
                  throw TestFailure(
                    "Tried to read a field that doesn't exist in the database",
                  );

                final TemplateField updatedField = oldField.copyWith(
                  fieldName: "Hospitalization Type",
                  type: TemplateFieldType.Number,
                );

                // * Invoke the [updateField()] method
                await templateRepo.updateField(
                  oldField: oldField,
                  updatedField: updatedField,
                );

                final TemplateField? updatedTemplateFromDB =
                    await templateRepo.readField(
                  fieldName: updatedField.fieldName,
                );

                if (updatedTemplateFromDB == null)
                  throw TestFailure(
                    "Tried to read a field that doesn't exist in the database",
                  );

                // ! Locally updated field must match the field freshly fetched from the database after update
                expect(
                  DeepCollectionEquality.unordered().equals(
                      updatedField.objectToMap(),
                      updatedTemplateFromDB.objectToMap()),
                  true,
                );
              },
            );

            test(
              'Change two attributes -> the name and category, of a non-mandatory field ("Patient Type") (belonging to "Patients Details") to "Hospitalization Type" and "Procedure Details" respectively',
              () async {
                final TemplateField? oldField = await templateRepo.readField(
                  fieldName: 'Patient Type',
                );

                if (oldField == null)
                  throw TestFailure(
                    "Tried to read a field that doesn't exist in the database",
                  );

                final TemplateField updatedField = oldField.copyWith(
                  fieldName: "Hospitalization Type",
                  category: TemplateFieldCategory.ProcedureDetails,
                );

                // * Invoke the [updateField()] method
                await templateRepo.updateField(
                  oldField: oldField,
                  updatedField: updatedField,
                );

                // * Compute the new sequence number of the moved field
                int sequence = 0;
                baseTemplate.forEach((key, value) {
                  if (value['category'] == updatedField.category.enumToString())
                    sequence++;
                });
                sequence++;

                final TemplateField? updatedTemplateFromDB =
                    await templateRepo.readField(
                  fieldName: updatedField.fieldName,
                );

                if (updatedTemplateFromDB == null)
                  throw TestFailure(
                    "Tried to read a field that doesn't exist in the database",
                  );

                // ! Locally updated field must match the field freshly fetched from the database after update
                expect(
                  DeepCollectionEquality.unordered().equals(
                      updatedField.copyWith(sequence: sequence).objectToMap(),
                      updatedTemplateFromDB.objectToMap()),
                  true,
                );
              },
            );

            test(
              'Change two attributes -> the name and category, of a non-mandatory field ("Ward Visit") (belonging to "Procedure Details") to "Ward Visit Time" and "Patient Details" respectively',
              () async {
                final TemplateField? oldField = await templateRepo.readField(
                  fieldName: 'Ward Visit',
                );

                if (oldField == null)
                  throw TestFailure(
                    "Tried to read a field that doesn't exist in the database",
                  );

                final TemplateField updatedField = oldField.copyWith(
                  fieldName: "Ward Visit Time",
                  category: TemplateFieldCategory.PatientDetails,
                );

                // * Invoke the [updateField()] method
                await templateRepo.updateField(
                  oldField: oldField,
                  updatedField: updatedField,
                );

                // * Compute the new sequence number of the moved field
                int sequence = 0;
                baseTemplate.forEach((key, value) {
                  if (value['category'] == updatedField.category.enumToString())
                    sequence++;
                });
                sequence++;

                final TemplateField? updatedTemplateFromDB =
                    await templateRepo.readField(
                  fieldName: updatedField.fieldName,
                );

                if (updatedTemplateFromDB == null)
                  throw TestFailure(
                    "Tried to read a field that doesn't exist in the database",
                  );

                // ! Locally updated field must match the field freshly fetched from the database after update
                expect(
                  DeepCollectionEquality.unordered().equals(
                      updatedField.copyWith(sequence: sequence).objectToMap(),
                      updatedTemplateFromDB.objectToMap()),
                  true,
                );
              },
            );

            test(
              'Change a single attribute -> the name, of a mandatory field ("Billed Amount")',
              () async {
                final TemplateField? oldField = await templateRepo.readField(
                  fieldName: 'Billed Amount',
                );

                if (oldField == null)
                  throw TestFailure(
                    "Tried to read a field that doesn't exist in the database",
                  );

                final TemplateField updatedField = oldField.copyWith(
                  fieldName: "Amount Billed",
                );

                // * Invoke the [updateField()] method
                await templateRepo.updateField(
                  oldField: oldField,
                  updatedField: updatedField,
                );

                final TemplateField? updatedTemplateFromDB =
                    await templateRepo.readField(
                  fieldName: oldField.fieldName,
                );

                if (updatedTemplateFromDB == null)
                  throw TestFailure(
                    "Tried to read a field that doesn't exist in the database",
                  );

                // ! Locally updated field must not match the field fetched from the database after update because the update will be rejected
                expect(
                  DeepCollectionEquality.unordered().equals(
                      updatedField.objectToMap(),
                      updatedTemplateFromDB.objectToMap()),
                  false,
                );
              },
            );

            test(
              'Change a single attribute -> the type, of a mandatory field ("Procedure Code") from "String" to "Number"',
              () async {
                final TemplateField? oldField = await templateRepo.readField(
                  fieldName: 'Billed Amount',
                );

                if (oldField == null)
                  throw TestFailure(
                    "Tried to read a field that doesn't exist in the database",
                  );

                final TemplateField updatedField = oldField.copyWith(
                  type: TemplateFieldType.Number,
                );

                // * Invoke the [updateField()] method
                await templateRepo.updateField(
                  oldField: oldField,
                  updatedField: updatedField,
                );

                final TemplateField? updatedTemplateFromDB =
                    await templateRepo.readField(
                  fieldName: updatedField.fieldName,
                );

                if (updatedTemplateFromDB == null)
                  throw TestFailure(
                    "Tried to read a field that doesn't exist in the database",
                  );

                // ! Locally updated field must not match the field fetched from the database after update because the update will be rejected
                expect(
                  DeepCollectionEquality.unordered().equals(
                      updatedField.objectToMap(),
                      updatedTemplateFromDB.objectToMap()),
                  false,
                );
              },
            );
          },
        );

        group(
          'Test [reorderField()] method 🔃',
          () {
            Future<Map<String, dynamic>> moveFieldsDown({
              required TemplateFieldCategory category,
              required int oldSequence,
              required int newSequence,
            }) async {
              // * Fetch the entire template from the database before invoking [reorderField()] method
              // * and recompute the sequence number of the fields
              Map<String, dynamic> preReoderTemplateMap =
                  (await templateRepo.readTemplate()).objectToMap();

              preReoderTemplateMap = preReoderTemplateMap.map((key, value) {
                final updatedValue = {...value as Map<String, dynamic>};

                if (value["category"] == category.enumToString()) {
                  if (value["sequence"] == oldSequence) {
                    updatedValue['sequence'] = newSequence;
                  } else if (value["sequence"] > oldSequence &&
                      value["sequence"] <= newSequence) {
                    updatedValue['sequence'] -= 1;
                  }
                }

                return MapEntry(key, updatedValue);
              });
              return preReoderTemplateMap;
            }

            Future<Map<String, dynamic>> moveFieldsUp({
              required TemplateFieldCategory category,
              required int oldSequence,
              required int newSequence,
            }) async {
              // * Fetch the entire template from the database before invoking [reorderField()] method
              // * and recompute the sequence number of the fields
              Map<String, dynamic> preReoderTemplateMap =
                  (await templateRepo.readTemplate()).objectToMap();

              preReoderTemplateMap = preReoderTemplateMap.map((key, value) {
                final updatedValue = {...value as Map<String, dynamic>};

                if (value["category"] == category.enumToString()) {
                  if (value["sequence"] == oldSequence) {
                    updatedValue['sequence'] = newSequence;
                  } else if (value["sequence"] < oldSequence &&
                      value["sequence"] >= newSequence) {
                    updatedValue['sequence'] += 1;
                  }
                }

                return MapEntry(key, updatedValue);
              });

              return preReoderTemplateMap;
            }

            int getLastSequenceNumber({
              required TemplateFieldCategory category,
            }) {
              // * Compute the new sequence number for the updated field
              int sequence = 0;
              baseTemplate.forEach((key, value) {
                if (value['category'] == category.enumToString()) sequence++;
              });
              return sequence;
            }

            test(
              'Move 1st field ("Procedure Name") of "Procedure Details" category to last position',
              () async {
                final TemplateField? oldField =
                    await templateRepo.readField(fieldName: "Procedure Name");

                if (oldField == null)
                  throw TestFailure(
                    "Tried to read a field that doesn't exist in the database",
                  );

                final TemplateField updatedField = oldField.copyWith(
                  sequence: getLastSequenceNumber(category: oldField.category),
                );

                // * Fetch the entire template from the database before invoking [reorderField()] method
                // * and recompute the sequence number of the fields
                Map<String, dynamic> preReoderTemplateMap =
                    await moveFieldsDown(
                  category: updatedField.category,
                  oldSequence: oldField.sequence,
                  newSequence: updatedField.sequence,
                );

                // * Invoke [reorderField()] method
                await templateRepo.reorderField(
                  oldField: oldField,
                  updatedField: updatedField,
                );

                // * Fetch the updated value from the database
                final TemplateField? updatedFieldFromDB =
                    await templateRepo.readField(fieldName: "Procedure Name");

                if (updatedFieldFromDB == null)
                  throw TestFailure(
                    "Tried to read a field that doesn't exist in the database",
                  );

                // * Fetch the entire template from the database after invoking [reorderField()] method
                final postReorderTemplate = await templateRepo.readTemplate();

                // ! Locally updated field must match the field fetched from the database
                expect(
                  DeepCollectionEquality.unordered().equals(
                    updatedField.objectToMap(),
                    updatedFieldFromDB.objectToMap(),
                  ),
                  true,
                );

                // ! Locally updated template must match the template fetched from the database
                expect(
                  DeepCollectionEquality.unordered().equals(
                    preReoderTemplateMap,
                    postReorderTemplate.objectToMap(),
                  ),
                  true,
                );
              },
            );

            test(
              'Move last field ("Consultation Note") of "Procedure Details" category to 1st position',
              () async {
                final TemplateField? oldField = await templateRepo.readField(
                    fieldName: "Consultation Note");

                if (oldField == null)
                  throw TestFailure(
                    "Tried to read a field that doesn't exist in the database",
                  );

                final TemplateField updatedField = oldField.copyWith(
                  sequence: 1,
                );

                // * Fetch the entire template from the database before invoking [reorderField()] method
                // * and recompute the sequence number of the fields
                Map<String, dynamic> preReoderTemplateMap = await moveFieldsUp(
                  category: updatedField.category,
                  oldSequence: oldField.sequence,
                  newSequence: updatedField.sequence,
                );

                // * Invoke [reorderField()] method
                await templateRepo.reorderField(
                  oldField: oldField,
                  updatedField: updatedField,
                );

                // * Fetch the updated value from the database
                final TemplateField? updatedFieldFromDB = await templateRepo
                    .readField(fieldName: "Consultation Note");

                if (updatedFieldFromDB == null)
                  throw TestFailure(
                    "Tried to read a field that doesn't exist in the database",
                  );

                // * Fetch the entire template from the database after invoking [reorderField()] method
                final postReorderTemplate = await templateRepo.readTemplate();

                // ! Locally updated field must match the field fetched from the database
                expect(
                  DeepCollectionEquality.unordered().equals(
                    updatedField.objectToMap(),
                    updatedFieldFromDB.objectToMap(),
                  ),
                  true,
                );

                // ! Locally updated template must match the template fetched from the database
                expect(
                  DeepCollectionEquality.unordered().equals(
                    preReoderTemplateMap,
                    postReorderTemplate.objectToMap(),
                  ),
                  true,
                );
              },
            );

            test(
              'Move 1st field ("Procedure Name") of "Procedure Details" category to middle (5th position)',
              () async {
                final TemplateField? oldField =
                    await templateRepo.readField(fieldName: "Procedure Name");

                if (oldField == null)
                  throw TestFailure(
                    "Tried to read a field that doesn't exist in the database",
                  );

                final TemplateField updatedField = oldField.copyWith(
                  sequence: 5,
                );

                // * Fetch the entire template from the database before invoking [reorderField()] method
                // * and recompute the sequence number of the fields
                Map<String, dynamic> preReoderTemplateMap =
                    await moveFieldsDown(
                  category: updatedField.category,
                  oldSequence: oldField.sequence,
                  newSequence: updatedField.sequence,
                );

                // * Invoke [reorderField()] method
                await templateRepo.reorderField(
                  oldField: oldField,
                  updatedField: updatedField,
                );

                // * Fetch the updated value from the database
                final TemplateField? updatedFieldFromDB =
                    await templateRepo.readField(fieldName: "Procedure Name");

                if (updatedFieldFromDB == null)
                  throw TestFailure(
                    "Tried to read a field that doesn't exist in the database",
                  );

                // * Fetch the entire template from the database after invoking [reorderField()] method
                final postReorderTemplate = await templateRepo.readTemplate();

                // ! Locally updated field must match the field fetched from the database
                expect(
                  DeepCollectionEquality.unordered().equals(
                    updatedField.objectToMap(),
                    updatedFieldFromDB.objectToMap(),
                  ),
                  true,
                );

                // ! Locally updated template must match the template fetched from the database
                expect(
                  DeepCollectionEquality.unordered().equals(
                    preReoderTemplateMap,
                    postReorderTemplate.objectToMap(),
                  ),
                  true,
                );
              },
            );

            test(
              'Move last field ("Consultation Note") of "Procedure Details" category to middle (5th position)',
              () async {
                final TemplateField? oldField = await templateRepo.readField(
                    fieldName: "Consultation Note");

                if (oldField == null)
                  throw TestFailure(
                    "Tried to read a field that doesn't exist in the database",
                  );

                final TemplateField updatedField = oldField.copyWith(
                  sequence: 5,
                );

                // * Fetch the entire template from the database before invoking [reorderField()] method
                // * and recompute the sequence number of the fields
                Map<String, dynamic> preReoderTemplateMap = await moveFieldsUp(
                  category: updatedField.category,
                  oldSequence: oldField.sequence,
                  newSequence: updatedField.sequence,
                );
                // * Invoke [reorderField()] method
                await templateRepo.reorderField(
                  oldField: oldField,
                  updatedField: updatedField,
                );

                // * Fetch the updated value from the database
                final TemplateField? updatedFieldFromDB = await templateRepo
                    .readField(fieldName: "Consultation Note");

                if (updatedFieldFromDB == null)
                  throw TestFailure(
                    "Tried to read a field that doesn't exist in the database",
                  );

                // * Fetch the entire template from the database after invoking [reorderField()] method
                final postReorderTemplate = await templateRepo.readTemplate();

                // ! Locally updated field must match the field fetched from the database
                expect(
                  DeepCollectionEquality.unordered().equals(
                    updatedField.objectToMap(),
                    updatedFieldFromDB.objectToMap(),
                  ),
                  true,
                );

                // ! Locally updated template must match the template fetched from the database
                expect(
                  DeepCollectionEquality.unordered().equals(
                    preReoderTemplateMap,
                    postReorderTemplate.objectToMap(),
                  ),
                  true,
                );
              },
            );

            test(
              'Move middle (5th position) field ("Paid Amount") of "Procedure Details" category to last position',
              () async {
                final TemplateField? oldField =
                    await templateRepo.readField(fieldName: "Paid Amount");

                if (oldField == null)
                  throw TestFailure(
                    "Tried to read a field that doesn't exist in the database",
                  );

                final TemplateField updatedField = oldField.copyWith(
                  sequence: getLastSequenceNumber(category: oldField.category),
                );

                // * Fetch the entire template from the database before invoking [reorderField()] method
                // * and recompute the sequence number of the fields
                Map<String, dynamic> preReoderTemplateMap =
                    await moveFieldsDown(
                  category: updatedField.category,
                  oldSequence: oldField.sequence,
                  newSequence: updatedField.sequence,
                );
                // * Invoke [reorderField()] method
                await templateRepo.reorderField(
                  oldField: oldField,
                  updatedField: updatedField,
                );

                // * Fetch the updated value from the database
                final TemplateField? updatedFieldFromDB =
                    await templateRepo.readField(fieldName: "Paid Amount");

                if (updatedFieldFromDB == null)
                  throw TestFailure(
                    "Tried to read a field that doesn't exist in the database",
                  );

                // * Fetch the entire template from the database after invoking [reorderField()] method
                final postReorderTemplate = await templateRepo.readTemplate();

                // ! Locally updated field must match the field fetched from the database
                expect(
                  DeepCollectionEquality.unordered().equals(
                    updatedField.objectToMap(),
                    updatedFieldFromDB.objectToMap(),
                  ),
                  true,
                );

                // ! Locally updated template must match the template fetched from the database
                expect(
                  DeepCollectionEquality.unordered().equals(
                    preReoderTemplateMap,
                    postReorderTemplate.objectToMap(),
                  ),
                  true,
                );
              },
            );

            test(
              'Move middle (5th position) field ("Paid Amount") of "Procedure Details" category to 1st position',
              () async {
                final TemplateField? oldField =
                    await templateRepo.readField(fieldName: "Paid Amount");

                if (oldField == null)
                  throw TestFailure(
                    "Tried to read a field that doesn't exist in the database",
                  );

                final TemplateField updatedField = oldField.copyWith(
                  sequence: 1,
                );

                // * Fetch the entire template from the database before invoking [reorderField()] method
                // * and recompute the sequence number of the fields
                Map<String, dynamic> preReoderTemplateMap = await moveFieldsUp(
                  category: updatedField.category,
                  oldSequence: oldField.sequence,
                  newSequence: updatedField.sequence,
                );
                // * Invoke [reorderField()] method
                await templateRepo.reorderField(
                  oldField: oldField,
                  updatedField: updatedField,
                );

                // * Fetch the updated value from the database
                final TemplateField? updatedFieldFromDB =
                    await templateRepo.readField(fieldName: "Paid Amount");

                if (updatedFieldFromDB == null)
                  throw TestFailure(
                    "Tried to read a field that doesn't exist in the database",
                  );

                // * Fetch the entire template from the database after invoking [reorderField()] method
                final postReorderTemplate = await templateRepo.readTemplate();

                // ! Locally updated field must match the field fetched from the database
                expect(
                  DeepCollectionEquality.unordered().equals(
                    updatedField.objectToMap(),
                    updatedFieldFromDB.objectToMap(),
                  ),
                  true,
                );

                // ! Locally updated template must match the template fetched from the database
                expect(
                  DeepCollectionEquality.unordered().equals(
                    preReoderTemplateMap,
                    postReorderTemplate.objectToMap(),
                  ),
                  true,
                );
              },
            );

            test(
              'Move 3rd field ("Date of Procedure") of "Procedure Details" category to the 7th position',
              () async {
                final TemplateField? oldField = await templateRepo.readField(
                    fieldName: "Date of Procedure");

                if (oldField == null)
                  throw TestFailure(
                    "Tried to read a field that doesn't exist in the database",
                  );

                final TemplateField updatedField = oldField.copyWith(
                  sequence: 7,
                );

                // * Fetch the entire template from the database before invoking [reorderField()] method
                // * and recompute the sequence number of the fields
                Map<String, dynamic> preReoderTemplateMap =
                    await moveFieldsDown(
                  category: updatedField.category,
                  oldSequence: oldField.sequence,
                  newSequence: updatedField.sequence,
                );
                // * Invoke [reorderField()] method
                await templateRepo.reorderField(
                  oldField: oldField,
                  updatedField: updatedField,
                );

                // * Fetch the updated value from the database
                final TemplateField? updatedFieldFromDB = await templateRepo
                    .readField(fieldName: "Date of Procedure");

                if (updatedFieldFromDB == null)
                  throw TestFailure(
                    "Tried to read a field that doesn't exist in the database",
                  );

                // * Fetch the entire template from the database after invoking [reorderField()] method
                final postReorderTemplate = await templateRepo.readTemplate();

                // ! Locally updated field must match the field fetched from the database
                expect(
                  DeepCollectionEquality.unordered().equals(
                    updatedField.objectToMap(),
                    updatedFieldFromDB.objectToMap(),
                  ),
                  true,
                );

                // ! Locally updated template must match the template fetched from the database
                expect(
                  DeepCollectionEquality.unordered().equals(
                    preReoderTemplateMap,
                    postReorderTemplate.objectToMap(),
                  ),
                  true,
                );
              },
            );

            test(
              'Move 7th field ("Ward Visit") of "Procedure Details" category to 3rd position',
              () async {
                final TemplateField? oldField =
                    await templateRepo.readField(fieldName: "Ward Visit");

                if (oldField == null)
                  throw TestFailure(
                    "Tried to read a field that doesn't exist in the database",
                  );

                final TemplateField updatedField = oldField.copyWith(
                  sequence: 3,
                );

                // * Fetch the entire template from the database before invoking [reorderField()] method
                // * and recompute the sequence number of the fields
                Map<String, dynamic> preReoderTemplateMap = await moveFieldsUp(
                  category: updatedField.category,
                  oldSequence: oldField.sequence,
                  newSequence: updatedField.sequence,
                );
                // * Invoke [reorderField()] method
                await templateRepo.reorderField(
                  oldField: oldField,
                  updatedField: updatedField,
                );

                // * Fetch the updated value from the database
                final TemplateField? updatedFieldFromDB =
                    await templateRepo.readField(fieldName: "Ward Visit");

                if (updatedFieldFromDB == null)
                  throw TestFailure(
                    "Tried to read a field that doesn't exist in the database",
                  );

                // * Fetch the entire template from the database after invoking [reorderField()] method
                final postReorderTemplate = await templateRepo.readTemplate();

                // ! Locally updated field must match the field fetched from the database
                expect(
                  DeepCollectionEquality.unordered().equals(
                    updatedField.objectToMap(),
                    updatedFieldFromDB.objectToMap(),
                  ),
                  true,
                );

                // ! Locally updated template must match the template fetched from the database
                expect(
                  DeepCollectionEquality.unordered().equals(
                    preReoderTemplateMap,
                    postReorderTemplate.objectToMap(),
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
        setUp(
          () async {
            // * Invoke the [initializeTemplate()] method to initialize the template store with the [baseTemplate]
            await templateRepo.initializeTemplate();
          },
        );

        test(
          'Test [deleteField()] method by deleting the only non-mandatory field ("patientType") belonging to the "Patient Details" category',
          () async {
            // * Read the "patientType" field from the database
            final TemplateField deletedField = TemplateField.mapToObject(
              templateFieldMap: await templateStore
                  .record('patientType')
                  .get(templateDatabase) as Map<String, dynamic>,
            );

            // ! The database must contain the "patientType" field before delete
            expect(
              await templateStore
                  .record('patientType')
                  .exists(templateDatabase),
              true,
            );

            // * Invoked the [deleteField()] method for the mandatory field "patientType"
            await templateRepo.deleteField(deletedField: deletedField);

            // ! The database must not contain the "patientType" field after delete
            expect(
              await templateStore
                  .record('patientType')
                  .exists(templateDatabase),
              false,
            );
          },
        );

        test(
          'Test [deleteField()] method by deleting a non-mandatory field ("wardVisit") belonging to the "Procedure Details" category',
          () async {
            // * Read the "wardVisit" field from the database
            final TemplateField deletedField = TemplateField.mapToObject(
              templateFieldMap: await templateStore
                  .record('wardVisit')
                  .get(templateDatabase) as Map<String, dynamic>,
            );

            // ! The database must contain the "wardVisit" field before delete
            expect(
              await templateStore.record('wardVisit').exists(templateDatabase),
              true,
            );

            // * Invoked the [deleteField()] method for the mandatory field "wardVisit"
            await templateRepo.deleteField(deletedField: deletedField);

            // ! The database must not contain the "wardVisit" field
            expect(
              await templateStore.record('wardVisit').exists(templateDatabase),
              false,
            );
          },
        );

        test(
          'Test [deleteField()] method by deleting a mandtory field ("billedAmount") belonging to the "Procedure Details" category',
          () async {
            // * Read the "billedAmount" field from the database
            final TemplateField deletedField = TemplateField.mapToObject(
              templateFieldMap: await templateStore
                  .record('billedAmount')
                  .get(templateDatabase) as Map<String, dynamic>,
            );

            // * Invoked the [deleteField()] method for the mandatory field "billedAmount"
            await templateRepo.deleteField(deletedField: deletedField);

            // ! The database must still contain the "billedAmount" field because a mandatory field cannot be deleted
            expect(
              await templateStore
                  .record('billedAmount')
                  .exists(templateDatabase),
              true,
            );
          },
        );
      },
    );
  });
}
