import 'package:flutter/material.dart';

class TransactionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? category;
  final String subtitle;
  final String amount;
  final String date;
  final Color amountColor;
  final VoidCallback? onTap;

  const TransactionTile({
    super.key,
    required this.icon,
    required this.title,
    this.category,
    required this.subtitle,
    required this.amount,
    required this.date,
    required this.amountColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final String displayTitle = category != null && category!.isNotEmpty
        ? "$title (${category!})"
        : title;

    return GestureDetector(
      onTap: onTap,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 4),
        leading: CircleAvatar(
          backgroundColor: Colors.grey.shade200,
          child: Icon(icon, color: Colors.black),
        ),
        title: Text(displayTitle,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(amount,
                style:
                    TextStyle(color: amountColor, fontWeight: FontWeight.w600)),
            Text(date,
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
