import 'package:database_repo/records_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final RecordsRepo recordsRepo;

  DashboardBloc({required this.recordsRepo}) : super(LoadingDashboardState());

  @override
  Stream<DashboardState> mapEventToState(DashboardEvent event) async* {
    if (event is LoadDashboardEvent) {
      yield* _mapLoadDashboardEventToState();
    } else if (event is DashboardLoadedEvent) {
      yield DashboardLoadedState(data: event.data);
    }
  }

  Stream<DashboardState> _mapLoadDashboardEventToState() async* {
    yield LoadingDashboardState();

    Map<String, dynamic>? percentFeeWaived =
        await this.recordsRepo.computePercentFeeWaived();
    Map<String, dynamic>? amountTotal =
        await this.recordsRepo.computeAmountTotal();

    add(
      DashboardLoadedEvent(
        data: {
          "percentFeeWaived": percentFeeWaived,
          "amountTotal": amountTotal,
        },
      ),
    );
  }
}
