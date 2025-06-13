import '../../../data/models/expense_model.dart';

abstract class ExpenseEvent {}

class AddExpenseEvent extends ExpenseEvent {
  final ExpenseModel expense;
  AddExpenseEvent(this.expense);
}
