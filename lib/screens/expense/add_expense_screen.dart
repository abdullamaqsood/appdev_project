import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/expense_model.dart';
import '../../blocs/expense_form/expense_form_bloc.dart';
import '../../blocs/expense_form/expense_form_event.dart';
import '../../blocs/expense_form/expense_form_state.dart';
import '../../data/repositories/expense_repository.dart';
import '../../data/repositories/budget_repository.dart';

class AddExpenseScreen extends StatelessWidget {
  final bool isEdit;
  final String? id;
  final String? title;
  final double? amount;
  final String? note;
  final DateTime? date;
  final String? category;

  AddExpenseScreen({
    super.key,
    this.isEdit = false,
    this.id,
    this.title,
    this.amount,
    this.note,
    this.date,
    this.category,
  });

  final List<String> categories = const [
    'Food',
    'Transport',
    'Shopping',
    'Bills',
    'Other'
  ];

  @override
  Widget build(BuildContext context) {
    final initialExpense = isEdit
        ? ExpenseModel(
            id: id!,
            title: title ?? '',
            amount: amount ?? 0,
            note: note ?? '',
            date: date ?? DateTime.now(),
            category: category ?? 'Other',
          )
        : null;
    return BlocProvider(
      create: (_) => ExpenseFormBloc(
        expenseRepository: ExpenseRepository(),
        budgetRepository: BudgetRepository(),
        isEdit: isEdit,
        id: id,
        initialExpense: initialExpense,
      ),
      child: BlocConsumer<ExpenseFormBloc, ExpenseFormState>(
        listener: (context, state) async {
          if (state.isSuccess) {
            Navigator.pop(context);
          } else if (state.isFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to save expense. Please try again.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar:
                AppBar(title: Text(isEdit ? "Edit Expense" : "Add Expense")),
            body: Padding(
              padding: const EdgeInsets.all(20),
              child: ListView(
                children: [
                  TextFormField(
                    initialValue: state.title,
                    onChanged: (val) => context
                        .read<ExpenseFormBloc>()
                        .add(ExpenseTitleChanged(val)),
                    decoration: const InputDecoration(labelText: 'Title'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: state.amount,
                    onChanged: (val) => context
                        .read<ExpenseFormBloc>()
                        .add(ExpenseAmountChanged(val)),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Amount'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: state.category,
                    items: categories
                        .map((cat) =>
                            DropdownMenuItem(value: cat, child: Text(cat)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        context
                            .read<ExpenseFormBloc>()
                            .add(ExpenseCategoryChanged(val));
                      }
                    },
                    decoration: const InputDecoration(labelText: 'Category'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: state.note,
                    onChanged: (val) => context
                        .read<ExpenseFormBloc>()
                        .add(ExpenseNoteChanged(val)),
                    decoration: const InputDecoration(labelText: 'Note'),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: state.date,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        context
                            .read<ExpenseFormBloc>()
                            .add(ExpenseDateChanged(picked));
                      }
                    },
                    icon: const Icon(Icons.calendar_today),
                    label: Text("Date: " +
                        state.date.toLocal().toString().split(' ')[0]),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: state.isSubmitting
                        ? null
                        : () {
                            context
                                .read<ExpenseFormBloc>()
                                .add(const ExpenseFormSubmitted());
                          },
                    child: state.isSubmitting
                        ? const CircularProgressIndicator()
                        : Text(isEdit ? "Update Expense" : "Add Expense"),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
