import '../../data/models/debt_model.dart';

abstract class DebtState {}

class DebtInitial extends DebtState {}

class DebtLoading extends DebtState {}

class DebtLoaded extends DebtState {
  final List<DebtModel> debts;
  DebtLoaded(this.debts);
}

class DueDebtsLoaded extends DebtState {
  final List<DebtModel> dueDebts;
  DueDebtsLoaded(this.dueDebts);
}

class DebtFailure extends DebtState {
  final String message;
  DebtFailure(this.message);
}
