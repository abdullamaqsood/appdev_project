import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/income_repository.dart';
import '../../blocs/income_form/income_form_bloc.dart';
import '../../blocs/income_form/income_form_event.dart';
import '../../blocs/income_form/income_form_state.dart';

class AddIncomeScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => IncomeFormBloc(
        repository: IncomeRepository(),
        isEdit: isEdit,
        id: id,
      )
        ..add(IncomeTitleChanged(title ?? ''))
        ..add(IncomeAmountChanged(amount?.toString() ?? ''))
        ..add(IncomeNoteChanged(note ?? ''))
        ..add(IncomeDateChanged(date ?? DateTime.now())),
      child: _AddIncomeForm(isEdit: isEdit),
    );
  }
}

class _AddIncomeForm extends StatefulWidget {
  final bool isEdit;
  const _AddIncomeForm({required this.isEdit});

  @override
  State<_AddIncomeForm> createState() => _AddIncomeFormState();
}

class _AddIncomeFormState extends State<_AddIncomeForm> {
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
  late IncomeFormState _lastState;

  @override
  void initState() {
    super.initState();
    final state = context.read<IncomeFormBloc>().state;
    _titleController = TextEditingController(text: state.title);
    _amountController = TextEditingController(text: state.amount);
    _noteController = TextEditingController(text: state.note);
    _lastState = state;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _updateControllers(IncomeFormState state) {
    if (_lastState.title != state.title &&
        _titleController.text != state.title) {
      _titleController.text = state.title;
      _titleController.selection = TextSelection.fromPosition(
        TextPosition(offset: _titleController.text.length),
      );
    }
    if (_lastState.amount != state.amount &&
        _amountController.text != state.amount) {
      _amountController.text = state.amount;
      _amountController.selection = TextSelection.fromPosition(
        TextPosition(offset: _amountController.text.length),
      );
    }
    if (_lastState.note != state.note && _noteController.text != state.note) {
      _noteController.text = state.note;
      _noteController.selection = TextSelection.fromPosition(
        TextPosition(offset: _noteController.text.length),
      );
    }
    _lastState = state;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.isEdit ? "Edit Income" : "Add Income")),
      backgroundColor: const Color(0xFFEFF3F9),
      body: BlocConsumer<IncomeFormBloc, IncomeFormState>(
        listener: (context, state) {
          if (state.isSuccess) {
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _updateControllers(state);
          });
          return Padding(
            padding: const EdgeInsets.all(20),
            child: ListView(
              children: [
                TextField(
                  controller: _titleController,
                  onChanged: (value) => context
                      .read<IncomeFormBloc>()
                      .add(IncomeTitleChanged(value)),
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  onChanged: (value) => context
                      .read<IncomeFormBloc>()
                      .add(IncomeAmountChanged(value)),
                  decoration: const InputDecoration(labelText: 'Amount'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _noteController,
                  onChanged: (value) => context
                      .read<IncomeFormBloc>()
                      .add(IncomeNoteChanged(value)),
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
                          .read<IncomeFormBloc>()
                          .add(IncomeDateChanged(picked));
                    }
                  },
                  icon: const Icon(Icons.calendar_today),
                  label: Text(
                      "Date: " + state.date.toLocal().toString().split(' ')[0]),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: state.isSubmitting
                      ? null
                      : () => context
                          .read<IncomeFormBloc>()
                          .add(IncomeFormSubmitted()),
                  child: state.isSubmitting
                      ? const CircularProgressIndicator()
                      : Text(widget.isEdit ? "Update Income" : "Add Income"),
                ),
                if (state.isFailure)
                  const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Text('Failed to save income',
                        style: TextStyle(color: Colors.red)),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
