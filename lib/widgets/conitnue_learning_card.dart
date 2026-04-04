import 'package:flutter/material.dart';

class ConitnueLearningCard extends StatelessWidget {
  final Icon icon;
  final String complexity;
  final String algorithm;
  final double completionValue;
  final String completionText;
  final VoidCallback? onTap;

  const ConitnueLearningCard({
    super.key,
    required this.icon,
    required this.complexity,
    required this.algorithm,
    required this.completionValue,
    required this.completionText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 232,
      height: 156,
      child: Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    icon,
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        complexity,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  algorithm,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                Spacer(),
                LinearProgressIndicator(
                  value: completionValue,
                  color: Colors.purpleAccent,
                ),
                SizedBox(height: 8),
                Text(
                  completionText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
