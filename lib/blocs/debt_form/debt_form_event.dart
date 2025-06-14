import 'package:equatable/equatable.dart';

abstract class DebtFormEvent extends Equatable {
  const DebtFormEvent();
  @override
  List<Object?> get props => [];
}

class DebtPersonChanged extends DebtFormEvent {
  final String person;
  const DebtPersonChanged(this.person);
  @override
  List<Object?> get props => [person];
}

class DebtAmountChanged extends DebtFormEvent {
  final String amount;
  const DebtAmountChanged(this.amount);
  @override
  List<Object?> get props => [amount];
}

class DebtNoteChanged extends DebtFormEvent {
  final String note;
  const DebtNoteChanged(this.note);
  @override
  List<Object?> get props => [note];
}

class DebtGivenDateChanged extends DebtFormEvent {
  final DateTime givenDate;
  const DebtGivenDateChanged(this.givenDate);
  @override
  List<Object?> get props => [givenDate];
}

class DebtDueDateChanged extends DebtFormEvent {
  final DateTime dueDate;
  const DebtDueDateChanged(this.dueDate);
  @override
  List<Object?> get props => [dueDate];
}

class DebtIsLoanChanged extends DebtFormEvent {
  final bool isLoan;
  const DebtIsLoanChanged(this.isLoan);
  @override
  List<Object?> get props => [isLoan];
}

class DebtFormSubmitted extends DebtFormEvent {
  const DebtFormSubmitted();
}
