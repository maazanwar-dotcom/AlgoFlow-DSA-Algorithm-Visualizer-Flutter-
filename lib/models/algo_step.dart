enum AlgoStepType { compare, swap, overwrite, noSwap, done, unknown }

class AlgoStep {
  final List<int> numbersSnapshot;
  final String opertation;
  final int i;
  final int j;
  final AlgoStepType stepType;
  final Map<int, int> treeSnapshot;
  final List<List<int>> graphEdges;
  final Map<String, int> graphWeights;
  final Map<int, int> graphCosts;
  final List<int> frontierNodeIndices;
  final int activeNodeIndex;
  final int targetValue;
  final int targetNodeIndex;
  final List<int> traversalPathIndices;
  final bool searchHit;

  const AlgoStep({
    required this.numbersSnapshot,
    required this.opertation,
    required this.i,
    required this.j,
    this.stepType = AlgoStepType.unknown,
    this.treeSnapshot = const <int, int>{},
    this.graphEdges = const <List<int>>[],
    this.graphWeights = const <String, int>{},
    this.graphCosts = const <int, int>{},
    this.frontierNodeIndices = const <int>[],
    this.activeNodeIndex = -1,
    this.targetValue = -1,
    this.targetNodeIndex = -1,
    this.traversalPathIndices = const <int>[],
    this.searchHit = false,
  });
}
