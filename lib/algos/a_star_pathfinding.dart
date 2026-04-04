import 'dart:math';

import 'package:algo_visualizer/algos/graph_common.dart';
import 'package:algo_visualizer/models/algo_step.dart';

class AStarPathfinding {
  final List<AlgoStep> steps = [];

  List<AlgoStep> performAStar([GraphDefinition? graph]) {
    steps.clear();

    final currentGraph = graph ?? weightedShortestPathGraph();
    final nodesMap = {for (final node in currentGraph.nodes) node: node};
    final edges = graphEdgesFromAdjacency(currentGraph.adjacency);
    final weights = Map<String, int>.from(currentGraph.weights);

    const int inf = 1 << 28;
    final heuristics = currentGraph.heuristics.isNotEmpty
        ? currentGraph.heuristics
        : const <int, int>{0: 7, 1: 6, 2: 5, 3: 3, 4: 2, 5: 1, 6: 0};

    final gScore = {for (final node in currentGraph.nodes) node: inf};
    final fScore = {for (final node in currentGraph.nodes) node: inf};
    final cameFrom = <int, int>{};
    final openSet = <int>{currentGraph.startNode};
    final closedSet = <int>{};
    final visitOrder = <int>[];

    gScore[currentGraph.startNode] = 0;
    fScore[currentGraph.startNode] = heuristics[currentGraph.startNode] ?? 0;

    steps.add(
      AlgoStep(
        numbersSnapshot: List<int>.from(currentGraph.nodes),
        opertation:
            'Initialize A* with start node ${currentGraph.startNode} and heuristic estimates',
        i: currentGraph.startNode,
        j: -1,
        stepType: AlgoStepType.overwrite,
        treeSnapshot: Map<int, int>.from(nodesMap),
        graphEdges: edges,
        graphWeights: weights,
        graphCosts: _finiteCosts(gScore, inf),
        frontierNodeIndices: _sorted(openSet),
        activeNodeIndex: currentGraph.startNode,
        targetNodeIndex: currentGraph.goalNode,
      ),
    );

    while (openSet.isNotEmpty) {
      int? current;
      int bestScore = inf;
      for (final node in openSet) {
        final score = fScore[node] ?? inf;
        if (score < bestScore) {
          bestScore = score;
          current = node;
        }
      }

      if (current == null) {
        break;
      }

      steps.add(
        AlgoStep(
          numbersSnapshot: List<int>.from(currentGraph.nodes),
          opertation:
              'Choose node $current from open set (lowest f-score $bestScore)',
          i: current,
          j: -1,
          stepType: AlgoStepType.compare,
          treeSnapshot: Map<int, int>.from(nodesMap),
          graphEdges: edges,
          graphWeights: weights,
          graphCosts: _finiteCosts(gScore, inf),
          frontierNodeIndices: _sorted(openSet),
          activeNodeIndex: current,
          targetNodeIndex: currentGraph.goalNode,
          traversalPathIndices: List<int>.from(visitOrder),
        ),
      );

      if (current == currentGraph.goalNode) {
        final path = _reconstructPath(
          cameFrom,
          currentGraph.startNode,
          currentGraph.goalNode,
        );

        steps.add(
          AlgoStep(
            numbersSnapshot: List<int>.from(currentGraph.nodes),
            opertation:
                'A* reached goal ${currentGraph.goalNode} with cost ${gScore[currentGraph.goalNode]}: ${path.join(' -> ')}',
            i: currentGraph.goalNode,
            j: -1,
            stepType: AlgoStepType.done,
            treeSnapshot: Map<int, int>.from(nodesMap),
            graphEdges: edges,
            graphWeights: weights,
            graphCosts: _finiteCosts(gScore, inf),
            frontierNodeIndices: _sorted(openSet),
            activeNodeIndex: currentGraph.goalNode,
            targetNodeIndex: currentGraph.goalNode,
            targetValue: gScore[currentGraph.goalNode] ?? -1,
            traversalPathIndices: path,
            searchHit: true,
          ),
        );
        return steps;
      }

      openSet.remove(current);
      closedSet.add(current);
      visitOrder.add(current);

      final neighbors = List<int>.from(
        currentGraph.adjacency[current] ?? const <int>[],
      )..sort();
      for (final neighbor in neighbors) {
        if (closedSet.contains(neighbor)) continue;

        final tentative =
            (gScore[current] ?? inf) + _weight(weights, current, neighbor);

        steps.add(
          AlgoStep(
            numbersSnapshot: List<int>.from(currentGraph.nodes),
            opertation:
                'Evaluate edge $current -> $neighbor (tentative g-score $tentative)',
            i: current,
            j: neighbor,
            stepType: AlgoStepType.compare,
            treeSnapshot: Map<int, int>.from(nodesMap),
            graphEdges: edges,
            graphWeights: weights,
            graphCosts: _finiteCosts(gScore, inf),
            frontierNodeIndices: _sorted(openSet),
            activeNodeIndex: current,
            targetNodeIndex: currentGraph.goalNode,
            traversalPathIndices: List<int>.from(visitOrder),
          ),
        );

        if (tentative < (gScore[neighbor] ?? inf)) {
          cameFrom[neighbor] = current;
          gScore[neighbor] = tentative;
          fScore[neighbor] = tentative + (heuristics[neighbor] ?? 0);
          openSet.add(neighbor);

          steps.add(
            AlgoStep(
              numbersSnapshot: List<int>.from(currentGraph.nodes),
              opertation:
                  'Update node $neighbor: g=${gScore[neighbor]}, f=${fScore[neighbor]} via $current',
              i: current,
              j: neighbor,
              stepType: AlgoStepType.overwrite,
              treeSnapshot: Map<int, int>.from(nodesMap),
              graphEdges: edges,
              graphWeights: weights,
              graphCosts: _finiteCosts(gScore, inf),
              frontierNodeIndices: _sorted(openSet),
              activeNodeIndex: neighbor,
              targetNodeIndex: currentGraph.goalNode,
              traversalPathIndices: List<int>.from(visitOrder),
            ),
          );
        } else {
          steps.add(
            AlgoStep(
              numbersSnapshot: List<int>.from(currentGraph.nodes),
              opertation:
                  'Skip update for node $neighbor (existing path is better)',
              i: current,
              j: neighbor,
              stepType: AlgoStepType.noSwap,
              treeSnapshot: Map<int, int>.from(nodesMap),
              graphEdges: edges,
              graphWeights: weights,
              graphCosts: _finiteCosts(gScore, inf),
              frontierNodeIndices: _sorted(openSet),
              activeNodeIndex: neighbor,
              targetNodeIndex: currentGraph.goalNode,
              traversalPathIndices: List<int>.from(visitOrder),
            ),
          );
        }
      }
    }

    steps.add(
      AlgoStep(
        numbersSnapshot: List<int>.from(currentGraph.nodes),
        opertation:
            'A* could not find a path from ${currentGraph.startNode} to ${currentGraph.goalNode}',
        i: -1,
        j: -1,
        stepType: AlgoStepType.done,
        treeSnapshot: Map<int, int>.from(nodesMap),
        graphEdges: edges,
        graphWeights: weights,
        graphCosts: _finiteCosts(gScore, inf),
        activeNodeIndex: -1,
        targetNodeIndex: currentGraph.goalNode,
        targetValue: -1,
        traversalPathIndices: List<int>.from(visitOrder),
        searchHit: false,
      ),
    );

    return steps;
  }

  int _weight(Map<String, int> weights, int from, int to) {
    return weights[graphWeightKey(from, to)] ?? 1;
  }

  List<int> _reconstructPath(Map<int, int> previous, int start, int goal) {
    final path = <int>[];
    int? current = goal;

    while (current != null) {
      path.add(current);
      if (current == start) break;
      current = previous[current];
    }

    if (path.isEmpty || path.last != start) {
      return <int>[];
    }

    return path.reversed.toList();
  }

  List<int> _sorted(Set<int> values) {
    final list = values.toList()..sort();
    return list;
  }

  Map<int, int> _finiteCosts(Map<int, int> costs, int inf) {
    final finite = <int, int>{};
    for (final entry in costs.entries) {
      if (entry.value >= inf) continue;
      finite[entry.key] = max(0, entry.value);
    }
    return finite;
  }
}
