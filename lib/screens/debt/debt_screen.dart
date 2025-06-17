import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/debt/debt_bloc.dart';
import '../../blocs/debt/debt_event.dart';
import '../../blocs/debt/debt_state.dart';
import 'add_debt_screen.dart';

class DebtScreen extends StatefulWidget {
  const DebtScreen({super.key});

  @override
  State<DebtScreen> createState() => _DebtScreenState();
}

class _DebtScreenState extends State<DebtScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DebtBloc>().add(LoadDebts());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF3F9),
      body: SafeArea(
        child: BlocBuilder<DebtBloc, DebtState>(
          builder: (context, state) {
            if (state is DebtLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is DebtLoaded) {
              final loans = state.debts.where((d) => d.isLoan).toList();
              final debts = state.debts.where((d) => !d.isLoan).toList();

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ListView(
                  children: [
                    const SizedBox(height: 16),
                    const Text(
                      "Debt & Loan Tracker",
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),

                    // Loans Given Section
                    const Text("Loans Given",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    if (loans.isEmpty)
                      const Text("No loans",
                          style: TextStyle(color: Colors.grey))
                    else
                      ...loans.map((d) => _buildTile(d, true)),

                    const SizedBox(height: 24),

                    // Debts Taken Section
                    const Text("Debts Taken",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    if (debts.isEmpty)
                      const Text("No debts",
                          style: TextStyle(color: Colors.grey))
                    else
                      ...debts.map((d) => _buildTile(d, false)),

                    const SizedBox(height: 80),
                  ],
                ),
              );
            } else if (state is DebtFailure) {
              return Center(child: Text("Error: ${state.message}"));
            } else {
              return const SizedBox();
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddDebtScreen()),
          ).then((_) {
            context.read<DebtBloc>().add(LoadDebts());
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTile(debt, bool isLoan) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: Icon(
          isLoan ? Icons.arrow_upward : Icons.arrow_downward,
          color: isLoan ? Colors.green : Colors.red,
          size: 28,
        ),
        title: Text(
          "${debt.person} - \$${debt.amount.toStringAsFixed(2)}",
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            "Due: ${debt.dueDate.toLocal().toString().split(' ')[0]}\nNote: ${debt.note}",
            style: const TextStyle(height: 1.4),
          ),
        ),
        isThreeLine: true,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddDebtScreen(debt: debt),
                  ),
                );
                context.read<DebtBloc>().add(LoadDebts());
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                context.read<DebtBloc>().add(DeleteDebt(debt.id));
              },
            ),
          ],
        ),
      ),
    );
  }
}
