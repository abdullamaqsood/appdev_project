import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/debt_model.dart';
import '../../../logic/blocs/debt/debt_bloc.dart';
import '../../../logic/blocs/debt/debt_event.dart';

class AddDebtScreen extends StatefulWidget {
  const AddDebtScreen({super.key});

  @override
  State<AddDebtScreen> createState() => _AddDebtScreenState();
}

class _AddDebtScreenState extends State<AddDebtScreen> {
  final personController = TextEditingController();
  final amountController = TextEditingController();
  final noteController = TextEditingController();
  DateTime _givenDate = DateTime.now();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 30));
  bool _isLoan = true;

  void _submit() {
    final id = const Uuid().v4();
    final person = personController.text.trim();
    final amount = double.tryParse(amountController.text) ?? 0;
    final note = noteController.text.trim();

    if (person.isEmpty || amount <= 0) return;

    final debt = DebtModel(
      id: id,
      person: person,
      amount: amount,
      givenDate: _givenDate,
      dueDate: _dueDate,
      note: note,
      isLoan: _isLoan,
    );

    context.read<DebtBloc>().add(AddDebt(debt));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Debt/Loan")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            SwitchListTile(
              value: _isLoan,
              onChanged: (val) => setState(() => _isLoan = val),
              title: Text(_isLoan ? "Loan (You gave)" : "Debt (You owe)"),
            ),
            TextField(
              controller: personController,
              decoration: const InputDecoration(labelText: "Person"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Amount"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(labelText: "Note"),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _givenDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                );
                if (picked != null) setState(() => _givenDate = picked);
              },
              icon: const Icon(Icons.calendar_today),
              label: Text("Given Date: ${_givenDate.toLocal()}".split(' ')[0]),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _dueDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (picked != null) setState(() => _dueDate = picked);
              },
              icon: const Icon(Icons.event),
              label: Text("Due Date: ${_dueDate.toLocal()}".split(' ')[0]),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submit,
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}
