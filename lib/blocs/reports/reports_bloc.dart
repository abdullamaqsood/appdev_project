import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/expense_repository.dart';
import '../../data/repositories/income_repository.dart';
import 'reports_event.dart';
import 'reports_state.dart';

class ReportsBloc extends Bloc<ReportsEvent, ReportsState> {
  final ExpenseRepository expenseRepository;
  final IncomeRepository incomeRepository;

  ReportsBloc({required this.expenseRepository, required this.incomeRepository})
      : super(ReportsInitial()) {
    on<LoadReports>((event, emit) async {
      emit(ReportsLoading());
      try {
        final expenses =
            await expenseRepository.fetchUserExpensesByMonth(event.month);
        final incomes =
            await incomeRepository.fetchUserIncomeByMonth(event.month);
        emit(ReportsLoaded(expenses: expenses, incomes: incomes));
      } catch (e) {
        emit(ReportsError(e.toString()));
      }
    });
  }
}
