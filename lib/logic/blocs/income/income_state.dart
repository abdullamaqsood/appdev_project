abstract class IncomeState {}

class IncomeInitial extends IncomeState {}

class IncomeLoading extends IncomeState {}

class IncomeSuccess extends IncomeState {}

class IncomeFailure extends IncomeState {
  final String error;
  IncomeFailure(this.error);
}
