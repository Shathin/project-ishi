part of 'dashboard_bloc.dart';

abstract class DashboardState {}

/// Represents the state of a dashboard that is currently loading the data from the database
///
/// A progress indicator can be show during the loading state
class LoadingDashboardState extends DashboardState {}

/// Represents the state of a dashboard that has completed loading the data from the database
class DashboardLoadedState extends DashboardState {
  Map<String, Map<String, dynamic>?> data;

  DashboardLoadedState({required this.data});
}
