part of 'records_bloc.dart';

abstract class RecordsEvent {}

/// Represents the event of loading the all the record objects from the database
class LoadAllRecordsEvent extends RecordsEvent {
  final bool sortByDateOfProcedure;

  LoadAllRecordsEvent({this.sortByDateOfProcedure = false});
}

/// Represents the event of loading the records by custom fields from the database
class LoadRecordsByKeyValue extends RecordsEvent {
  final TemplateFieldType fieldType;
  final String fieldKey;
  final dynamic fieldValue;
  final bool sortByDateOfProcedure;

  LoadRecordsByKeyValue({
    required this.fieldType,
    required this.fieldKey,
    required this.fieldValue,
    this.sortByDateOfProcedure = false,
  });
}

/// Represents the event of loading the records between a date range by date of procedure field from the database
class LoadRecordsBetweenDateRange extends RecordsEvent {
  final DateTime start;
  final DateTime end;
  final bool sortByDateOfProcedure;

  LoadRecordsBetweenDateRange({
    required this.start,
    required this.end,
    this.sortByDateOfProcedure = false,
  });
}

/// Represents the event of successful loading of the record objects from the database
class RecordsLoadedEvent extends RecordsEvent {
  List<Record>? records;

  RecordsLoadedEvent({required this.records});
}
