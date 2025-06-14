import '../../data/models/budget_model.dart';

abstract class BudgetState {}

class BudgetInitial extends BudgetState {}

class BudgetLoading extends BudgetState {}

class BudgetLoaded extends BudgetState {
  final List<BudgetModel> budgets;
  BudgetLoaded(this.budgets);
}

class BudgetFailure extends BudgetState {
  final String message;
  BudgetFailure(this.message);
}
