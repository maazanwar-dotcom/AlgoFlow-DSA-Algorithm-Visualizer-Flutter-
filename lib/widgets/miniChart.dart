import 'dart:math' as math;

import 'package:algo_visualizer/widgets/miniBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class Minichart extends StatelessWidget {
  final List<int> numbers;
  final Color defaultColor;
  final Color highlightenedColor;
  final Color secondHighLightColor;
  final int highlightIndex;
  final Set<int> highlightIndices;
  final Map<int, Color> highLightMap;
  final Map<int, String> markerLabels;
  final Duration animationDuration;
  final Duration colorAnimationDuration;
  const Minichart({
    super.key,
    required this.numbers,
    this.defaultColor = const Color(0xFF2F2542),
    this.highlightenedColor = Colors.cyan,
    this.secondHighLightColor = Colors.purple,
    this.highlightIndex = -1,
    this.highlightIndices = const {},
    this.highLightMap = const {},
    this.markerLabels = const {},
    this.animationDuration = const Duration(milliseconds: 500),
    this.colorAnimationDuration = const Duration(milliseconds: 750),
  });

  @override
  Widget build(BuildContext context) {
    if (numbers.isEmpty) {
      return const SizedBox(height: 180, child: Center(child: Text('No data')));
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final maxWidth = constraints.maxWidth;

        const double barSpacing = 4;
        final int numBars = numbers.length;
        final double totalSpacing = (numBars - 1) * barSpacing;
        final double availableWidth = maxWidth - 40;
        final double rawBarWidth = (availableWidth - totalSpacing) / numBars;
        final bool shouldScroll = rawBarWidth < 8;
        final double barWidth = shouldScroll ? 8 : rawBarWidth;
        final int maxvalue = numbers.isEmpty
            ? 1
            : numbers.reduce((a, b) => a > b ? a : b);

        const double maxBarHeight = 150.0;
        const double minBarHeight = 4.0;
        final bool showAllLabels = numBars <= 20;

        Widget chartRow = Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (int i = 0; i < numbers.length; i++) ...[
              SizedBox(
                width: barWidth,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      height: 18,
                      child: markerLabels.containsKey(i)
                          ? FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: highLightMap[i] ?? Colors.white24,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  markerLabels[i]!,
                                  style: const TextStyle(
                                    fontSize: 9,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            )
                          : null,
                    ),
                    SizedBox(
                      height: 16,
                      child: (showAllLabels || highLightMap.containsKey(i))
                          ? FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                '${numbers[i]}',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: highLightMap[i] ?? Colors.white70,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            )
                          : null,
                    ),
                    SizedBox(height: 2),
                    Minibar(
                      height: numbers[i] == 0
                          ? minBarHeight
                          : (numbers[i] / maxvalue) *
                                    (maxBarHeight - minBarHeight) +
                                minBarHeight,
                      width: barWidth,
                      color: highLightMap[i] ?? defaultColor,
                      animationDuration: animationDuration,
                      colorAnimationDuration: colorAnimationDuration,
                    ),
                    SizedBox(height: 4),
                    SizedBox(
                      height: 14,
                      child: (showAllLabels || highLightMap.containsKey(i))
                          ? FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                '$i',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: highLightMap[i] ?? Colors.white54,
                                ),
                              ),
                            )
                          : null,
                    ),
                  ],
                ),
              ),
              if (i < numbers.length - 1) SizedBox(width: barSpacing),
            ],
          ],
        );

        if (shouldScroll) {
          final double contentWidth = math.max(
            maxWidth,
            (barWidth * numBars) + totalSpacing,
          );
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(width: contentWidth, child: chartRow),
          );
        }

        return chartRow;
      },
    );
  }

  /* return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (int i = 0; i < numbers.length; i++)
          Minibar(
            height: numbers[i].toDouble(),
            width: ,
            color: highLightMap[i] ?? defaultColor,
          ),
      ],
    ); */
}
