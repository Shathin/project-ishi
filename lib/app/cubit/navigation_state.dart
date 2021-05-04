part of 'navigation_cubit.dart';

/// Determines which screen is to shown
enum Screen {
  dashboard,
  allRecords,
  addRecord,
  manageTemplate,
  allPatients,
  summary,
  settings
}

class NavigationState {
  final Screen screen;

  NavigationState({this.screen = Screen.dashboard});

  NavigationState dashboard() => NavigationState(screen: Screen.dashboard);
  NavigationState viewAllRecords() =>
      NavigationState(screen: Screen.allRecords);
  NavigationState addRecord() => NavigationState(screen: Screen.addRecord);
  NavigationState manageTemplate() =>
      NavigationState(screen: Screen.manageTemplate);
  NavigationState viewAllPatients() =>
      NavigationState(screen: Screen.allPatients);
  NavigationState generateSummary() => NavigationState(screen: Screen.summary);
  NavigationState settings() => NavigationState(screen: Screen.settings);
}
