import 'package:algo_visualizer/algos/graph_common.dart';
import 'package:algo_visualizer/models/algo_step.dart';

class GraphDfs {
  final List<AlgoStep> steps = [];

  List<AlgoStep> performGraphDfs([GraphDefinition? graph]) {
    steps.clear();

    final currentGraph = graph ?? traversalGraph();
    final nodesMap = {for (final node in currentGraph.nodes) node: node};
    final edges = graphEdgesFromAdjacency(currentGraph.adjacency);

    final stack = <int>[currentGraph.startNode];
    final visited = <int>{currentGraph.startNode};
    final visitedOrder = <int>[];

    steps.add(
      AlgoStep(
        numbersSnapshot: List<int>.from(currentGraph.nodes),
        opertation:
            'Initialize stack with start node ${currentGraph.startNode}',
        i: currentGraph.startNode,
        j: -1,
        stepType: AlgoStepType.overwrite,
        treeSnapshot: Map<int, int>.from(nodesMap),
        graphEdges: edges,
        frontierNodeIndices: List<int>.from(stack),
        activeNodeIndex: currentGraph.startNode,
      ),
    );

    while (stack.isNotEmpty) {
      final current = stack.removeLast();
      visitedOrder.add(current);

      steps.add(
        AlgoStep(
          numbersSnapshot: List<int>.from(currentGraph.nodes),
          opertation: 'Visit node $current and dive deeper',
          i: current,
          j: -1,
          stepType: AlgoStepType.compare,
          treeSnapshot: Map<int, int>.from(nodesMap),
          graphEdges: edges,
          frontierNodeIndices: List<int>.from(stack),
          activeNodeIndex: current,
          traversalPathIndices: List<int>.from(visitedOrder),
        ),
      );

      final neighbors = List<int>.from(
        currentGraph.adjacency[current] ?? const <int>[],
      )..sort();
      for (int i = neighbors.length - 1; i >= 0; i--) {
        final neighbor = neighbors[i];
        if (visited.contains(neighbor)) continue;

        visited.add(neighbor);
        stack.add(neighbor);

        steps.add(
          AlgoStep(
            numbersSnapshot: List<int>.from(currentGraph.nodes),
            opertation: 'Push node $neighbor on stack for DFS exploration',
            i: current,
            j: neighbor,
            stepType: AlgoStepType.noSwap,
            treeSnapshot: Map<int, int>.from(nodesMap),
            graphEdges: edges,
            frontierNodeIndices: List<int>.from(stack),
            activeNodeIndex: neighbor,
            traversalPathIndices: List<int>.from(visitedOrder),
          ),
        );
      }
    }

    steps.add(
      AlgoStep(
        numbersSnapshot: List<int>.from(currentGraph.nodes),
        opertation: 'Graph DFS complete',
        i: -1,
        j: -1,
        stepType: AlgoStepType.done,
        treeSnapshot: Map<int, int>.from(nodesMap),
        graphEdges: edges,
        activeNodeIndex: -1,
        traversalPathIndices: List<int>.from(visitedOrder),
        searchHit: true,
      ),
    );

    return steps;
  }
}
