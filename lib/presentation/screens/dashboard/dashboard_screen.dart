import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/blocs/dashboard/dashboard_bloc.dart';
import '../../../logic/blocs/dashboard/dashboard_event.dart';
import '../../../logic/blocs/dashboard/dashboard_state.dart';
import '../../../logic/blocs/expense/expense_bloc.dart';
import '../../../logic/blocs/income/income_bloc.dart';
import '../dashboard/widgets/transaction_tile.dart';
import '../dashboard/widgets/bottom_nav_bar.dart';
import 'widgets/fab_popup.dart';
import '../../../data/repositories/expense_repository.dart';
import '../../../data/repositories/income_repository.dart';
import '../expense/add_expense_screen.dart';
import '../income/add_income_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(LoadUserExpenses());
  }

  void showTransactionDetailsDialog({
    required BuildContext context,
    required String type, // 'income' or 'expense'
    required String id,
    required String title,
    required String note,
    required double amount,
    required DateTime date,
    String? category,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(type == 'income' ? 'Income Details' : 'Expense Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Title: $title"),
            Text("Amount: \$${amount.toStringAsFixed(2)}"),
            Text("Date: ${date.toLocal().toString().split(" ").first}"),
            Text("Note: $note"),
            if (category != null) Text("Category: $category"),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: () {
              Navigator.pop(context);
              onEdit();
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              onDelete();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE7F0FD),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await showIncomeExpensePopup(context);

          if (result == 'expense') {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<ExpenseBloc>(),
                  child: const AddExpenseScreen(),
                ),
              ),
            );
            context.read<DashboardBloc>().add(LoadUserExpenses());
          } else if (result == 'income') {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<IncomeBloc>(),
                  child: const AddIncomeScreen(),
                ),
              ),
            );
            context.read<DashboardBloc>().add(LoadUserExpenses());
          }
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const CustomBottomNavBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: ListView(
            children: [
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      CircleAvatar(
                        backgroundImage:
                            NetworkImage("https://i.pravatar.cc/100"),
                        radius: 24,
                      ),
                      SizedBox(width: 10),
                      Text(
                        "Hey, Jacob!",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const Icon(Icons.notifications_outlined, size: 28),
                ],
              ),
              const SizedBox(height: 24),
              BlocBuilder<DashboardBloc, DashboardState>(
                builder: (context, state) {
                  if (state is DashboardLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is DashboardLoaded) {
                    final totalIncome = state.incomes.fold<double>(
                      0,
                      (sum, item) => sum + item.amount,
                    );
                    final totalExpense = state.expenses.fold<double>(
                      0,
                      (sum, item) => sum + item.amount,
                    );
                    final balance = totalIncome - totalExpense;

                    final transactions = [
                      ...state.expenses.map((e) => {
                            'id': e.id,
                            'type': 'expense',
                            'title': e.title,
                            'note': e.note,
                            'amount': '-\$${e.amount.toStringAsFixed(2)}',
                            'rawAmount': e.amount,
                            'date': e.date,
                            'color': Colors.red,
                            'icon': Icons.remove_circle_outline,
                            'category': e.category,
                          }),
                      ...state.incomes.map((i) => {
                            'id': i.id,
                            'type': 'income',
                            'title': i.title,
                            'note': i.note,
                            'amount': '+\$${i.amount.toStringAsFixed(2)}',
                            'rawAmount': i.amount,
                            'date': i.date,
                            'color': Colors.green,
                            'icon': Icons.add_circle_outline,
                            'category': null,
                          }),
                    ];

                    transactions.sort((a, b) => (b['date'] as DateTime)
                        .compareTo(a['date'] as DateTime));

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '\$${balance.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const Text(
                          "Total Balance",
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.teal.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("Income",
                                        style:
                                            TextStyle(color: Colors.black54)),
                                    const SizedBox(height: 4),
                                    Text(
                                      '\$${totalIncome.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const Icon(Icons.arrow_upward,
                                        color: Colors.green),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("Expense",
                                        style:
                                            TextStyle(color: Colors.black54)),
                                    const SizedBox(height: 4),
                                    Text(
                                      '-\$${totalExpense.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const Icon(Icons.arrow_downward,
                                        color: Colors.red),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          "Recent Transactions",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 16),
                        transactions.isEmpty
                            ? const Text("No recent transactions.")
                            : Column(
                                children: transactions.map((tx) {
                                  return TransactionTile(
                                    icon: tx['icon'] as IconData,
                                    title: tx['title'] as String,
                                    category: tx['category'] as String?,
                                    subtitle: tx['note'] as String,
                                    amount: tx['amount'] as String,
                                    date: (tx['date'] as DateTime)
                                        .toLocal()
                                        .toString()
                                        .split(" ")
                                        .first,
                                    amountColor: tx['color'] as Color,
                                    onTap: () {
                                      showTransactionDetailsDialog(
                                        context: context,
                                        type: tx['type'] as String,
                                        id: tx['id'] as String,
                                        title: tx['title'] as String,
                                        note: tx['note'] as String,
                                        amount: tx['rawAmount'] as double,
                                        date: tx['date'] as DateTime,
                                        category: tx['category'] as String?,
                                        onEdit: () async {
                                          if (tx['type'] == 'expense') {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    AddExpenseScreen(
                                                  isEdit: true,
                                                  id: tx['id'] as String,
                                                  title: tx['title'] as String,
                                                  amount:
                                                      tx['rawAmount'] as double,
                                                  note: tx['note'] as String,
                                                  date: tx['date'] as DateTime,
                                                  category:
                                                      tx['category'] as String,
                                                ),
                                              ),
                                            ).then((_) {
                                              context
                                                  .read<DashboardBloc>()
                                                  .add(LoadUserExpenses());
                                            });
                                          } else {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => AddIncomeScreen(
                                                  isEdit: true,
                                                  id: tx['id'] as String,
                                                  title: tx['title'] as String,
                                                  amount:
                                                      tx['rawAmount'] as double,
                                                  note: tx['note'] as String,
                                                  date: tx['date'] as DateTime,
                                                ),
                                              ),
                                            ).then((_) {
                                              context
                                                  .read<DashboardBloc>()
                                                  .add(LoadUserExpenses());
                                            });
                                          }
                                        },
                                        onDelete: () async {
                                          final expenseRepo =
                                              ExpenseRepository();
                                          final incomeRepo = IncomeRepository();

                                          if (tx['type'] == 'expense') {
                                            await expenseRepo.deleteExpense(
                                                tx['id'] as String);
                                          } else {
                                            await incomeRepo.deleteIncome(
                                                tx['id'] as String);
                                          }

                                          context
                                              .read<DashboardBloc>()
                                              .add(LoadUserExpenses());
                                        },
                                      );
                                    },
                                  );
                                }).toList(),
                              ),
                      ],
                    );
                  } else if (state is DashboardError) {
                    return Text("Error: ${state.message}");
                  } else {
                    return const SizedBox();
                  }
                },
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}
