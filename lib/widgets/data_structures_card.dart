import 'package:flutter/material.dart';

class DataStructuresCard extends StatelessWidget {
  final String title;
  final String subTitle;
  final Icon icon;
  final Color color;
  final VoidCallback? onTap;
  const DataStructuresCard({
    super.key,
    required this.title,
    required this.subTitle,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: color,
                ),
                child: Padding(padding: const EdgeInsets.all(5.0), child: icon),
              ),
              SizedBox(height: 10),
              Text(title, style: TextStyle(fontSize: 16)),
              SizedBox(height: 5),
              Text(
                subTitle,
                style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
