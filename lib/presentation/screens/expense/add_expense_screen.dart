import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/expense_model.dart';
import '../../../logic/blocs/expense/expense_bloc.dart';
import '../../../logic/blocs/expense/expense_event.dart';
import '../../../logic/blocs/expense/expense_state.dart';
import '../../../data/repositories/expense_repository.dart';

class AddExpenseScreen extends StatefulWidget {
  final bool isEdit;
  final String? id;
  final String? title;
  final double? amount;
  final String? note;
  final DateTime? date;
  final String? category;

  const AddExpenseScreen({
    super.key,
    this.isEdit = false,
    this.id,
    this.title,
    this.amount,
    this.note,
    this.date,
    this.category,
  });

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _selectedCategory = "Food";

  final List<String> categories = [
    'Food',
    'Transport',
    'Shopping',
    'Bills',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.isEdit) {
      _titleController.text = widget.title ?? '';
      _amountController.text = widget.amount?.toString() ?? '';
      _noteController.text = widget.note ?? '';
      _selectedDate = widget.date ?? DateTime.now();
      _selectedCategory = widget.category ?? 'Other';
    }
  }

  Future<void> _submit() async {
    final id = widget.isEdit ? widget.id! : const Uuid().v4();
    final title = _titleController.text.trim();
    final amount = double.tryParse(_amountController.text) ?? 0;
    final note = _noteController.text;

    if (title.isEmpty || amount <= 0) return;

    final expense = ExpenseModel(
      id: id,
      title: title,
      category: _selectedCategory,
      amount: amount,
      date: _selectedDate,
      note: note,
    );

    if (widget.isEdit) {
      await ExpenseRepository().addExpense(expense); // Overwrite existing doc
      if (mounted) Navigator.pop(context);
    } else {
      context.read<ExpenseBloc>().add(AddExpenseEvent(expense));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text(widget.isEdit ? "Edit Expense" : "Add Expense")),
      body: BlocConsumer<ExpenseBloc, ExpenseState>(
        listener: (context, state) {
          if (state is ExpenseSuccess) {
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: ListView(
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Amount'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  items: categories
                      .map((cat) =>
                          DropdownMenuItem(value: cat, child: Text(cat)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedCategory = val);
                  },
                  decoration: const InputDecoration(labelText: 'Category'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _noteController,
                  decoration: const InputDecoration(labelText: 'Note'),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() => _selectedDate = picked);
                    }
                  },
                  icon: const Icon(Icons.calendar_today),
                  label: Text("Date: ${_selectedDate.toLocal()}".split(' ')[0]),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: state is ExpenseLoading ? null : _submit,
                  child: state is ExpenseLoading
                      ? const CircularProgressIndicator()
                      : Text(widget.isEdit ? "Update Expense" : "Add Expense"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
