import 'package:flutter/material.dart';
import '../../../data/repositories/debt_repository.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Map<String, dynamic>> _dueDebts = [];

  @override
  void initState() {
    super.initState();
    _loadDueDebts();
  }

  Future<void> _loadDueDebts() async {
    final debts = await DebtRepository().fetchDebts();
    final now = DateTime.now();
    final dueDebts = debts
        .where((debt) {
          final due = debt.dueDate;
          final daysUntilDue = due.difference(now).inDays;
          return daysUntilDue <= 1 && due.isAfter(now);
        })
        .map((debt) => {
              'id': debt.id,
              'title': debt.isLoan ? 'Loan Due Soon' : 'Debt Due Soon',
              'person': debt.person,
              'dueDate': debt.dueDate,
              'amount': debt.amount,
              'isLoan': debt.isLoan,
            })
        .toList();

    setState(() {
      _dueDebts = dueDebts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE7F0FD),
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDueDebts,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDueDebts,
        child: _dueDebts.isEmpty
            ? const Center(
                child: Text(
                  'No due payments',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            : ListView.builder(
                itemCount: _dueDebts.length,
                itemBuilder: (context, index) {
                  final debt = _dueDebts[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ListTile(
                      leading: Icon(
                        debt['isLoan'] ? Icons.account_balance : Icons.money,
                        color: Colors.blue,
                      ),
                      title: Text(
                        debt['title'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Person: ${debt['person']}'),
                          Text(
                              'Amount: \$${debt['amount'].toStringAsFixed(2)}'),
                          Text(
                              'Due Date: ${debt['dueDate'].toLocal().toString().split(' ')[0]}'),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
