import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/expense_repository.dart';
import '../../data/repositories/income_repository.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final ExpenseRepository expenseRepo;
  final IncomeRepository incomeRepo;

  DashboardBloc(this.expenseRepo, this.incomeRepo)
      : super(const DashboardInitial()) {
    on<LoadUserExpenses>((event, emit) async {
      emit(DashboardLoading(selectedIndex: state.selectedIndex));
      try {
        final expenses = await expenseRepo.fetchUserExpenses();
        final incomes = await incomeRepo.fetchUserIncome();
        emit(DashboardLoaded(
          expenses: expenses,
          incomes: incomes,
          selectedIndex: state.selectedIndex,
        ));
      } catch (e) {
        emit(DashboardError(e.toString(), selectedIndex: state.selectedIndex));
      }
    });

    on<DashboardTabChanged>((event, emit) async {
      // If already loaded, preserve data, else just update index
      final currentState = state;
      if (currentState is DashboardLoaded) {
        emit(DashboardLoaded(
          expenses: currentState.expenses,
          incomes: currentState.incomes,
          selectedIndex: event.index,
        ));
      } else if (currentState is DashboardLoading) {
        emit(DashboardLoading(selectedIndex: event.index));
      } else if (currentState is DashboardError) {
        emit(DashboardError(currentState.message, selectedIndex: event.index));
      } else {
        emit(DashboardInitial(selectedIndex: event.index));
      }
    });
  }
}
