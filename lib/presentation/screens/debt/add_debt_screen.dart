import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/debt_model.dart';
import '../../../logic/blocs/debt/debt_bloc.dart';
import '../../../logic/blocs/debt/debt_event.dart';
import '../../../logic/blocs/debt_form/debt_form_bloc.dart';
import '../../../logic/blocs/debt_form/debt_form_event.dart';
import '../../../logic/blocs/debt_form/debt_form_state.dart';
import '../../../data/repositories/debt_repository.dart';

class AddDebtScreen extends StatelessWidget {
  const AddDebtScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DebtFormBloc(debtRepository: DebtRepository()),
      child: const _AddDebtForm(),
    );
  }
}

class _AddDebtForm extends StatelessWidget {
  const _AddDebtForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<DebtFormBloc, DebtFormState>(
      listener: (context, state) {
        if (state.isSuccess) {
          Navigator.pop(context);
        } else if (state.isFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please fill all required fields.')),
          );
        }
      },
      child: BlocBuilder<DebtFormBloc, DebtFormState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(title: const Text("Add Debt/Loan")),
            body: Padding(
              padding: const EdgeInsets.all(20),
              child: ListView(
                children: [
                  SwitchListTile(
                    value: state.isLoan,
                    onChanged: (val) => context
                        .read<DebtFormBloc>()
                        .add(DebtIsLoanChanged(val)),
                    title: Text(
                        state.isLoan ? "Loan (You gave)" : "Debt (You owe)"),
                  ),
                  TextField(
                    onChanged: (val) => context
                        .read<DebtFormBloc>()
                        .add(DebtPersonChanged(val)),
                    decoration: const InputDecoration(labelText: "Person"),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    keyboardType: TextInputType.number,
                    onChanged: (val) => context
                        .read<DebtFormBloc>()
                        .add(DebtAmountChanged(val)),
                    decoration: const InputDecoration(labelText: "Amount"),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    onChanged: (val) =>
                        context.read<DebtFormBloc>().add(DebtNoteChanged(val)),
                    decoration: const InputDecoration(labelText: "Note"),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: state.givenDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        context
                            .read<DebtFormBloc>()
                            .add(DebtGivenDateChanged(picked));
                      }
                    },
                    icon: const Icon(Icons.calendar_today),
                    label: Text("Given Date: " +
                        state.givenDate.toLocal().toString().split(' ')[0]),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: state.dueDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        context
                            .read<DebtFormBloc>()
                            .add(DebtDueDateChanged(picked));
                      }
                    },
                    icon: const Icon(Icons.event),
                    label: Text("Due Date: " +
                        state.dueDate.toLocal().toString().split(' ')[0]),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: state.isSubmitting
                        ? null
                        : () => context
                            .read<DebtFormBloc>()
                            .add(const DebtFormSubmitted()),
                    child: state.isSubmitting
                        ? const CircularProgressIndicator()
                        : const Text("Save"),
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
