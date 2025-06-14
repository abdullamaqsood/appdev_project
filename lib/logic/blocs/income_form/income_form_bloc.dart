import 'package:flutter_bloc/flutter_bloc.dart';
import 'income_form_event.dart';
import 'income_form_state.dart';
import '../../../data/models/income_model.dart';
import '../../../data/repositories/income_repository.dart';
import 'package:uuid/uuid.dart';

class IncomeFormBloc extends Bloc<IncomeFormEvent, IncomeFormState> {
  final IncomeRepository repository;
  final bool isEdit;
  final String? id;

  IncomeFormBloc({required this.repository, this.isEdit = false, this.id})
      : super(IncomeFormState.initial()) {
    on<IncomeTitleChanged>((event, emit) {
      emit(state.copyWith(title: event.title));
    });
    on<IncomeAmountChanged>((event, emit) {
      emit(state.copyWith(amount: event.amount));
    });
    on<IncomeNoteChanged>((event, emit) {
      emit(state.copyWith(note: event.note));
    });
    on<IncomeDateChanged>((event, emit) {
      emit(state.copyWith(date: event.date));
    });
    on<IncomeFormSubmitted>((event, emit) async {
      emit(state.copyWith(
          isSubmitting: true, isFailure: false, isSuccess: false));
      try {
        final income = IncomeModel(
          id: isEdit ? id! : const Uuid().v4(),
          title: state.title.trim(),
          amount: double.tryParse(state.amount) ?? 0,
          date: state.date,
          note: state.note,
        );
        await repository.addIncome(income);
        emit(state.copyWith(isSubmitting: false, isSuccess: true));
      } catch (e) {
        emit(state.copyWith(isSubmitting: false, isFailure: true));
      }
    });
  }
}
