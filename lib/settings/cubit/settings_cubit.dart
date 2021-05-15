import 'package:bloc/bloc.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(SettingsState());

  /// Invoked after all the operations are completed
  void operationsComplete() => emit(state.pageLoaded());

  /// Invoked when the "Initialize database with mock data" opeartion is requested
  void operationInitMockData() => emit(state.initMockData());

  /// Invoked when the "Clear Data" operation is requested
  void operationClearData() => emit(state.clearData());
}
