// ! Third party libraries
import 'package:database_repo/patients_repo.dart';
import 'package:sembast/sembast.dart';

// ! Models
import './models/models.dart';

// ! Custom libraries
import 'package:database_repo/template_repo.dart';

/// Repository that provides operations associated with the records collection
class RecordsRepo {
  final StoreRef _recordsStore;
  final Database _recordsDatabase;
  final PatientsRepo _patientsRepo;

  RecordsRepo({
    required Database recordsDatabase,
    required StoreRef recordsStore,
    required PatientsRepo patientsRepo,
  })  : this._recordsDatabase = recordsDatabase,
        this._recordsStore = recordsStore,
        this._patientsRepo = patientsRepo;

  /// Getter to obtain the record's [StoreRef] object
  StoreRef get recordsStore => this._recordsStore;

  /// Getter to obtain the record's [Database] object
  Database get recordsDatabase => this._recordsDatabase;

  // * CREATE ===========================================================================

  /// Writes a new record to the database
  Future<void> createRecord({
    required Record record,
  }) async {
    // * Get current patient object from the database
    Patient? patient =
        await this._patientsRepo.getPatientByPID(pid: record.pid);

    // * Reject creating a new record if the patient cannot be found
    if (patient == null) return;

    Patient updatedPatient = patient.copyWith(
      recordReferences: [
        ...patient.recordReferences,
        record.rid,
      ],
    );

    // * Update the patient object in the database to show the new reference to the record object
    await this._patientsRepo.updatePatient(
          oldPatient: patient,
          updatedPatient: updatedPatient,
        );

    // * Write the record object to the database
    await this
        ._recordsStore
        .record(record.rid)
        .add(this._recordsDatabase, record.objectToMap());
  }

  // * READ =============================================================================

  /// Fetches a record by record id
  ///
  /// Returns [null] if none found
  Future<Record?> getRecordByRID({
    required String rid,
  }) async {
    final recordMap = await this
        ._recordsStore
        .record(rid)
        .get(this._recordsDatabase) as Map<String, dynamic>?;

    if (recordMap == null) return null;

    return Record.mapToObject(
      rid: rid,
      recordMap: recordMap,
    );
  }

  /// Fetches a list of records which belong to the patient specified by the patient id
  ///
  /// Optionally, the result can be sorted by the "dateOfProcedure" field
  ///
  /// Returns [null] if none found
  Future<List<Record>?> getRecordsByPID({
    required String pid,
    bool sortByDateOfProcedure = false,
  }) async {
    List<RecordSnapshot> recordSnapshotList = await this._recordsStore.find(
          this._recordsDatabase,
          finder: Finder(
            sortOrders: sortByDateOfProcedure
                ? <SortOrder>[
                    // TODO : Make sure this way of sorting dates works
                    SortOrder('dateOfProcedure'),
                  ]
                : null,
            filter: Filter.matches('pid', pid),
          ),
        );

    if (recordSnapshotList.isEmpty) return null;

    List<Record> recordList = <Record>[];

    recordSnapshotList.forEach((snapshot) {
      recordList.add(Record.mapToObject(
        rid: snapshot.key,
        recordMap: snapshot.value,
      ));
    });

    return recordList;
  }

  /// Fetches a list of records whose "dateOfProcedure" field lies between the [start] and [end] date arguments
  ///
  /// Optionally, the result can be sorted by the "dateOfProcedure" field
  ///
  /// Returns [null] if none found
  Future<List<Record>?> getRecordsBetweenDate({
    required DateTime start,
    required DateTime end,
    bool sortByDateOfProcedure = false,
  }) async {
    List<RecordSnapshot> recordSnapshotList = await this._recordsStore.find(
          this._recordsDatabase,
          finder: Finder(
            sortOrders: sortByDateOfProcedure
                ? <SortOrder>[
                    // TODO : Make sure this way of sorting dates works
                    SortOrder('dateOfProcedure'),
                  ]
                : null,
            filter: Filter.custom((record) {
              DateTime dateOfProcedure = DateTime.parse(
                record["dateOfProcedure"] as String,
              );

              if (dateOfProcedure.isAfter(start) &&
                  dateOfProcedure.isBefore(end))
                return true;
              else
                return false;
            }),
          ),
        );

    if (recordSnapshotList.isEmpty) return null;

    List<Record> recordList = <Record>[];

    recordSnapshotList.forEach((snapshot) {
      recordList.add(Record.mapToObject(
        rid: snapshot.key,
        recordMap: snapshot.value,
      ));
    });

    return recordList;
  }

