import 'package:flutter/material.dart';

class BalanceCard extends StatelessWidget {
  const BalanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
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
              children: const [
                Text("Income", style: TextStyle(color: Colors.black54)),
                SizedBox(height: 4),
                Text("\$2,450.00",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Icon(Icons.arrow_upward, color: Colors.green),
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
              children: const [
                Text("Expense", style: TextStyle(color: Colors.black54)),
                SizedBox(height: 4),
                Text("-\$710.00",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Icon(Icons.arrow_downward, color: Colors.red),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
