import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/expense_repository.dart';
import 'expense_event.dart';
import 'expense_state.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final ExpenseRepository repository;

  ExpenseBloc(this.repository) : super(ExpenseInitial()) {
    on<AddExpenseEvent>((event, emit) async {
      emit(ExpenseLoading());
      try {
        await repository.addExpense(event.expense);
        emit(ExpenseSuccess());
      } catch (e) {
        emit(ExpenseFailure(e.toString()));
      }
    });
  }
}
