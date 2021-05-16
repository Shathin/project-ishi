part of 'dashboard_bloc.dart';

// TODO : Add documentation

abstract class DashboardEvent {}

/// Represents the event of loading the dashboard with the data from the database
class LoadDashboardEvent extends DashboardEvent {
  final DateTime? start;
  final DateTime? end;

  LoadDashboardEvent({
    this.start,
    this.end,
  });
}

/// Represents the event of successful completion of loading the dashboard with the data from the database
class DashboardLoadedEvent extends DashboardEvent {
  final Map<String, Map<String, dynamic>?> data;

  DashboardLoadedEvent({required this.data});
}
