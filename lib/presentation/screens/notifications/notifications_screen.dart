import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/blocs/debt/debt_bloc.dart';
import '../../../logic/blocs/debt/debt_event.dart';
import '../../../logic/blocs/debt/debt_state.dart';
import '../../../data/repositories/debt_repository.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DebtBloc(DebtRepository())..add(LoadDueDebts()),
      child: Scaffold(
        backgroundColor: const Color(0xFFE7F0FD),
        appBar: AppBar(
          title: const Text('Notifications'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  context.read<DebtBloc>().add(LoadDueDebts());
                },
              ),
            ),
          ],
        ),
        body: BlocBuilder<DebtBloc, DebtState>(
          builder: (context, state) {
            if (state is DebtLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is DueDebtsLoaded) {
              final dueDebts = state.dueDebts;
              if (dueDebts.isEmpty) {
                return const Center(
                  child: Text(
                    'No due payments',
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<DebtBloc>().add(LoadDueDebts());
                },
                child: ListView.builder(
                  itemCount: dueDebts.length,
                  itemBuilder: (context, index) {
                    final debt = dueDebts[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        leading: Icon(
                          debt.isLoan ? Icons.account_balance : Icons.money,
                          color: Colors.blue,
                        ),
                        title: Text(
                          debt.isLoan ? 'Loan Due Soon' : 'Debt Due Soon',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Person: ${debt.person}'),
                            Text('Amount: ${debt.amount.toStringAsFixed(2)}'),
                            Text(
                                'Due Date: ${debt.dueDate.toLocal().toString().split(' ')[0]}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            } else if (state is DebtFailure) {
              return Center(child: Text('Error: ${state.message}'));
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
      ),
    );
  }
}
