import '../../data/models/expense_model.dart';
import '../../data/models/income_model.dart';

abstract class DashboardState {
  final int selectedIndex;
  const DashboardState({this.selectedIndex = 0});
}

class DashboardInitial extends DashboardState {
  const DashboardInitial({int selectedIndex = 0})
      : super(selectedIndex: selectedIndex);
}

class DashboardLoading extends DashboardState {
  const DashboardLoading({int selectedIndex = 0})
      : super(selectedIndex: selectedIndex);
}

class DashboardLoaded extends DashboardState {
  final List<ExpenseModel> expenses;
  final List<IncomeModel> incomes;
  const DashboardLoaded({
    required this.expenses,
    required this.incomes,
    int selectedIndex = 0,
  }) : super(selectedIndex: selectedIndex);
}

class DashboardError extends DashboardState {
  final String message;
  const DashboardError(this.message, {int selectedIndex = 0})
      : super(selectedIndex: selectedIndex);
}
