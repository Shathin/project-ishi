part of 'settings_cubit.dart';

enum SettingsStatus {
  pageLoaded,
  initMockData,
  clearData,
}

class SettingsState {
  final SettingsStatus status;

  SettingsState({this.status = SettingsStatus.pageLoaded});

  /// Invoked either on first page load or after all operations are completed
  SettingsState pageLoaded() =>
      SettingsState(status: SettingsStatus.pageLoaded);

  /// Invoked when the "Initialize Database with Mock Data" operation is requested
  SettingsState initMockData() =>
      SettingsState(status: SettingsStatus.initMockData);

  /// Invoked when the "Clear data" operation is requested
  SettingsState clearData() => SettingsState(status: SettingsStatus.clearData);
}
