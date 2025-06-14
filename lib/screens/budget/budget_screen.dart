import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../blocs/budget/budget_bloc.dart';
import '../../blocs/budget/budget_event.dart';
import '../../blocs/budget/budget_state.dart';
import '../../data/models/budget_model.dart';

class BudgetScreen extends StatefulWidget {
  final Function(int) onTabSelected;

  const BudgetScreen({
    super.key,
    required this.onTabSelected,
  });

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  @override
  void initState() {
    super.initState();
    context.read<BudgetBloc>().add(LoadBudgets());
  }

  void _showAddBudgetDialog() {
    final limitController = TextEditingController();
    final categories = ['Food', 'Transport', 'Shopping', 'Bills', 'Other'];
    String selectedCategory = categories.first;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Budget"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BlocBuilder<BudgetBloc, BudgetState>(
              builder: (context, state) {
                if (state is BudgetLoaded) {
                  // Filter out categories that already have budgets
                  final availableCategories = categories
                      .where((cat) => !state.budgets
                          .any((budget) => budget.category == cat))
                      .toList();

                  if (availableCategories.isEmpty) {
                    return const Text(
                      "All categories already have budgets assigned.",
                      style: TextStyle(color: Colors.red),
                    );
                  }

                  // Update selected category if current one is not available
                  if (!availableCategories.contains(selectedCategory)) {
                    selectedCategory = availableCategories.first;
                  }

                  return DropdownButtonFormField<String>(
                    value: selectedCategory,
                    items: availableCategories
                        .map((cat) => DropdownMenuItem(
                              value: cat,
                              child: Text(cat),
                            ))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) selectedCategory = val;
                    },
                    decoration: const InputDecoration(labelText: 'Category'),
                  );
                }
                return const CircularProgressIndicator();
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: limitController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Limit'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          BlocBuilder<BudgetBloc, BudgetState>(
            builder: (context, state) {
              if (state is BudgetLoaded) {
                final availableCategories = categories
                    .where((cat) =>
                        !state.budgets.any((budget) => budget.category == cat))
                    .toList();

                return ElevatedButton(
                  onPressed: availableCategories.isEmpty
                      ? null
                      : () {
                          final budget = BudgetModel(
                            id: const Uuid().v4(),
                            category: selectedCategory,
                            limit: double.tryParse(limitController.text) ?? 0,
                            createdAt: DateTime.now(),
                          );
                          context.read<BudgetBloc>().add(AddBudget(budget));
                          Navigator.pop(context);
                        },
                  child: const Text("Add"),
                );
              }
              return const SizedBox();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ListView(
              children: [
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      "Budgets",
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    Icon(Icons.notifications_outlined, size: 28),
                  ],
                ),
                const SizedBox(height: 24),
                BlocBuilder<BudgetBloc, BudgetState>(
                  builder: (context, state) {
                    if (state is BudgetLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is BudgetLoaded) {
                      if (state.budgets.isEmpty) {
                        return const Text("No budgets added yet.");
                      }

                      return Column(
                        children: state.budgets.map((budget) {
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                            color: Colors.white,
                            child: ListTile(
                              leading: const Icon(Icons.wallet),
                              title: Text(budget.category),
                              subtitle: Text("Limit: \$${budget.limit}"),
                              trailing: IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  context
                                      .read<BudgetBloc>()
                                      .add(DeleteBudget(budget.id));
                                },
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    } else if (state is BudgetFailure) {
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

          // FAB
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.add, size: 28),
              onPressed: _showAddBudgetDialog,
            ),
          ),
        ],
      ),
    );
  }
}
