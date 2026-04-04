import 'dart:math';

import 'package:algo_visualizer/algos/graph_common.dart';
import 'package:algo_visualizer/models/algo_step.dart';

class DijkstraShortestPath {
  final List<AlgoStep> steps = [];

  List<AlgoStep> performDijkstra([GraphDefinition? graph]) {
    steps.clear();

    final currentGraph = graph ?? weightedShortestPathGraph();
    final nodesMap = {for (final node in currentGraph.nodes) node: node};
    final edges = graphEdgesFromAdjacency(currentGraph.adjacency);
    final weights = Map<String, int>.from(currentGraph.weights);

    const int inf = 1 << 28;
    final dist = {for (final node in currentGraph.nodes) node: inf};
    final previous = <int, int>{};
    final unvisited = Set<int>.from(currentGraph.nodes);
    final settledOrder = <int>[];

    dist[currentGraph.startNode] = 0;

    steps.add(
      AlgoStep(
        numbersSnapshot: List<int>.from(currentGraph.nodes),
        opertation:
            'Initialize distances from source ${currentGraph.startNode} (distance 0 at source)',
        i: currentGraph.startNode,
        j: -1,
        stepType: AlgoStepType.overwrite,
        treeSnapshot: Map<int, int>.from(nodesMap),
        graphEdges: edges,
        graphWeights: weights,
        graphCosts: _finiteCosts(dist, inf),
        frontierNodeIndices: _sorted(unvisited),
        activeNodeIndex: currentGraph.startNode,
        targetNodeIndex: currentGraph.goalNode,
      ),
    );

    while (unvisited.isNotEmpty) {
      int? current;
      int currentDist = inf;
      for (final node in unvisited) {
        final d = dist[node] ?? inf;
        if (d < currentDist) {
          currentDist = d;
          current = node;
        }
      }

      if (current == null || currentDist == inf) {
        break;
      }

      unvisited.remove(current);
      settledOrder.add(current);

      steps.add(
        AlgoStep(
          numbersSnapshot: List<int>.from(currentGraph.nodes),
          opertation:
              'Pick node $current with smallest tentative distance $currentDist',
          i: current,
          j: -1,
          stepType: AlgoStepType.compare,
          treeSnapshot: Map<int, int>.from(nodesMap),
          graphEdges: edges,
          graphWeights: weights,
          graphCosts: _finiteCosts(dist, inf),
          frontierNodeIndices: _sorted(unvisited),
          activeNodeIndex: current,
          targetNodeIndex: currentGraph.goalNode,
          traversalPathIndices: List<int>.from(settledOrder),
        ),
      );

      if (current == currentGraph.goalNode) {
        break;
      }

      final neighbors = List<int>.from(
        currentGraph.adjacency[current] ?? const <int>[],
      )..sort();
      for (final neighbor in neighbors) {
        if (!unvisited.contains(neighbor)) continue;

        final weight = _weight(weights, current, neighbor);
        final candidate = (dist[current] ?? inf) + weight;

        steps.add(
          AlgoStep(
            numbersSnapshot: List<int>.from(currentGraph.nodes),
            opertation:
                'Relax edge $current -> $neighbor with weight $weight (candidate $candidate)',
            i: current,
            j: neighbor,
            stepType: AlgoStepType.compare,
            treeSnapshot: Map<int, int>.from(nodesMap),
            graphEdges: edges,
            graphWeights: weights,
            graphCosts: _finiteCosts(dist, inf),
            frontierNodeIndices: _sorted(unvisited),
            activeNodeIndex: current,
            targetNodeIndex: currentGraph.goalNode,
            traversalPathIndices: List<int>.from(settledOrder),
          ),
        );

        if (candidate < (dist[neighbor] ?? inf)) {
          dist[neighbor] = candidate;
          previous[neighbor] = current;

          steps.add(
            AlgoStep(
              numbersSnapshot: List<int>.from(currentGraph.nodes),
              opertation:
                  'Updated shortest distance of node $neighbor to $candidate via $current',
              i: current,
              j: neighbor,
              stepType: AlgoStepType.overwrite,
              treeSnapshot: Map<int, int>.from(nodesMap),
              graphEdges: edges,
              graphWeights: weights,
              graphCosts: _finiteCosts(dist, inf),
              frontierNodeIndices: _sorted(unvisited),
              activeNodeIndex: neighbor,
              targetNodeIndex: currentGraph.goalNode,
              traversalPathIndices: List<int>.from(settledOrder),
            ),
          );
        } else {
          steps.add(
            AlgoStep(
              numbersSnapshot: List<int>.from(currentGraph.nodes),
              opertation:
                  'No improvement for node $neighbor (best remains ${dist[neighbor]})',
              i: current,
              j: neighbor,
              stepType: AlgoStepType.noSwap,
              treeSnapshot: Map<int, int>.from(nodesMap),
              graphEdges: edges,
              graphWeights: weights,
              graphCosts: _finiteCosts(dist, inf),
              frontierNodeIndices: _sorted(unvisited),
              activeNodeIndex: neighbor,
              targetNodeIndex: currentGraph.goalNode,
              traversalPathIndices: List<int>.from(settledOrder),
            ),
          );
        }
      }
    }

    final bool found = (dist[currentGraph.goalNode] ?? inf) < inf;
    final shortestPath = found
        ? _reconstructPath(
            previous,
            currentGraph.startNode,
            currentGraph.goalNode,
          )
        : <int>[];

    steps.add(
      AlgoStep(
        numbersSnapshot: List<int>.from(currentGraph.nodes),
        opertation: found
            ? 'Shortest path found with distance ${dist[currentGraph.goalNode]}: ${shortestPath.join(' -> ')}'
            : 'Goal node ${currentGraph.goalNode} is unreachable from source ${currentGraph.startNode}',
        i: found ? currentGraph.goalNode : -1,
        j: -1,
        stepType: AlgoStepType.done,
        treeSnapshot: Map<int, int>.from(nodesMap),
        graphEdges: edges,
        graphWeights: weights,
        graphCosts: _finiteCosts(dist, inf),
        activeNodeIndex: found ? currentGraph.goalNode : -1,
        targetNodeIndex: currentGraph.goalNode,
        targetValue: found ? (dist[currentGraph.goalNode] ?? -1) : -1,
        traversalPathIndices: found
            ? shortestPath
            : List<int>.from(settledOrder),
        searchHit: found,
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

  Map<int, int> _finiteCosts(Map<int, int> dist, int inf) {
    final costs = <int, int>{};
    for (final entry in dist.entries) {
      if (entry.value >= inf) continue;
      costs[entry.key] = max(0, entry.value);
    }
    return costs;
  }
}
