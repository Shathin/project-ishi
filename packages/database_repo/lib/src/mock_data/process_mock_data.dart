import 'dart:convert';
import 'dart:io';

import 'mock_data.dart';

/// A method that processes the [mockData] and splits it into patient and record maps.
///
/// Returns a map of the format {'patients': mockPatientData, 'records': mockRecordsData}
///
/// Set [writeToFile] argument if you wish to store the results of this method into two files -> patients.txt and records.txt
Future<Map<String, Map<String, dynamic>>> processMockData({
  bool writeToFile = false,
}) async {
  Map<String, dynamic> patients = {};
  Map<String, dynamic> records = {};

  mockData.forEach((Map<String, dynamic> patientItem) {
    Map<String, dynamic> patient = {};

    patient["name"] = patientItem["name"];
    patient["gender"] = patientItem["gender"];
    if (patientItem["age"] != null) patient["age"] = patientItem["age"];
    patient["records"] = <String>[];

    (patientItem["records"] as List<Map<String, dynamic>>)
        .forEach((recordItem) {
      Map<String, dynamic> record = {};
      record["pid"] = patientItem["patientId"];
      record["patientType"] = recordItem["patientType"];
      record["procedureName"] = recordItem["procedureName"];
      record["procedureCode"] = recordItem["procedureCode"];

      // * This extra step is done in order to sanitize the date
      record["dateOfProcedure"] = DateTime.parse(
        recordItem["dateOfProcedure"],
      ).toIso8601String();

      record["billedAmount"] = recordItem["billedAmount"];
      record["paidAmount"] = recordItem["paidAmount"];
      record["feeWaived?"] = recordItem["feeWaived?"];

      // * This extra step is done in order to sanitize the date
      record["wardVisit"] = (recordItem["wardVisit"] as List<dynamic>)
          .map(
            (item) => DateTime.parse(item).toIso8601String(),
          )
          .toList();

      record["report"] = recordItem["report"];
      record["consultationNote"] = recordItem["consultationNote"];
      records[recordItem["recordId"]] = record;

      (patient["records"] as List<String>).add(recordItem["recordId"]);
    });

    patients[patientItem["patientId"]] = patient;
  });

  if (writeToFile) {
    final patientsFile = File('patients.txt');
    final recordsFile = File('records.txt');

    await patientsFile.writeAsString(json.encode(patients));
    await recordsFile.writeAsString(json.encode(records));
  }

  return {
    "patients": patients,
    "records": records,
  };
}
