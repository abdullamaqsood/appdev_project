abstract class ExpenseState {}

class ExpenseInitial extends ExpenseState {}

class ExpenseLoading extends ExpenseState {}

class ExpenseSuccess extends ExpenseState {}

class ExpenseFailure extends ExpenseState {
  final String error;
  ExpenseFailure(this.error);
}
