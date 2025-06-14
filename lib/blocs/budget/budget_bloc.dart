import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/budget_repository.dart';
import 'budget_event.dart';
import 'budget_state.dart';

class BudgetBloc extends Bloc<BudgetEvent, BudgetState> {
  final BudgetRepository repository;

  BudgetBloc(this.repository) : super(BudgetInitial()) {
    on<LoadBudgets>((event, emit) async {
      emit(BudgetLoading());
      try {
        final budgets = await repository.fetchBudgets();
        emit(BudgetLoaded(budgets));
      } catch (e) {
        emit(BudgetFailure(e.toString()));
      }
    });

    on<AddBudget>((event, emit) async {
      try {
        await repository.addBudget(event.budget);
        add(LoadBudgets());
      } catch (e) {
        emit(BudgetFailure(e.toString()));
      }
    });

    on<DeleteBudget>((event, emit) async {
      try {
        await repository.deleteBudget(event.id);
        add(LoadBudgets());
      } catch (e) {
        emit(BudgetFailure(e.toString()));
      }
    });

    on<UpdateBudget>((event, emit) async {
      try {
        await repository.updateBudget(event.budget);
        add(LoadBudgets());
      } catch (e) {
        emit(BudgetFailure(e.toString()));
      }
    });
  }
}