  /// Fetches a list of records whose field identified by [fieldKey] argument has the value [fieldValue]
  ///
  /// - For the field types [TemplateFieldType.String], [TemplateFieldType.LargeText] and [TemplateFieldType.Media] this method performs a 'contains' type search
  /// - For the field types [TemplateFieldType.Number] and [TemplateFieldType.Money] this method performs a 'greater than or equals to' type search
  /// - For the field type [TemplateFieldType.Choice] this method performs a 'equals' type search
  /// - For the field type [TemplateFieldType.Array] and this method performs a 'inList?' type search
  /// - For the field type [TemplateFieldType.Timestamp] this method invokes the [getRecordsBetweenDate] by passing the [start] as the the input date with the time being the start of the day and the [end] as the input date with the time being the end of day
  ///
  /// Optionally, the result can be sorted by the "dateOfProcedure" field
  ///
  /// Returns [null] if none found
  Future<List<Record>?> getRecordsByFieldKeyValue({
    required TemplateFieldType fieldType,
    required String fieldKey,
    required dynamic fieldValue,
    bool sortByDateOfProcedure = false,
  }) async {
    Filter filter;

    switch (fieldType) {
      case TemplateFieldType.String:
      case TemplateFieldType.LargeText:
      case TemplateFieldType.Media:
        filter = Filter.matches(fieldKey, fieldValue);
        break;
      case TemplateFieldType.Number:
      case TemplateFieldType.Money:
        filter = Filter.greaterThanOrEquals(fieldKey, fieldValue);
        break;
      case TemplateFieldType.Choice:
        filter = Filter.equals(fieldKey, fieldValue);
        break;
      case TemplateFieldType.Array:
        filter = Filter.inList(fieldKey, fieldValue);
        break;
      case TemplateFieldType.Timestamp:
        DateTime inputDate = (fieldValue as DateTime);
        return this.getRecordsBetweenDate(
          start: DateTime(
            inputDate.year,
            inputDate.month,
            inputDate.day,
            0, // hour
            0, // minute
            0, // second
            000, // microseconds
          ),
          end: DateTime(
            inputDate.year,
            inputDate.month,
            inputDate.day,
            23, // hour
            59, // minute
            59, // second
            999, // microseconds
          ),
          sortByDateOfProcedure: sortByDateOfProcedure,
        );
    }

    List<RecordSnapshot> recordSnapshotList = await this._recordsStore.find(
          this._recordsDatabase,
          finder: Finder(
            sortOrders: sortByDateOfProcedure
                ? <SortOrder>[
                    // TODO : Make sure this way of sorting dates works
                    SortOrder('dateOfProcedure'),
                  ]
                : null,
            filter: filter,
          ),
        );

    if (recordSnapshotList.isEmpty) return null;

    List<Record> recordList = <Record>[];

    recordSnapshotList.forEach((snapshot) {
      recordList.add(Record.mapToObject(
        rid: snapshot.key,
        recordMap: snapshot.value,
      ));
    });

    return recordList;
  }

  /// Fetches all the records from the database
  ///
  /// Optionally, the result can be sorted by the "dateOfProcedure" field
  ///
  /// Returns [null] is no records exist
  Future<List<Record>?> getAllRecords({
    bool sortByDateOfProcedure = false,
  }) async {
    List<RecordSnapshot> recordSnapshotList = await this._recordsStore.find(
          this._recordsDatabase,
          finder: Finder(
            sortOrders: sortByDateOfProcedure
                ? <SortOrder>[
                    // TODO : Make sure this way of sorting dates works
                    SortOrder('dateOfProcedure'),
                  ]
                : null,
          ),
        );

    if (recordSnapshotList.isEmpty) return null;

    List<Record> recordList = <Record>[];

    recordSnapshotList.forEach((snapshot) {
      recordList.add(Record.mapToObject(
        rid: snapshot.key,
        recordMap: snapshot.value,
      ));
    });

    return recordList;
  }

  // * UPDATE ===========================================================================

  /// Updates the [oldRecord] record with the [updatedRecord] object supplied to this method as the argument
  Future<void> updateRecord({
    required Record oldRecord,
    required Record updatedRecord,
  }) async {
    await this
        ._recordsStore
        .record(oldRecord.rid)
        .update(this._recordsDatabase, updatedRecord.objectToMap());
  }

  // * DELETE ===========================================================================

