import 'dart:math' as math;

import 'package:flutter/material.dart';

class TreeChart extends StatelessWidget {
  final Map<int, int> nodes;
  final int activeNodeIndex;
  final int targetValue;
  final int targetNodeIndex;
  final List<int> traversalPathIndices;
  final bool searchHit;
  final Duration animationDuration;

  const TreeChart({
    super.key,
    required this.nodes,
    this.activeNodeIndex = -1,
    this.targetValue = -1,
    this.targetNodeIndex = -1,
    this.traversalPathIndices = const <int>[],
    this.searchHit = false,
    this.animationDuration = const Duration(milliseconds: 450),
  });

  @override
  Widget build(BuildContext context) {
    if (nodes.isEmpty) {
      return const SizedBox(
        height: 180,
        child: Center(child: Text('No tree snapshot')),
      );
    }

    final indices = nodes.keys.toList()..sort();
    final maxDepth = _depthForIndex(indices.last);

    const double nodeRadius = 16;
    const double verticalSpacing = 64;
    final double chartHeight = ((maxDepth + 1) * verticalSpacing) + nodeRadius;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.of(context).size.width - 40;

        final positions = <int, Offset>{};
        for (final index in indices) {
          final depth = _depthForIndex(index);
          final levelStart = 1 << depth;
          final positionInLevel = index - levelStart;
          final slots = 1 << depth;

          final x = ((positionInLevel + 0.5) / slots) * width;
          final y = 20 + depth * verticalSpacing;
          positions[index] = Offset(x, y);
        }

        return SizedBox(
          height: chartHeight + 12,
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _TreeEdgesPainter(
                    positions: positions,
                    nodes: nodes,
                    nodeRadius: nodeRadius,
                    traversalPathIndices: traversalPathIndices,
                  ),
                ),
              ),
              for (final index in indices)
                AnimatedPositioned(
                  duration: animationDuration,
                  curve: Curves.easeOutCubic,
                  left: positions[index]!.dx - nodeRadius,
                  top: positions[index]!.dy - nodeRadius,
                  child: _TreeNode(
                    value: nodes[index]!,
                    radius: nodeRadius,
                    isActive: index == activeNodeIndex,
                    isTarget: index == targetNodeIndex,
                    isOnTraversalPath: traversalPathIndices.contains(index),
                    isHit: searchHit && index == activeNodeIndex,
                  ),
                ),
              if (targetValue >= 0)
                Positioned(
                  right: 6,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0x1AFFFFFF),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Text(
                      'Target: $targetValue',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  int _depthForIndex(int index) {
    if (index <= 1) return 0;
    return (math.log(index) / math.log(2)).floor();
  }
}

class _TreeNode extends StatelessWidget {
  final int value;
  final double radius;
  final bool isActive;
  final bool isTarget;
  final bool isOnTraversalPath;
  final bool isHit;

  const _TreeNode({
    required this.value,
    required this.radius,
    required this.isActive,
    required this.isTarget,
    required this.isOnTraversalPath,
    required this.isHit,
  });

  @override
  Widget build(BuildContext context) {
    final Color fill = isHit
        ? Colors.greenAccent
        : isActive && isTarget
        ? const Color(0xFFFFC84A)
        : isActive
        ? Colors.purpleAccent
        : isTarget
        ? Colors.orangeAccent
        : isOnTraversalPath
        ? const Color(0xFF3D4F70)
        : const Color(0xFF2F2542);
    final Color border = isHit
        ? Colors.green
        : isActive
        ? Colors.cyanAccent
        : isTarget
        ? const Color(0xFFFFAB40)
        : isOnTraversalPath
        ? const Color(0xFF7DD3FC)
        : Colors.white24;
    final Color textColor = (isActive || isTarget || isHit)
        ? Colors.black
        : Colors.white;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: fill,
        border: Border.all(color: border, width: 1.5),
      ),
      child: Center(
        child: Text(
          '$value',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

class _TreeEdgesPainter extends CustomPainter {
  final Map<int, Offset> positions;
  final Map<int, int> nodes;
  final double nodeRadius;
  final List<int> traversalPathIndices;

  _TreeEdgesPainter({
    required this.positions,
    required this.nodes,
    required this.nodeRadius,
    required this.traversalPathIndices,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final basePaint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;
    final pathPaint = Paint()
      ..color = const Color(0xFF7DD3FC)
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke;

    final visited = traversalPathIndices.toSet();

    for (final parentIndex in nodes.keys) {
      final parentPos = positions[parentIndex];
      if (parentPos == null) continue;

      for (final childIndex in <int>[parentIndex * 2, parentIndex * 2 + 1]) {
        if (!nodes.containsKey(childIndex)) continue;
        final childPos = positions[childIndex];
        if (childPos == null) continue;

        final bool isPathEdge =
            visited.contains(parentIndex) && visited.contains(childIndex);

        canvas.drawLine(
          Offset(parentPos.dx, parentPos.dy + nodeRadius * 0.65),
          Offset(childPos.dx, childPos.dy - nodeRadius * 0.65),
          isPathEdge ? pathPaint : basePaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TreeEdgesPainter oldDelegate) {
    return oldDelegate.positions != positions ||
        oldDelegate.nodes != nodes ||
        oldDelegate.nodeRadius != nodeRadius ||
        oldDelegate.traversalPathIndices != traversalPathIndices;
  }
}
