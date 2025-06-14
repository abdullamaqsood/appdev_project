import 'package:equatable/equatable.dart';

abstract class ExpenseFormEvent extends Equatable {
  const ExpenseFormEvent();
  @override
  List<Object?> get props => [];
}

class ExpenseTitleChanged extends ExpenseFormEvent {
  final String title;
  const ExpenseTitleChanged(this.title);
  @override
  List<Object?> get props => [title];
}

class ExpenseAmountChanged extends ExpenseFormEvent {
  final String amount;
  const ExpenseAmountChanged(this.amount);
  @override
  List<Object?> get props => [amount];
}

class ExpenseNoteChanged extends ExpenseFormEvent {
  final String note;
  const ExpenseNoteChanged(this.note);
  @override
  List<Object?> get props => [note];
}

class ExpenseDateChanged extends ExpenseFormEvent {
  final DateTime date;
  const ExpenseDateChanged(this.date);
  @override
  List<Object?> get props => [date];
}

class ExpenseCategoryChanged extends ExpenseFormEvent {
  final String category;
  const ExpenseCategoryChanged(this.category);
  @override
  List<Object?> get props => [category];
}

class ExpenseFormSubmitted extends ExpenseFormEvent {
  const ExpenseFormSubmitted();
}
