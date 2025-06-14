import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/debt_form/debt_form_bloc.dart';
import '../../blocs/debt_form/debt_form_event.dart';
import '../../blocs/debt_form/debt_form_state.dart';
import '../../data/repositories/debt_repository.dart';
import '../../data/models/debt_model.dart';

class AddDebtScreen extends StatelessWidget {
  final DebtModel? debt;
  const AddDebtScreen({super.key, this.debt});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DebtFormBloc(debtRepository: DebtRepository()),
      child: _AddDebtForm(debt: debt),
    );
  }
}

class _AddDebtForm extends StatefulWidget {
  final DebtModel? debt;
  const _AddDebtForm({Key? key, this.debt}) : super(key: key);

  @override
  State<_AddDebtForm> createState() => _AddDebtFormState();
}

class _AddDebtFormState extends State<_AddDebtForm> {
  late final TextEditingController _personController;
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _personController = TextEditingController();
    _amountController = TextEditingController();
    _noteController = TextEditingController();
  }

  @override
  void dispose() {
    _personController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _initializeFields(DebtFormState state) {
    if (!_initialized && widget.debt != null) {
      _personController.text = widget.debt!.person;
      _amountController.text = widget.debt!.amount.toString();
      _noteController.text = widget.debt!.note;
      final bloc = context.read<DebtFormBloc>();
      bloc.add(DebtPersonChanged(widget.debt!.person));
      bloc.add(DebtAmountChanged(widget.debt!.amount.toString()));
      bloc.add(DebtNoteChanged(widget.debt!.note));
      bloc.add(DebtGivenDateChanged(widget.debt!.givenDate));
      bloc.add(DebtDueDateChanged(widget.debt!.dueDate));
      bloc.add(DebtIsLoanChanged(widget.debt!.isLoan));
      _initialized = true;
    }
  }

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
          _initializeFields(state);
          return Scaffold(
            appBar: AppBar(
                title: Text(
                    widget.debt == null ? "Add Debt/Loan" : "Edit Debt/Loan")),
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
                    controller: _personController,
                    onChanged: (val) => context
                        .read<DebtFormBloc>()
                        .add(DebtPersonChanged(val)),
                    decoration: const InputDecoration(labelText: "Person"),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    onChanged: (val) => context
                        .read<DebtFormBloc>()
                        .add(DebtAmountChanged(val)),
                    decoration: const InputDecoration(labelText: "Amount"),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _noteController,
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
                        : () async {
                            final bloc = context.read<DebtFormBloc>();
                            if (widget.debt == null) {
                              bloc.add(const DebtFormSubmitted());
                            } else {
                              final updatedDebt = DebtModel(
                                id: widget.debt!.id,
                                person: state.person,
                                amount: double.tryParse(state.amount) ?? 0,
                                givenDate: state.givenDate,
                                dueDate: state.dueDate,
                                note: state.note,
                                isLoan: state.isLoan,
                              );
                              await DebtRepository().updateDebt(updatedDebt);
                              Navigator.pop(context);
                            }
                          },
                    child: state.isSubmitting
                        ? const CircularProgressIndicator()
                        : Text(widget.debt == null ? "Save" : "Update"),
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
