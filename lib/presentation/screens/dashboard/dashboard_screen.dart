import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/blocs/dashboard/dashboard_bloc.dart';
import '../../../logic/blocs/dashboard/dashboard_event.dart';
import '../../../logic/blocs/dashboard/dashboard_state.dart';
import '../../../logic/blocs/expense/expense_bloc.dart';
import '../../../logic/blocs/income/income_bloc.dart';
import '../../../data/repositories/expense_repository.dart';
import '../../../data/repositories/income_repository.dart';
import '../dashboard/widgets/transaction_tile.dart';
import '../dashboard/widgets/bottom_nav_bar.dart';
import 'widgets/fab_popup.dart';
import '../expense/add_expense_screen.dart';
import '../income/add_income_screen.dart';
import '../budget/budget_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(LoadUserExpenses());
  }

  void _openAddPopup() async {
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
    }
    context.read<DashboardBloc>().add(LoadUserExpenses());
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      _buildDashboardContent(),
      BudgetScreen(onTabSelected: (i) => setState(() => _selectedIndex = i)),
      const Center(child: Text("Reports Screen")), // Placeholder
      const Center(child: Text("Debt Screen")),
      const Center(child: Text("Profile Screen")),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFE7F0FD),
      body: SafeArea(
        child: Stack(
          children: [
            screens[_selectedIndex],
            if (_selectedIndex == 0)
              Positioned(
                bottom: 20,
                right: 20,
                child: FloatingActionButton(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.add, size: 28),
                  onPressed: _openAddPopup,
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTabSelected: (index) {
          setState(() => _selectedIndex = index);
        },
      ),
    );
  }

  Widget _buildDashboardContent() {
    return Padding(
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
                    backgroundImage: NetworkImage("https://i.pravatar.cc/100"),
                    radius: 24,
                  ),
                  SizedBox(width: 10),
                  Text(
                    "Hey, Jacob!",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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

                transactions.sort((a, b) =>
                    (b['date'] as DateTime).compareTo(a['date'] as DateTime));

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
                    const Text("Total Balance",
                        style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        _buildStatCard("Income", totalIncome, Colors.green),
                        const SizedBox(width: 16),
                        _buildStatCard("Expense", totalExpense, Colors.red),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text("Recent Transactions",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600)),
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
                                onTap: () {},
                              );
                            }).toList(),
                          ),
                    const SizedBox(height: 80),
                  ],
                );
              } else {
                return const SizedBox();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, double value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 4),
            Text(
              '${label == "Expense" ? "-" : ""}\$${value.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Icon(
              label == "Income" ? Icons.arrow_upward : Icons.arrow_downward,
              color: color,
            ),
          ],
        ),
      ),
    );
  }
}