  /// Deletes the record passed to this method as the argument
  Future<void> deleteRecord({
    required Record deletedRecord,
  }) async {
    await this
        ._recordsStore
        .record(deletedRecord.rid)
        .delete(this._recordsDatabase);

    // * Get current patient object from the database
    Patient? patient =
        await this._patientsRepo.getPatientByPID(pid: deletedRecord.pid);

    // * Don't bother with updating a patient object if it doesn't exist
    if (patient != null) {
      List<String> updatedRecordReferences = patient.recordReferences;
      updatedRecordReferences.remove(deletedRecord.rid);

      Patient updatedPatient = patient.copyWith(
        recordReferences: updatedRecordReferences,
      );

      // * Update the patient object in the database
      await this._patientsRepo.updatePatient(
            oldPatient: patient,
            updatedPatient: updatedPatient,
          );
    }
  }

  /// Empties the records database
  ///
  /// Use with caution! ⚠
  Future<void> emptyRecordsDatabase() async {
    await this._recordsStore.drop(this._recordsDatabase);
  }

  // * COMPUTE  ===========================================================================

  /// Computes the percentage  of the three fee waived choices i.e., "Yes", "No" and "Partially", that exists in all the records
  ///
  /// Format : {
  ///   "Yes" : .10,
  ///   "No" : .79,
  ///   "Partially": .11,
  ///   "total" : 100
  /// }
  ///
  /// Optionally the [start] and [end] date range can be provided
  /// inorder to compute the data only for the specified range
  ///
  /// Return null if no data exists in the database
  Future<Map<String, double>?> computePercentFeeWaived({
    DateTime? start,
    DateTime? end,
  }) async {
    List<Record>? recordList;

    if (start != null && end != null) {
      // * Both start and end dates were specified
      recordList = await this.getRecordsBetweenDate(
        start: start,
        end: end,
      );
    } else if (start == null && end != null) {
      // * Only the end date was specified
      recordList = await this.getRecordsBetweenDate(
        start: DateTime(1990),
        end: end,
      );
    } else if (start != null && end == null) {
      // * Only the start date was specified
      recordList = await this.getRecordsBetweenDate(
        start: start,
        end: DateTime.now(),
      );
    } else {
      // * Both start and end dates were not specified
      recordList = await this.getAllRecords();
    }

    if (recordList == null) return null;

    double recordCount = recordList.length.toDouble();
    double yesCount = 0;
    double noCount = 0;
    double partiallyCount = 0;

    recordList.forEach((record) {
      if (record.feeWaived == "Yes")
        yesCount++;
      else if (record.feeWaived == "No")
        noCount++;
      else
        partiallyCount++;
    });

    return {
      "Yes": yesCount / recordCount,
      "No": noCount / recordCount,
      "Partially": partiallyCount / recordCount,
      "total": recordCount,
    };
  }

  /// Computes the sum of billed amount and the sum of the paid amount and returns the two sums along with the difference between the two sums
  ///
  /// Format : {
  ///   "totalBilled" : number,
  ///   "totalPaid" : number,
  ///   "totalUnpaidAmount": number,
  ///   "percentageUnpaid": number
  ///   "percentagePaid": number
  /// }
  ///
  /// Optionally the [start] and [end] date range can be provided
  /// inorder to compute the data only for the specified range
  ///
  /// Return null if no data exists in the database
  Future<Map<String, double>?> computeAmountTotal({
    DateTime? start,
    DateTime? end,
  }) async {
    List<Record>? recordList;

    if (start != null && end != null) {
      // * Both start and end dates were specified
      recordList = await this.getRecordsBetweenDate(
        start: start,
        end: end,
      );
    } else if (start == null && end != null) {
      // * Only the end date was specified
      recordList = await this.getRecordsBetweenDate(
        start: DateTime(1990),
        end: end,
      );
    } else if (start != null && end == null) {
      // * Only the start date was specified
      recordList = await this.getRecordsBetweenDate(
        start: start,
        end: DateTime.now(),
      );
    } else {
      // * Both start and end dates were not specified
      recordList = await this.getAllRecords();
    }

    if (recordList == null) return null;

    double totalBilledAmount = 0;
    double totalPaidAmount = 0;
    double totalUnpaidAmount = 0;

    recordList.forEach((record) {
      totalBilledAmount += record.billedAmount;
      totalPaidAmount += record.paidAmount;
    });

    totalUnpaidAmount = totalBilledAmount - totalPaidAmount;

    return {
      "totalBilled": totalBilledAmount,
      "totalPaid": totalPaidAmount,
      "totalUnpaidAmount": totalUnpaidAmount,
      "percentageUnpaid": totalUnpaidAmount / totalBilledAmount,
      "percentagePaid": totalPaidAmount / totalBilledAmount,
    };
  }
}
