import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/blocs/debt/debt_bloc.dart';
import '../../../logic/blocs/debt/debt_event.dart';
import '../../../logic/blocs/debt/debt_state.dart';
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
      appBar: AppBar(title: const Text("Debt & Loan Tracker")),
      body: BlocBuilder<DebtBloc, DebtState>(
        builder: (context, state) {
          if (state is DebtLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is DebtLoaded) {
            final loans = state.debts.where((d) => d.isLoan).toList();
            final debts = state.debts.where((d) => !d.isLoan).toList();

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text("Loans Given",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ...loans.map((d) => _buildTile(d, true)),
                const SizedBox(height: 24),
                const Text("Debts Taken",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ...debts.map((d) => _buildTile(d, false)),
              ],
            );
          } else if (state is DebtFailure) {
            return Center(child: Text("Error: ${state.message}"));
          } else {
            return const SizedBox();
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddDebtScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTile(debt, bool isLoan) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Icon(isLoan ? Icons.arrow_upward : Icons.arrow_downward,
            color: isLoan ? Colors.green : Colors.red),
        title: Text("${debt.person} - \$${debt.amount.toStringAsFixed(2)}"),
        subtitle: Text(
            "Due: ${debt.dueDate.toLocal().toString().split(' ')[0]}\nNote: ${debt.note}"),
        isThreeLine: true,
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () {
            context.read<DebtBloc>().add(DeleteDebt(debt.id));
          },
        ),
      ),
    );
  }
}
