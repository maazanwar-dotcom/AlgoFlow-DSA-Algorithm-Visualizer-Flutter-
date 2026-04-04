import 'package:flutter/material.dart';

categoryPill(String label, bool isSelected, onTap) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(30),
      color: isSelected ? Colors.purple : Color(0xFF1B1429),
      border: isSelected
          ? Border.all(color: Colors.purpleAccent, width: 2)
          : Border.all(color: Color(0xFF2E243F), width: 2),
    ),
    child: GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(top: 8, bottom: 8, left: 20, right: 20),
        child: Text(label),
      ),
    ),
  );
}
