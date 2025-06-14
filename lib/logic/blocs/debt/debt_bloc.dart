import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/debt_repository.dart';
import 'debt_event.dart';
import 'debt_state.dart';

class DebtBloc extends Bloc<DebtEvent, DebtState> {
  final DebtRepository repository;

  DebtBloc(this.repository) : super(DebtInitial()) {
    on<LoadDebts>((event, emit) async {
      emit(DebtLoading());
      try {
        final debts = await repository.fetchDebts();
        emit(DebtLoaded(debts));
      } catch (e) {
        emit(DebtFailure(e.toString()));
      }
    });

    on<AddDebt>((event, emit) async {
      try {
        await repository.addDebt(event.debt);
        add(LoadDebts());
      } catch (e) {
        emit(DebtFailure(e.toString()));
      }
    });

    on<DeleteDebt>((event, emit) async {
      try {
        await repository.deleteDebt(event.id);
        add(LoadDebts());
      } catch (e) {
        emit(DebtFailure(e.toString()));
      }
    });

    on<LoadDueDebts>((event, emit) async {
      emit(DebtLoading());
      try {
        final debts = await repository.fetchDebts();
        final now = DateTime.now();
        final dueDebts = debts.where((debt) {
          final due = debt.dueDate;
          final daysUntilDue = due.difference(now).inDays;
          return daysUntilDue <= 1 && due.isAfter(now);
        }).toList();
        emit(DueDebtsLoaded(dueDebts));
      } catch (e) {
        emit(DebtFailure(e.toString()));
      }
    });
  }
}
