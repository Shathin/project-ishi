import 'dart:io';
import 'package:path/path.dart';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart' as foundation;

// ! Custom libraries
import 'package:database_repo/patients_repo.dart';
import 'package:database_repo/records_repo.dart';
import 'package:database_repo/template_repo.dart';

class SpreadsheetGenerator {
  final TemplateRepo templateRepo;
  final RecordsRepo recordsRepo;
  final PatientsRepo patientsRepo;

  SpreadsheetGenerator({
    required this.templateRepo,
    required this.recordsRepo,
    required this.patientsRepo,
  });

  /// Method that generates a spreadsheet for the specified field names
  ///
  /// The data will have the date of procedure field between the range [start, end] if specified
  ///
  /// Method will return with a [false] if no records are found or if any patient corresponding to the record is missing
  Future<bool> generateSpreadsheetForDateRange({
    required List<String> fieldNames,
    DateTime? start,
    DateTime? end,
  }) async {
    print("STARTED generateSpreadsheetForDateRange()");
    if (start == null) start = DateTime(1997);
    if (end == null) end = DateTime.now();

    final Map<String, dynamic> dataMap = {};

    List<Record>? records = await this.recordsRepo.getRecordsBetweenDate(
          start: start,
          end: end,
        );

    if (records == null) return false;

    List<Patient>? patients = [];

    for (Record record in records) {
      Patient? patient = await this.patientsRepo.getPatientByPID(
            pid: record.pid,
          );

      if (patient == null) return false;

      patients.add(patient);
    }

    for (Patient patient in patients) {
      if (dataMap.containsKey(patient.pid)) continue;
      dataMap[patient.pid] = patient.objectToMap();

      Map<String, dynamic> records = {};

      patient.recordReferences.forEach((ref) {
        records[ref] = null;
      });

      dataMap[patient.pid]["records"] = records;
    }

    for (Record record in records) {
      Map<String, dynamic> recordMap = record.objectToMap();

      // * Remove the fields that haven't been selected
      recordMap = Map.fromIterable(
        recordMap.keys.where(
          (key) => fieldNames.contains(key),
        ),
        key: (key) => key,
        value: (key) => recordMap[key],
      );

      dataMap[record.pid]["records"][record.rid] = recordMap;
    }

    // * Remove the rid references from the patient maps that have no corresponding record maps
    // * a [null] means that the record doesn't fall between the selected date range
    for (String pid in dataMap.keys) {
      dataMap[pid]["records"] = Map.fromIterable(
        (dataMap[pid]["records"] as Map<String, dynamic>).keys.where(
              (rid) => dataMap[pid]["records"][rid] != null,
            ),
        key: (key) => key,
        value: (key) => dataMap[pid]["records"][key],
      );
    }

    final Excel excel = Excel.createExcel();
    final Sheet sheet = excel['DATA'];

    // * HEADING
    List<String> heading = ["Patient Name", "Age", "Gender", ...fieldNames];
    sheet.insertRowIterables(heading, 1);

    // * CONTENT
    int row = 3;
    for (String pid in dataMap.keys) {
      List<String> data = [
        dataMap[pid]["name"],
        dataMap[pid]["age"]?.toString() ?? "N/A",
        dataMap[pid]["gender"],
      ];

      for (String rid in dataMap[pid]["records"].keys) {
        List<String> recordData = [...data];

        fieldNames.forEach((fieldName) {
          recordData.add(dataMap[pid]["records"][rid][fieldName].toString());
        });
        sheet.insertRowIterables(recordData, row++);
      }
    }

    // * Save the file
    if (foundation.kIsWeb) {
      // * Web platform
      excel.save(fileName: "ishi-report.xlsx");
    } else if (Platform.isWindows) {
      // * Windows
      var fileBytes = excel.save();
      File('ishi-report.xlsx')
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes ?? []);
    }

    return true;
  }
}
