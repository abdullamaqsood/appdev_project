import 'package:flutter_bloc/flutter_bloc.dart';
import 'debt_form_event.dart';
import 'debt_form_state.dart';
import '../../../data/models/debt_model.dart';
import '../../../data/repositories/debt_repository.dart';
import 'package:uuid/uuid.dart';

class DebtFormBloc extends Bloc<DebtFormEvent, DebtFormState> {
  final DebtRepository debtRepository;

  DebtFormBloc({required this.debtRepository})
      : super(DebtFormState.initial()) {
    on<DebtPersonChanged>((event, emit) {
      emit(state.copyWith(person: event.person));
    });
    on<DebtAmountChanged>((event, emit) {
      emit(state.copyWith(amount: event.amount));
    });
    on<DebtNoteChanged>((event, emit) {
      emit(state.copyWith(note: event.note));
    });
    on<DebtGivenDateChanged>((event, emit) {
      emit(state.copyWith(givenDate: event.givenDate));
    });
    on<DebtDueDateChanged>((event, emit) {
      emit(state.copyWith(dueDate: event.dueDate));
    });
    on<DebtIsLoanChanged>((event, emit) {
      emit(state.copyWith(isLoan: event.isLoan));
    });
    on<DebtFormSubmitted>((event, emit) async {
      emit(state.copyWith(
          isSubmitting: true, isFailure: false, isSuccess: false));
      try {
        final id = const Uuid().v4();
        final person = state.person.trim();
        final amount = double.tryParse(state.amount) ?? 0;
        final note = state.note.trim();
        final givenDate = state.givenDate;
        final dueDate = state.dueDate;
        final isLoan = state.isLoan;
        if (person.isEmpty || amount <= 0) {
          emit(state.copyWith(isSubmitting: false, isFailure: true));
          return;
        }
        final debt = DebtModel(
          id: id,
          person: person,
          amount: amount,
          givenDate: givenDate,
          dueDate: dueDate,
          note: note,
          isLoan: isLoan,
        );
        await debtRepository.addDebt(debt);
        emit(state.copyWith(isSubmitting: false, isSuccess: true));
      } catch (e) {
        emit(state.copyWith(isSubmitting: false, isFailure: true));
      }
    });
  }
}
