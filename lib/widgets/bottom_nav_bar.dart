import 'package:flutter/material.dart';

getBottomNavBar(int index, ValueChanged<int> onTap) {
  return BottomNavigationBar(
    currentIndex: index,
    onTap: onTap,
    items: [
      BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Home"),
      BottomNavigationBarItem(
        icon: Icon(Icons.stacked_bar_chart),
        label: "Cataloug",
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.bookmark_border_outlined),
        label: "Saved",
      ),
    ],
  );
}
