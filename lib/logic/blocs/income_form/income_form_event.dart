import 'package:equatable/equatable.dart';

abstract class IncomeFormEvent extends Equatable {
  const IncomeFormEvent();
  @override
  List<Object?> get props => [];
}

class IncomeTitleChanged extends IncomeFormEvent {
  final String title;
  const IncomeTitleChanged(this.title);
  @override
  List<Object?> get props => [title];
}

class IncomeAmountChanged extends IncomeFormEvent {
  final String amount;
  const IncomeAmountChanged(this.amount);
  @override
  List<Object?> get props => [amount];
}

class IncomeNoteChanged extends IncomeFormEvent {
  final String note;
  const IncomeNoteChanged(this.note);
  @override
  List<Object?> get props => [note];
}

class IncomeDateChanged extends IncomeFormEvent {
  final DateTime date;
  const IncomeDateChanged(this.date);
  @override
  List<Object?> get props => [date];
}

class IncomeFormSubmitted extends IncomeFormEvent {
  const IncomeFormSubmitted();
}
