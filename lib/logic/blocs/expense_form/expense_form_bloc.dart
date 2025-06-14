import 'package:flutter_bloc/flutter_bloc.dart';
import 'expense_form_event.dart';
import 'expense_form_state.dart';
import '../../../data/models/expense_model.dart';
import '../../../data/models/budget_model.dart';
import '../../../data/repositories/expense_repository.dart';
import '../../../data/repositories/budget_repository.dart';
import 'package:uuid/uuid.dart';

class ExpenseFormBloc extends Bloc<ExpenseFormEvent, ExpenseFormState> {
  final ExpenseRepository expenseRepository;
  final BudgetRepository budgetRepository;
  final bool isEdit;
  final String? id;
  final ExpenseModel? initialExpense;

  ExpenseFormBloc({
    required this.expenseRepository,
    required this.budgetRepository,
    this.isEdit = false,
    this.id,
    this.initialExpense,
  }) : super(
          initialExpense != null
              ? ExpenseFormState(
                  title: initialExpense.title,
                  amount: initialExpense.amount.toString(),
                  note: initialExpense.note,
                  date: initialExpense.date,
                  category: initialExpense.category,
                )
              : ExpenseFormState.initial(),
        ) {
    on<ExpenseTitleChanged>((event, emit) {
      emit(state.copyWith(title: event.title));
    });
    on<ExpenseAmountChanged>((event, emit) {
      emit(state.copyWith(amount: event.amount));
    });
    on<ExpenseNoteChanged>((event, emit) {
      emit(state.copyWith(note: event.note));
    });
    on<ExpenseDateChanged>((event, emit) {
      emit(state.copyWith(date: event.date));
    });
    on<ExpenseCategoryChanged>((event, emit) {
      emit(state.copyWith(category: event.category));
    });
    on<ExpenseFormSubmitted>((event, emit) async {
      emit(state.copyWith(
          isSubmitting: true, isFailure: false, isSuccess: false));
      try {
        final idVal = isEdit ? id! : const Uuid().v4();
        final title = state.title.trim();
        final amount = double.tryParse(state.amount) ?? 0;
        final note = state.note;
        final date = state.date;
        final category = state.category;
        if (title.isEmpty || amount <= 0) {
          emit(state.copyWith(isSubmitting: false, isFailure: true));
          return;
        }
        // Check budget before adding expense
        final budgets = await budgetRepository.fetchBudgets();
        final categoryBudget = budgets.firstWhere(
          (budget) => budget.category == category,
          orElse: () => BudgetModel(
            id: '',
            category: '',
            limit: 0,
            createdAt: DateTime.now(),
          ),
        );
        if (categoryBudget.id.isNotEmpty) {
          final currentMonth =
              DateTime(DateTime.now().year, DateTime.now().month);
          final expenses =
              await expenseRepository.fetchUserExpensesByMonth(currentMonth);
          final categoryExpenses =
              expenses.where((e) => e.category == category);
          double totalSpent =
              categoryExpenses.fold<double>(0, (sum, e) => sum + e.amount);
          if (isEdit && initialExpense != null) {
            totalSpent -= initialExpense!.amount;
          }
          if (totalSpent + amount > categoryBudget.limit) {
            // Optionally, you can emit a special state for budget warning
          }
        }
        final expense = ExpenseModel(
          id: idVal,
          title: title,
          category: category,
          amount: amount,
          date: date,
          note: note,
        );
        await expenseRepository.addExpense(expense);
        emit(state.copyWith(isSubmitting: false, isSuccess: true));
      } catch (e) {
        emit(state.copyWith(isSubmitting: false, isFailure: true));
      }
    });
  }
}
