import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/income_model.dart';
import '../../../logic/blocs/income/income_bloc.dart';
import '../../../logic/blocs/income/income_event.dart';
import '../../../logic/blocs/income/income_state.dart';
import '../../../data/repositories/income_repository.dart';

class AddIncomeScreen extends StatefulWidget {
  final bool isEdit;
  final String? id;
  final String? title;
  final double? amount;
  final String? note;
  final DateTime? date;

  const AddIncomeScreen({
    super.key,
    this.isEdit = false,
    this.id,
    this.title,
    this.amount,
    this.note,
    this.date,
  });

  @override
  State<AddIncomeScreen> createState() => _AddIncomeScreenState();
}

class _AddIncomeScreenState extends State<AddIncomeScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.isEdit) {
      _titleController.text = widget.title ?? '';
      _amountController.text = widget.amount?.toString() ?? '';
      _noteController.text = widget.note ?? '';
      _selectedDate = widget.date ?? DateTime.now();
    }
  }

  Future<void> _submit() async {
    final id = widget.isEdit ? widget.id! : const Uuid().v4();
    final title = _titleController.text.trim();
    final amount = double.tryParse(_amountController.text) ?? 0;
    final note = _noteController.text;

    if (title.isEmpty || amount <= 0) return;

    final income = IncomeModel(
      id: id,
      title: title,
      amount: amount,
      date: _selectedDate,
      note: note,
    );

    if (widget.isEdit) {
      await IncomeRepository().addIncome(income); // Overwrite existing
      if (mounted) Navigator.pop(context);
    } else {
      context.read<IncomeBloc>().add(AddIncomeEvent(income));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.isEdit ? "Edit Income" : "Add Income")),
      body: BlocConsumer<IncomeBloc, IncomeState>(
        listener: (context, state) {
          if (state is IncomeSuccess) {
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
                  onPressed: state is IncomeLoading ? null : _submit,
                  child: state is IncomeLoading
                      ? const CircularProgressIndicator()
                      : Text(widget.isEdit ? "Update Income" : "Add Income"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
