import 'dart:math' as math;

import 'package:algo_visualizer/algos/graph_common.dart';
import 'package:flutter/material.dart';

class GraphChart extends StatelessWidget {
  final Map<int, int> nodes;
  final List<List<int>> edges;
  final Map<String, int> weights;
  final Map<int, int> costs;
  final List<int> traversalPathIndices;
  final List<int> frontierNodeIndices;
  final int activeNodeIndex;
  final int targetNodeIndex;
  final int activeEdgeFrom;
  final int activeEdgeTo;
  final bool searchHit;
  final Duration animationDuration;

  const GraphChart({
    super.key,
    required this.nodes,
    required this.edges,
    this.weights = const <String, int>{},
    this.costs = const <int, int>{},
    this.traversalPathIndices = const <int>[],
    this.frontierNodeIndices = const <int>[],
    this.activeNodeIndex = -1,
    this.targetNodeIndex = -1,
    this.activeEdgeFrom = -1,
    this.activeEdgeTo = -1,
    this.searchHit = false,
    this.animationDuration = const Duration(milliseconds: 450),
  });

  @override
  Widget build(BuildContext context) {
    if (nodes.isEmpty) {
      return const SizedBox(
        height: 190,
        child: Center(child: Text('No graph snapshot')),
      );
    }

    final nodeIndices = nodes.keys.toList()..sort();

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.of(context).size.width - 40;
        const double chartHeight = 235;
        final radius = math.max(30.0, math.min(width, chartHeight) * 0.34);
        final center = Offset(width / 2, chartHeight / 2);

        final positions = <int, Offset>{};
        for (int i = 0; i < nodeIndices.length; i++) {
          final node = nodeIndices[i];
          final angle =
              (-math.pi / 2) + ((2 * math.pi * i) / nodeIndices.length);
          positions[node] = Offset(
            center.dx + radius * math.cos(angle),
            center.dy + radius * math.sin(angle),
          );
        }

        return SizedBox(
          height: chartHeight,
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _GraphEdgesPainter(
                    positions: positions,
                    edges: edges,
                    weights: weights,
                    activeEdgeFrom: activeEdgeFrom,
                    activeEdgeTo: activeEdgeTo,
                    traversalPathIndices: traversalPathIndices,
                    nodeRadius: 16,
                  ),
                ),
              ),
              for (final node in nodeIndices)
                AnimatedPositioned(
                  duration: animationDuration,
                  curve: Curves.easeOutCubic,
                  left: positions[node]!.dx - 20,
                  top: positions[node]!.dy - 20,
                  child: _GraphNode(
                    label: _labelFor(nodes[node]!),
                    cost: costs[node],
                    isActive: node == activeNodeIndex,
                    isTarget: node == targetNodeIndex,
                    isVisited: traversalPathIndices.contains(node),
                    isFrontier: frontierNodeIndices.contains(node),
                    isHit: searchHit && node == targetNodeIndex,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  String _labelFor(int value) {
    if (value >= 0 && value <= 25) {
      return String.fromCharCode(65 + value);
    }
    return '$value';
  }
}

class _GraphNode extends StatelessWidget {
  final String label;
  final int? cost;
  final bool isActive;
  final bool isTarget;
  final bool isVisited;
  final bool isFrontier;
  final bool isHit;

  const _GraphNode({
    required this.label,
    required this.cost,
    required this.isActive,
    required this.isTarget,
    required this.isVisited,
    required this.isFrontier,
    required this.isHit,
  });

  @override
  Widget build(BuildContext context) {
    final fill = isHit
        ? Colors.greenAccent
        : isActive
        ? Colors.purpleAccent
        : isTarget
        ? Colors.orangeAccent
        : isFrontier
        ? Colors.cyanAccent
        : isVisited
        ? const Color(0xFF455E85)
        : const Color(0xFF2F2542);

    final border = isActive
        ? Colors.cyanAccent
        : isTarget
        ? const Color(0xFFFFB74D)
        : Colors.white24;

    final textColor = (isActive || isTarget || isHit || isFrontier)
        ? Colors.black
        : Colors.white;

    return SizedBox(
      width: 40,
      height: 56,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: fill,
              border: Border.all(color: border, width: 1.6),
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            cost == null ? '' : 'd:$cost',
            style: const TextStyle(fontSize: 9, color: Colors.white60),
          ),
        ],
      ),
    );
  }
}

