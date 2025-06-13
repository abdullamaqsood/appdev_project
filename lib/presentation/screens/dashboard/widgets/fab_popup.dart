import 'package:flutter/material.dart';

Future<String?> showIncomeExpensePopup(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.remove_circle_outline),
            title: const Text('Add Expense'),
            onTap: () {
              Navigator.pop(context, 'expense');
            },
          ),
          ListTile(
            leading: const Icon(Icons.add_circle_outline),
            title: const Text('Add Income'),
            onTap: () {
              Navigator.pop(context, 'income');
            },
          ),
        ],
      );
    },
  );
}
