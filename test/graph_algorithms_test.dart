import 'package:algo_visualizer/algos/a_star_pathfinding.dart';
import 'package:algo_visualizer/algos/dijkstra_shortest_path.dart';
import 'package:algo_visualizer/algos/graph_common.dart';
import 'package:algo_visualizer/algos/graph_bfs.dart';
import 'package:algo_visualizer/algos/graph_dfs.dart';
import 'package:algo_visualizer/models/algo_step.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Graph BFS emits traversal steps and completes', () {
    final steps = GraphBfs().performGraphBfs(traversalGraph());

    expect(steps, isNotEmpty);
    expect(steps.any((s) => s.stepType == AlgoStepType.compare), isTrue);
    expect(steps.last.stepType, AlgoStepType.done);
    expect(steps.last.graphEdges, isNotEmpty);
    expect(steps.last.traversalPathIndices, isNotEmpty);
  });

  test('Graph DFS emits traversal steps and completes', () {
    final steps = GraphDfs().performGraphDfs(traversalGraph());

    expect(steps, isNotEmpty);
    expect(steps.any((s) => s.stepType == AlgoStepType.compare), isTrue);
    expect(steps.last.stepType, AlgoStepType.done);
    expect(steps.last.graphEdges, isNotEmpty);
    expect(steps.last.traversalPathIndices, isNotEmpty);
  });

  test('Dijkstra computes shortest path to goal', () {
    final steps = DijkstraShortestPath().performDijkstra(
      weightedShortestPathGraph(),
    );

    expect(steps, isNotEmpty);
    expect(steps.any((s) => s.stepType == AlgoStepType.overwrite), isTrue);
    expect(steps.last.stepType, AlgoStepType.done);
    expect(steps.last.searchHit, isTrue);
    expect(steps.last.targetNodeIndex, equals(6));
    expect(steps.last.targetValue, greaterThanOrEqualTo(0));
    expect(steps.last.traversalPathIndices, isNotEmpty);
  });

  test('A* computes goal-directed shortest path', () {
    final steps = AStarPathfinding().performAStar(weightedShortestPathGraph());

    expect(steps, isNotEmpty);
    expect(steps.any((s) => s.stepType == AlgoStepType.compare), isTrue);
    expect(steps.last.stepType, AlgoStepType.done);
    expect(steps.last.searchHit, isTrue);
    expect(steps.last.targetNodeIndex, equals(6));
    expect(steps.last.targetValue, greaterThanOrEqualTo(0));
    expect(steps.last.traversalPathIndices, isNotEmpty);
  });
}
