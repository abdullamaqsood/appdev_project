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
            backgroundColor: const Color(0xFFEFF3F9),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ListView(
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      widget.debt == null
                          ? "Add Debt / Loan"
                          : "Edit Debt / Loan",
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),

                    // Type Switch
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 4)
                        ],
                      ),
                      child: SwitchListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16),
                        value: state.isLoan,
                        onChanged: (val) => context
                            .read<DebtFormBloc>()
                            .add(DebtIsLoanChanged(val)),
                        title: Text(
                          state.isLoan ? "Loan (You gave)" : "Debt (You owe)",
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Person
                    TextField(
                      controller: _personController,
                      onChanged: (val) => context
                          .read<DebtFormBloc>()
                          .add(DebtPersonChanged(val)),
                      decoration: InputDecoration(
                        labelText: "Person",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Amount
                    TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      onChanged: (val) => context
                          .read<DebtFormBloc>()
                          .add(DebtAmountChanged(val)),
                      decoration: InputDecoration(
                        labelText: "Amount",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Note
                    TextField(
                      controller: _noteController,
                      onChanged: (val) => context
                          .read<DebtFormBloc>()
                          .add(DebtNoteChanged(val)),
                      decoration: InputDecoration(
                        labelText: "Note",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Given Date
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
                      label: Text(
                          "Given Date: ${state.givenDate.toLocal().toString().split(' ')[0]}"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                        elevation: 1,
                        alignment: Alignment.centerLeft,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Due Date
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
                      label: Text(
                          "Due Date: ${state.dueDate.toLocal().toString().split(' ')[0]}"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                        elevation: 1,
                        alignment: Alignment.centerLeft,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
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
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: state.isSubmitting
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              widget.debt == null ? "Save" : "Update",
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.white),
                            ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
