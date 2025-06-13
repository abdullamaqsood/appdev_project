import '../../../data/models/expense_model.dart';
import '../../../data/models/income_model.dart';

abstract class DashboardState {}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final List<ExpenseModel> expenses;
  final List<IncomeModel> incomes;

  DashboardLoaded({
    required this.expenses,
    required this.incomes,
  });
}

class DashboardError extends DashboardState {
  final String message;
  DashboardError(this.message);
}
