// ! File imports
import 'package:uuid/uuid.dart';

/// Class that represents a record object
class Record {
  // ! The mandatory fields are expected as to populate the variables of this class
  // ! while the non-mandatory fields will all be stored in a map

  /// Represents the key used to access the patient's record in the database
  final String rid;

  /// Represents the id of the patient who owns this record
  final String pid;

  /// Represents the name of the medical procedure
  final String procedureName;

  /// Represents the code of the medical procedure
  final String procedureCode;

  /// Represents the date when the medical procedure was performed
  final DateTime dateOfProcedure;

  /// Represents the cost of the procedure
  final double billedAmount;

  /// Represents the amount paid by the patient towards the procedure
  final double paidAmount;

  /// Represents the decision of the doctor to waive the fees for the procedure
  ///
  /// Expects either of - "Yes", "No" or "Partially"
  final String feeWaived;

  /// Represents the {"key": "value"} map that contains the values for the user's custom defined fields and pre-baked non-mandatory fields
  final Map<String, dynamic> customFields;

  /// Constructor to instantiate the [Record] class
  Record({
    required this.rid,
    required this.pid,
    required this.procedureCode,
    required this.procedureName,
    required this.dateOfProcedure,
    required this.billedAmount,
    required this.paidAmount,
    required this.feeWaived,
    this.customFields = const <String, dynamic>{},
  });

  /// Use this constructor while creating a new [Record] object
  ///
  /// This constructor auto-generates a new [rid] using the UUID package
  Record.create({
    required this.pid,
    required this.procedureCode,
    required this.procedureName,
    required this.dateOfProcedure,
    required this.billedAmount,
    required this.paidAmount,
    required this.feeWaived,
    this.customFields = const <String, dynamic>{},
  }) : this.rid = Uuid().v1();

  /// Method to convert the [Record] object into a map
  Map<String, dynamic> objectToMap() => {
        "pid": this.pid,
        "procedureCode": this.procedureCode,
        "procedureName": this.procedureName,
        "dateOfProcedure": this.dateOfProcedure.toIso8601String(),
        "billedAmount": this.billedAmount,
        "paidAmount": this.paidAmount,
        "feeWaived?": this.feeWaived,
        ...this.customFields,
      };

  /// Method to convert a map containing the record into a [Record] object
  static Record mapToObject({
    required String rid,
    required Map<String, dynamic> recordMap,
  }) =>
      Record(
        rid: rid,
        pid: recordMap["pid"],
        procedureCode: recordMap["procedureCode"],
        procedureName: recordMap["procedureName"],
        dateOfProcedure: DateTime.parse(recordMap["dateOfProcedure"]),
        billedAmount: (recordMap["billedAmount"]).toDouble(),
        paidAmount: (recordMap["paidAmount"]).toDouble(),
        feeWaived: recordMap["feeWaived?"],
        customFields: Map.fromIterable(
          recordMap.keys.where(
            (key) => ![
              "pid",
              "procedureCode",
              "procedureName",
              "dateOfProcedure",
              "billedAmount",
              "paidAmount",
              "feeWaived?"
            ].contains(key),
          ),
          key: (key) => key,
          value: (key) => recordMap[key],
        ),
      );

  /// Method that returns a copy of the current [Record] object with a specified fields replaced by the arguments passed to this method
  Record copyWith({
    String? procedureName,
    String? procedureCode,
    DateTime? dateOfProcedure,
    double? billedAmount,
    double? paidAmount,
    String? feeWaived,
    Map<String, dynamic>? customFields,
  }) =>
      Record(
        rid: this.rid,
        pid: this.pid,
        procedureCode: procedureCode ?? this.procedureCode,
        procedureName: procedureName ?? this.procedureName,
        dateOfProcedure: dateOfProcedure ?? this.dateOfProcedure,
        billedAmount: billedAmount ?? this.billedAmount,
        paidAmount: paidAmount ?? this.paidAmount,
        feeWaived: feeWaived ?? this.feeWaived,
        customFields: customFields ?? this.customFields,
      );

  @override
  String toString() {
    String recordString = '\n';

    recordString += '${this.rid} : {';
    recordString += '\n\t';

    this.objectToMap().forEach((key, value) {
      recordString += '$key : $value';
      recordString += '\n\t';
    });

    recordString += "\n";
    recordString += "}";

    return recordString;
  }
}
