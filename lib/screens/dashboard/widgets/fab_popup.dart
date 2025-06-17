import 'package:flutter/material.dart';

Future<String?> showIncomeExpensePopup(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    backgroundColor: Colors.white,
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                "Choose an option",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading:
                  const Icon(Icons.remove_circle_outline, color: Colors.red),
              title: const Text('Add Expense',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              onTap: () {
                Navigator.pop(context, 'expense');
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.add_circle_outline, color: Colors.green),
              title: const Text('Add Income',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              onTap: () {
                Navigator.pop(context, 'income');
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}
