import 'package:equatable/equatable.dart';
import '../../data/models/expense_model.dart';
import '../../data/models/income_model.dart';

abstract class ReportsState extends Equatable {
  const ReportsState();

  @override
  List<Object?> get props => [];
}

class ReportsInitial extends ReportsState {}

class ReportsLoading extends ReportsState {}

class ReportsLoaded extends ReportsState {
  final List<ExpenseModel> expenses;
  final List<IncomeModel> incomes;

  const ReportsLoaded({required this.expenses, required this.incomes});

  @override
  List<Object?> get props => [expenses, incomes];
}

class ReportsError extends ReportsState {
  final String message;
  const ReportsError(this.message);

  @override
  List<Object?> get props => [message];
}
