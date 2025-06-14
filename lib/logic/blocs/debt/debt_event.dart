import '../../../data/models/debt_model.dart';

abstract class DebtEvent {}

class LoadDebts extends DebtEvent {}

class LoadDueDebts extends DebtEvent {}

class AddDebt extends DebtEvent {
  final DebtModel debt;
  AddDebt(this.debt);
}

class DeleteDebt extends DebtEvent {
  final String id;
  DeleteDebt(this.id);
}
