import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/expense_repository.dart';
import '../../data/repositories/income_repository.dart';
import '../../data/models/expense_model.dart';
import '../../blocs/reports/reports_bloc.dart';
import '../../blocs/reports/reports_event.dart';
import '../../blocs/reports/reports_state.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  Map<String, double> _categoryTotals(List<ExpenseModel> expenses) {
    final Map<String, double> totals = {};
    for (var e in expenses) {
      totals[e.category] = (totals[e.category] ?? 0) + e.amount;
    }
    return totals;
  }

  List<BarChartGroupData> _barChartData(List<ExpenseModel> expenses) {
    final Map<int, double> dailyTotals = {};
    for (var e in expenses) {
      int day = e.date.day;
      dailyTotals[day] = (dailyTotals[day] ?? 0) + e.amount;
    }

    return dailyTotals.entries.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: entry.value,
            color: Colors.blue,
            width: 10,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList()
      ..sort((a, b) => a.x.compareTo(b.x));
  }

  @override
  Widget build(BuildContext context) {
    final DateTime currentMonth =
        DateTime(DateTime.now().year, DateTime.now().month);

    return BlocProvider(
      create: (_) => ReportsBloc(
        expenseRepository: ExpenseRepository(),
        incomeRepository: IncomeRepository(),
      )..add(LoadReports(month: currentMonth)),
      child: BlocBuilder<ReportsBloc, ReportsState>(
        builder: (context, state) {
          if (state is ReportsLoading || state is ReportsInitial) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (state is ReportsLoaded) {
            final expenses = state.expenses;
            final incomes = state.incomes;
            final categoryData = _categoryTotals(expenses);
            final barGroups = _barChartData(expenses);
            final totalExpense = expenses.fold(0.0, (sum, e) => sum + e.amount);
            final totalIncome = incomes.fold(0.0, (sum, i) => sum + i.amount);
            final balance = totalIncome - totalExpense;
            final double maxY = barGroups.isEmpty
                ? 10
                : barGroups
                        .map((e) => e.barRods.first.toY)
                        .reduce((a, b) => a > b ? a : b) +
                    10;

            return Scaffold(
              backgroundColor: const Color(0xFFEFF3F9),
              body: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ListView(
                    children: [
                      const SizedBox(height: 16),
                      const Text(
                        "Reports",
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Month: ${DateFormat.yMMM().format(currentMonth)}",
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 20),

                      // Summary Section
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 4)
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _summaryTile("Income", totalIncome, Colors.green),
                              _summaryTile("Expense", totalExpense, Colors.red),
                              _summaryTile(
                                  "Balance",
                                  balance,
                                  balance >= 0
                                      ? Colors.blue
                                      : Colors.redAccent),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Category Breakdown
                      const Text("Category Breakdown",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      categoryData.isEmpty
                          ? const Text("No expenses this month.")
                          : Column(
                              children: categoryData.entries.map((e) {
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: const [
                                      BoxShadow(
                                          color: Colors.black12, blurRadius: 4)
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.label_outline,
                                              size: 20, color: Colors.grey),
                                          const SizedBox(width: 8),
                                          Text(e.key,
                                              style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500)),
                                        ],
                                      ),
                                      Text("\$${e.value.toStringAsFixed(2)}",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),

                      const SizedBox(height: 32),

                      // Spending Trend
                      const Text("Spending Trend",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      barGroups.isEmpty
                          ? const Text("No data to display.")
                          : SizedBox(
                              height: 220,
                              child: BarChart(
                                BarChartData(
                                  barGroups: barGroups,
                                  gridData: FlGridData(show: true),
                                  borderData: FlBorderData(show: false),
                                  maxY: maxY,
                                  alignment: BarChartAlignment.start,
                                  titlesData: FlTitlesData(
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        interval: 1,
                                        getTitlesWidget: (value, meta) {
                                          return Padding(
                                            padding:
                                                const EdgeInsets.only(top: 6),
                                            child: Text(
                                              value.toInt().toString(),
                                              style:
                                                  const TextStyle(fontSize: 10),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 28,
                                        interval: maxY > 50 ? 20 : 10,
                                        getTitlesWidget: (value, _) => Text(
                                          "\$${value.toInt()}",
                                          style: const TextStyle(fontSize: 10),
                                        ),
                                      ),
                                    ),
                                    topTitles: AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    rightTitles: AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            );
          } else if (state is ReportsError) {
            return Scaffold(
              body: Center(child: Text("Error: ${state.message}")),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _summaryTile(String label, double amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 14, color: Colors.black54)),
        const SizedBox(height: 4),
        Text(
          "\$${amount.toStringAsFixed(2)}",
          style: TextStyle(
              fontWeight: FontWeight.w600, fontSize: 16, color: color),
        ),
      ],
    );
  }
}
