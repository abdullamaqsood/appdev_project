import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabSelected;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      height: 70,
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: const Icon(Icons.home),
            color: currentIndex == 0 ? Colors.blue : Colors.black,
            onPressed: () => onTabSelected(0),
          ),
          IconButton(
            icon: const Icon(Icons.pie_chart),
            color: currentIndex == 1 ? Colors.blue : Colors.black,
            onPressed: () => onTabSelected(1),
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            color: currentIndex == 2 ? Colors.blue : Colors.black,
            onPressed: () => onTabSelected(2),
          ),
          IconButton(
            icon: const Icon(Icons.credit_card),
            color: currentIndex == 3 ? Colors.blue : Colors.black,
            onPressed: () => onTabSelected(3),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            color: currentIndex == 4 ? Colors.blue : Colors.black,
            onPressed: () => onTabSelected(4),
          ),
        ],
      ),
    );
  }
}
