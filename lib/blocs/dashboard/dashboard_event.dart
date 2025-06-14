abstract class DashboardEvent {}

class LoadUserExpenses extends DashboardEvent {}

class DashboardTabChanged extends DashboardEvent {
  final int index;
  DashboardTabChanged(this.index);
}
