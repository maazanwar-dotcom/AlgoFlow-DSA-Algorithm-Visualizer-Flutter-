import 'package:algo_visualizer/algos/graph_common.dart';
import 'package:algo_visualizer/models/algo_step.dart';

class GraphBfs {
  final List<AlgoStep> steps = [];

  List<AlgoStep> performGraphBfs([GraphDefinition? graph]) {
    steps.clear();

    final currentGraph = graph ?? traversalGraph();
    final nodesMap = {for (final node in currentGraph.nodes) node: node};
    final edges = graphEdgesFromAdjacency(currentGraph.adjacency);

    final queue = <int>[currentGraph.startNode];
    final visited = <int>{currentGraph.startNode};
    final visitedOrder = <int>[];

    steps.add(
      AlgoStep(
        numbersSnapshot: List<int>.from(currentGraph.nodes),
        opertation:
            'Initialize queue with start node ${currentGraph.startNode}',
        i: currentGraph.startNode,
        j: -1,
        stepType: AlgoStepType.overwrite,
        treeSnapshot: Map<int, int>.from(nodesMap),
        graphEdges: edges,
        frontierNodeIndices: List<int>.from(queue),
        activeNodeIndex: currentGraph.startNode,
      ),
    );

    while (queue.isNotEmpty) {
      final current = queue.removeAt(0);
      visitedOrder.add(current);

      steps.add(
        AlgoStep(
          numbersSnapshot: List<int>.from(currentGraph.nodes),
          opertation: 'Visit node $current and explore its neighbors',
          i: current,
          j: -1,
          stepType: AlgoStepType.compare,
          treeSnapshot: Map<int, int>.from(nodesMap),
          graphEdges: edges,
          frontierNodeIndices: List<int>.from(queue),
          activeNodeIndex: current,
          traversalPathIndices: List<int>.from(visitedOrder),
        ),
      );

      final neighbors = List<int>.from(
        currentGraph.adjacency[current] ?? const <int>[],
      )..sort();
      for (final neighbor in neighbors) {
        if (visited.contains(neighbor)) continue;

        visited.add(neighbor);
        queue.add(neighbor);

        steps.add(
          AlgoStep(
            numbersSnapshot: List<int>.from(currentGraph.nodes),
            opertation: 'Discovered node $neighbor, enqueue for later visit',
            i: current,
            j: neighbor,
            stepType: AlgoStepType.noSwap,
            treeSnapshot: Map<int, int>.from(nodesMap),
            graphEdges: edges,
            frontierNodeIndices: List<int>.from(queue),
            activeNodeIndex: neighbor,
            traversalPathIndices: List<int>.from(visitedOrder),
          ),
        );
      }
    }

    steps.add(
      AlgoStep(
        numbersSnapshot: List<int>.from(currentGraph.nodes),
        opertation: 'Graph BFS complete',
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
