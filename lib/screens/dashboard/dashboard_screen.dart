import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:csv/csv.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../blocs/dashboard/dashboard_bloc.dart';
import '../../blocs/dashboard/dashboard_event.dart';
import '../../blocs/dashboard/dashboard_state.dart';
import '../../blocs/expense/expense_bloc.dart';
import '../../blocs/income/income_bloc.dart';
import '../../data/repositories/expense_repository.dart';
import '../../data/repositories/income_repository.dart';
import '../../utils/notification_helper.dart';
import 'widgets/transaction_tile.dart';
import 'widgets/bottom_nav_bar.dart';
import 'widgets/fab_popup.dart';
import '../expense/add_expense_screen.dart';
import '../income/add_income_screen.dart';
import '../budget/budget_screen.dart';
import '../reports/reports_screen.dart';
import '../debt/debt_screen.dart';
import '../notifications/notifications_screen.dart';
import '../../data/repositories/debt_repository.dart';
import '../../data/repositories/budget_repository.dart';
import '../profile/profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  final int initialTabIndex;
  const DashboardScreen({super.key, this.initialTabIndex = 0});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Future<void> scheduleDueDebtNotifications() async {
    await NotificationHelper().scheduleDueDebtNotifications();
  }

  @override
  void initState() {
    super.initState();
    context
        .read<DashboardBloc>()
        .add(DashboardTabChanged(widget.initialTabIndex));
    context.read<DashboardBloc>().add(LoadUserExpenses());
    _checkDueDebts();
    _checkBudgetBreaches();
  }

  Future<void> _checkDueDebts() async {
    final debts = await DebtRepository().fetchDebts();
    final now = DateTime.now();
    bool hasDueDebts = false;

    for (final debt in debts) {
      final due = debt.dueDate;
      final daysUntilDue = due.difference(now).inDays;

      if (daysUntilDue <= 1 && due.isAfter(now)) {
        hasDueDebts = true;
        break;
      }
    }

    if (hasDueDebts && mounted) {
      await NotificationHelper.showNotification(
        id: 0,
        title: 'Due Payments',
        body: 'You have loans/debts due soon. Check notifications for details.',
      );
    }
  }

  Future<void> _checkBudgetBreaches() async {
    final budgets = await BudgetRepository().fetchBudgets();
    if (budgets.isEmpty) return;

    final currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
    final expenses =
        await ExpenseRepository().fetchUserExpensesByMonth(currentMonth);

    // Calculate total spent for each category
    final Map<String, double> categoryTotals = {};
    for (var expense in expenses) {
      categoryTotals[expense.category] =
          (categoryTotals[expense.category] ?? 0) + expense.amount;
    }

    // Check each budget
    for (var budget in budgets) {
      final totalSpent = categoryTotals[budget.category] ?? 0;
      if (totalSpent > budget.limit) {
        await NotificationHelper.showNotification(
          id: 2,
          title: 'Budget Breached',
          body:
              'Your ${budget.category} expenses (\$${totalSpent.toStringAsFixed(2)}) have exceeded the budget of \$${budget.limit}',
        );
      }
    }
  }

  void _openAddPopup() async {
    final result = await showIncomeExpensePopup(context);
    if (result == 'expense') {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: context.read<ExpenseBloc>(),
            child: AddExpenseScreen(),
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

  Future<void> _exportTransactions(
    List<Map<String, dynamic>> transactions,
    double income,
    double expense,
    double balance,
  ) async {
    // Ask user: PDF or CSV?
    final choice = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.picture_as_pdf),
            title: const Text("Export as PDF"),
            onTap: () => Navigator.pop(context, 'pdf'),
          ),
          ListTile(
            leading: const Icon(Icons.table_chart),
            title: const Text("Export as CSV"),
            onTap: () => Navigator.pop(context, 'csv'),
          ),
        ],
      ),
    );

    if (choice == null) return;

    // Downloads folder path (Android only)
    final downloadsDir = Directory('/storage/emulated/0/Download');
    final timeStamp = DateTime.now().millisecondsSinceEpoch;

    if (!(await downloadsDir.exists())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Downloads folder not found.")),
      );
      return;
    }

    if (choice == 'csv') {
      final csvFile =
          File('${downloadsDir.path}/transaction_export_$timeStamp.csv');

      List<List<dynamic>> rows = [
        ['Date', 'Time', 'Title', 'Type', 'Category', 'Amount', 'Note']
      ];
      for (var tx in transactions) {
        final dateTime = tx['date'] as DateTime;
        rows.add([
          dateTime.toLocal().toString().split(' ').first,
          dateTime.toLocal().toString().split(' ').last.split('.').first,
          tx['title'],
          tx['type'],
          tx['category'] ?? '-',
          tx['rawAmount'],
          tx['note'],
        ]);
      }

      final csvData = const ListToCsvConverter().convert(rows);
      await csvFile.writeAsString(csvData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("CSV exported to: ${csvFile.path}")),
      );
    }

    if (choice == 'pdf') {
      final pdfFile =
          File('${downloadsDir.path}/transaction_export_$timeStamp.pdf');

      final pdf = pw.Document();
      List<List<String>> pdfTable = transactions
          .map((tx) {
            final dt = tx['date'] as DateTime;
            return [
              dt.toLocal().toString().split(' ').first,
              dt.toLocal().toString().split(' ').last.split('.').first,
              tx['title'].toString(),
              tx['type'].toString(),
              (tx['category'] ?? '-').toString(),
              tx['rawAmount'].toString(),
              tx['note'].toString(),
            ];
          })
          .toList()
          .cast<List<String>>();

      pdf.addPage(
        pw.MultiPage(
          build: (pw.Context context) => [
            pw.Text("Transaction Summary",
                style:
                    pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Text("Total Income: \$${income.toStringAsFixed(2)}"),
            pw.Text("Total Expense: \$${expense.toStringAsFixed(2)}"),
            pw.Text("Balance: \$${balance.toStringAsFixed(2)}"),
            pw.SizedBox(height: 20),
            pw.Text("Transactions", style: pw.TextStyle(fontSize: 16)),
            pw.Table.fromTextArray(
              headers: [
                'Date',
                'Time',
                'Title',
                'Type',
                'Category',
                'Amount',
                'Note'
              ],
              data: pdfTable,
            ),
          ],
        ),
      );

      await pdfFile.writeAsBytes(await pdf.save());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("PDF exported to: ${pdfFile.path}")),
      );
    }
  }

  void showTransactionDetailsDialog({
    required BuildContext context,
    required String type,
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
        backgroundColor: Colors.white,
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
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        final selectedIndex = state.selectedIndex;
        final screens = [
          _buildDashboardContent(),
          BudgetScreen(
              onTabSelected: (i) =>
                  context.read<DashboardBloc>().add(DashboardTabChanged(i))),
          const ReportsScreen(),
          const DebtScreen(),
          const ProfileScreen(),
        ];

        return Scaffold(
          backgroundColor: const Color(0xFFEFF3F9),
          body: SafeArea(
            child: Stack(
              children: [
                screens[selectedIndex],
                if (selectedIndex == 0)
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
            currentIndex: selectedIndex,
            onTabSelected: (index) {
              context.read<DashboardBloc>().add(DashboardTabChanged(index));
            },
          ),
        );
      },
    );
  }

  Widget _buildDashboardContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: ListView(
        children: [
          const SizedBox(height: 16),

          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  CircleAvatar(
                    backgroundImage: NetworkImage(
                        "https://t3.ftcdn.net/jpg/02/99/04/20/360_F_299042079_vGBD7wIlSeNl7vOevWHiL93G4koMM967.jpg"),
                    radius: 22,
                  ),
                  SizedBox(width: 12),
                  Text(
                    "Hey, Abdullah!",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.notifications_outlined, size: 26),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationsScreen(),
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Dashboard Data
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
                        'icon': Icons.arrow_downward,
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
                        'icon': Icons.arrow_upward,
                        'category': null,
                      }),
                ];

                transactions.sort((a, b) =>
                    (b['date'] as DateTime).compareTo(a['date'] as DateTime));

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Balance
                    Text(
                      '\$${balance.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const Text("Total Balance",
                        style: TextStyle(color: Colors.black54)),
                    const SizedBox(height: 24),

                    // Stat Cards
                    Row(
                      children: [
                        _buildStatCard("Income", totalIncome, Colors.green),
                        const SizedBox(width: 16),
                        _buildStatCard("Expense", totalExpense, Colors.red),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // Recent Transactions Title Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Recent Transactions",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        TextButton.icon(
                          onPressed: () {
                            final state = context.read<DashboardBloc>().state;
                            if (state is DashboardLoaded) {
                              final allTransactions = [
                                ...state.expenses.map((e) => {
                                      'id': e.id,
                                      'type': 'expense',
                                      'title': e.title,
                                      'note': e.note,
                                      'rawAmount': e.amount,
                                      'date': e.date,
                                      'category': e.category,
                                    }),
                                ...state.incomes.map((i) => {
                                      'id': i.id,
                                      'type': 'income',
                                      'title': i.title,
                                      'note': i.note,
                                      'rawAmount': i.amount,
                                      'date': i.date,
                                      'category': null,
                                    }),
                              ];
                              allTransactions.sort((a, b) =>
                                  (b['date'] as DateTime)
                                      .compareTo(a['date'] as DateTime));
                              final totalIncome = state.incomes.fold<double>(
                                0,
                                (sum, item) => sum + item.amount,
                              );
                              final totalExpense = state.expenses.fold<double>(
                                0,
                                (sum, item) => sum + item.amount,
                              );
                              final balance = totalIncome - totalExpense;

                              _exportTransactions(allTransactions, totalIncome,
                                  totalExpense, balance);
                            }
                          },
                          icon: const Icon(Icons.file_download, size: 20),
                          label: const Text("Download"),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Transaction List
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
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => AddExpenseScreen(
                                              isEdit: true,
                                              id: tx['id'] as String,
                                              title: tx['title'] as String,
                                              amount: tx['rawAmount'] as double,
                                              note: tx['note'] as String,
                                              date: tx['date'] as DateTime,
                                              category:
                                                  tx['category'] as String,
                                            ),
                                          ),
                                        );
                                      } else {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => AddIncomeScreen(
                                              isEdit: true,
                                              id: tx['id'] as String,
                                              title: tx['title'] as String,
                                              amount: tx['rawAmount'] as double,
                                              note: tx['note'] as String,
                                              date: tx['date'] as DateTime,
                                            ),
                                          ),
                                        );
                                      }
                                      context
                                          .read<DashboardBloc>()
                                          .add(LoadUserExpenses());
                                    },
                                    onDelete: () async {
                                      if (tx['type'] == 'expense') {
                                        await ExpenseRepository()
                                            .deleteExpense(tx['id'] as String);
                                      } else {
                                        await IncomeRepository()
                                            .deleteIncome(tx['id'] as String);
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
