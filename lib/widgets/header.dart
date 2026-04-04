import 'package:flutter/material.dart';

Widget getHeader(String text, {VoidCallback? onSettingsTap}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(text, style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
      Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Color(0x9E2E243F),
          borderRadius: BorderRadius.circular(60),
        ),
        child: IconButton(
          onPressed: onSettingsTap,
          icon: Icon(Icons.settings, size: 22),
        ),
      ),
    ],
  );
}
