import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/income_repository.dart';
import 'income_event.dart';
import 'income_state.dart';

class IncomeBloc extends Bloc<IncomeEvent, IncomeState> {
  final IncomeRepository repository;

  IncomeBloc(this.repository) : super(IncomeInitial()) {
    on<AddIncomeEvent>((event, emit) async {
      emit(IncomeLoading());
      try {
        await repository.addIncome(event.income);
        emit(IncomeSuccess());
      } catch (e) {
        emit(IncomeFailure(e.toString()));
      }
    });
  }
}
