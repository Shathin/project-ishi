// ! Third party libraries
import 'package:bloc/bloc.dart';

// ! Parts
part 'navigation_state.dart';

class NavigationCubit extends Cubit<NavigationState> {
  NavigationCubit() : super(NavigationState());

  void navigateToDashboard() => emit(state.dashboard());
  void navigateToViewAllRecords() => emit(state.viewAllRecords());
  void navigateToAddRecord() => emit(state.addRecord());
  void navigateToManageTemplate() => emit(state.manageTemplate());
  void navigateToViewAllPatients() => emit(state.viewAllPatients());
  void navigateToGenerateSummary() => emit(state.generateSummary());
  void navigateToSettings() => emit(state.settings());
}
