import 'package:flutter/material.dart';

class BottomBar extends StatelessWidget {
  final int currentIndex;
  final void Function(int index) onTap;
  const BottomBar({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Ana Sayfa'),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Geçmiş'),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'İstatistik'),
      ],
      currentIndex: currentIndex,
      onTap: onTap,
    );
  }
}
