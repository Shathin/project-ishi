import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:database_repo/records_repo.dart';
import 'package:database_repo/template_repo.dart';

part 'records_event.dart';
part 'records_state.dart';

class RecordsBloc extends Bloc<RecordsEvent, RecordsState> {
  final RecordsRepo recordsRepo;
  final TemplateRepo templateRepo;

  RecordsBloc({
    required this.recordsRepo,
    required this.templateRepo,
  }) : super(LoadingRecordsState());

  @override
  Stream<RecordsState> mapEventToState(RecordsEvent event) async* {
    if (event is LoadAllRecordsEvent) {
      yield* _mapLoadAllRecordsEventToState(event);
    } else if (event is LoadRecordsByKeyValue) {
      yield* _mapLoadRecordsByKeyValueToState(event);
    } else if (event is LoadRecordsBetweenDateRange) {
      yield* _mapLoadRecordsBetweenDateRangeToState(event);
    } else if (event is RecordsLoadedEvent) {
      yield RecordsLoadedState(records: event.records);
    }
  }

  Stream<RecordsState> _mapLoadAllRecordsEventToState(
      LoadAllRecordsEvent event) async* {
    yield LoadingRecordsState();

    List<Record>? records = await this.recordsRepo.getAllRecords(
          sortByDateOfProcedure: event.sortByDateOfProcedure,
        );

    add(RecordsLoadedEvent(records: records));
  }

  Stream<RecordsState> _mapLoadRecordsByKeyValueToState(
      LoadRecordsByKeyValue event) async* {
    yield LoadingRecordsState();

    List<Record>? records = await this.recordsRepo.getRecordsByFieldKeyValue(
          fieldType: event.fieldType,
          fieldKey: event.fieldKey,
          fieldValue: event.fieldValue,
          sortByDateOfProcedure: event.sortByDateOfProcedure,
        );

    add(RecordsLoadedEvent(records: records));
  }

  Stream<RecordsState> _mapLoadRecordsBetweenDateRangeToState(
      LoadRecordsBetweenDateRange event) async* {
    yield LoadingRecordsState();

    List<Record>? records = await this.recordsRepo.getRecordsBetweenDate(
          start: event.start,
          end: event.end,
          sortByDateOfProcedure: event.sortByDateOfProcedure,
        );

    add(RecordsLoadedEvent(records: records));
  }
}