class _GraphEdgesPainter extends CustomPainter {
  final Map<int, Offset> positions;
  final List<List<int>> edges;
  final Map<String, int> weights;
  final int activeEdgeFrom;
  final int activeEdgeTo;
  final List<int> traversalPathIndices;
  final double nodeRadius;

  _GraphEdgesPainter({
    required this.positions,
    required this.edges,
    required this.weights,
    required this.activeEdgeFrom,
    required this.activeEdgeTo,
    required this.traversalPathIndices,
    required this.nodeRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final basePaint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 1.3
      ..style = PaintingStyle.stroke;

    final pathPaint = Paint()
      ..color = Colors.purpleAccent
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke;

    final activePaint = Paint()
      ..color = Colors.cyanAccent
      ..strokeWidth = 2.6
      ..style = PaintingStyle.stroke;

    final pathEdgeKeys = <String>{};
    for (int i = 0; i < traversalPathIndices.length - 1; i++) {
      pathEdgeKeys.add(
        graphWeightKey(traversalPathIndices[i], traversalPathIndices[i + 1]),
      );
    }

    for (final edge in edges) {
      if (edge.length != 2) continue;
      final from = edge[0];
      final to = edge[1];
      final fromPos = positions[from];
      final toPos = positions[to];
      if (fromPos == null || toPos == null) continue;

      final isActiveEdge =
          (from == activeEdgeFrom && to == activeEdgeTo) ||
          (from == activeEdgeTo && to == activeEdgeFrom);
      final isPathEdge = pathEdgeKeys.contains(graphWeightKey(from, to));

      final paint = isActiveEdge
          ? activePaint
          : isPathEdge
          ? pathPaint
          : basePaint;

      canvas.drawLine(
        _trimPoint(fromPos, toPos, nodeRadius * 0.6),
        _trimPoint(toPos, fromPos, nodeRadius * 0.6),
        paint,
      );

      final weight = weights[graphWeightKey(from, to)];
      if (weight != null) {
        final mid = Offset(
          (fromPos.dx + toPos.dx) / 2,
          (fromPos.dy + toPos.dy) / 2,
        );
        _paintWeight(canvas, mid, '$weight');
      }
    }
  }

  Offset _trimPoint(Offset from, Offset to, double trim) {
    final dx = to.dx - from.dx;
    final dy = to.dy - from.dy;
    final dist = math.sqrt(dx * dx + dy * dy);
    if (dist == 0) return from;
    return Offset(from.dx + (dx / dist) * trim, from.dy + (dy / dist) * trim);
  }

  void _paintWeight(Canvas canvas, Offset offset, String text) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          fontSize: 9,
          color: Colors.white70,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final bgRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: offset,
        width: painter.width + 8,
        height: painter.height + 4,
      ),
      const Radius.circular(6),
    );

    final bgPaint = Paint()..color = const Color(0xB0100A19);
    canvas.drawRRect(bgRect, bgPaint);

    painter.paint(
      canvas,
      Offset(offset.dx - painter.width / 2, offset.dy - painter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _GraphEdgesPainter oldDelegate) {
    return oldDelegate.positions != positions ||
        oldDelegate.edges != edges ||
        oldDelegate.weights != weights ||
        oldDelegate.activeEdgeFrom != activeEdgeFrom ||
        oldDelegate.activeEdgeTo != activeEdgeTo ||
        oldDelegate.traversalPathIndices != traversalPathIndices ||
        oldDelegate.nodeRadius != nodeRadius;
  }
}
