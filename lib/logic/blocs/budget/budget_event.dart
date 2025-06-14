import '../../../data/models/budget_model.dart';

abstract class BudgetEvent {}

class LoadBudgets extends BudgetEvent {}

class AddBudget extends BudgetEvent {
  final BudgetModel budget;
  AddBudget(this.budget);
}

class DeleteBudget extends BudgetEvent {
  final String id;
  DeleteBudget(this.id);
}
