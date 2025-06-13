import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/expense_repository.dart';
import '../../../data/repositories/income_repository.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final ExpenseRepository expenseRepo;
  final IncomeRepository incomeRepo;

  DashboardBloc(this.expenseRepo, this.incomeRepo) : super(DashboardInitial()) {
    on<LoadUserExpenses>((event, emit) async {
      emit(DashboardLoading());
      try {
        final expenses = await expenseRepo.fetchUserExpenses();
        final incomes = await incomeRepo.fetchUserIncome();
        emit(DashboardLoaded(expenses: expenses, incomes: incomes));
      } catch (e) {
        emit(DashboardError(e.toString()));
      }
    });
  }
}
