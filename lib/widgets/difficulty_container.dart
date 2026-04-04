import 'package:algo_visualizer/models/algorithms.dart';
import 'package:flutter/material.dart';

Widget getDifficulty(Difficulty difficulty) {
  // choose colors based on difficulty
  final String d = difficulty.toString().split('.').last;
  final Color bgColor = d == 'easy'
      ? const Color.fromARGB(123, 71, 180, 77)
      : d == 'medium'
      ? Color(0xFF0D2130)
      : d == 'hard'
      ? const Color.fromARGB(118, 255, 0, 0)
      : Color.fromARGB(255, 13, 33, 48);
  final Color borderColor = d == 'easy'
      ? Colors.greenAccent
      : d == 'medium'
      ? Color(0x6D00EEFF)
      : d == 'hard'
      ? Colors.redAccent
      : Color.fromARGB(110, 0, 238, 255);
  final Color textColor = Colors.white;

  return Container(
    width: 90,
    height: 30,
    decoration: BoxDecoration(
      color: bgColor,
      border: Border.all(color: borderColor),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Center(
      child: Text(
        difficulty.toString().split('.').last.toUpperCase(),
        style: TextStyle(color: textColor),
      ),
    ),
  );
}
