part of 'records_bloc.dart';

abstract class RecordsState {}

/// Represents the state of loading the record objects from the database
class LoadingRecordsState extends RecordsState {}

/// Represents the state of successful completiong of loading the record objects from the database
class RecordsLoadedState extends RecordsState {
  List<Record>? records;

  RecordsLoadedState({required this.records});
}
