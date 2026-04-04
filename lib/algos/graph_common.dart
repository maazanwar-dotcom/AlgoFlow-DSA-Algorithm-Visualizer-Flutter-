import 'dart:math';

class GraphDefinition {
  final List<int> nodes;
  final Map<int, List<int>> adjacency;
  final Map<String, int> weights;
  final Map<int, int> heuristics;
  final int startNode;
  final int goalNode;

  const GraphDefinition({
    required this.nodes,
    required this.adjacency,
    required this.weights,
    this.heuristics = const <int, int>{},
    required this.startNode,
    required this.goalNode,
  });
}

String graphWeightKey(int a, int b) {
  final int left = min(a, b);
  final int right = max(a, b);
  return '$left-$right';
}

List<List<int>> graphEdgesFromAdjacency(Map<int, List<int>> adjacency) {
  final seen = <String>{};
  final edges = <List<int>>[];

  final fromNodes = adjacency.keys.toList()..sort();
  for (final from in fromNodes) {
    final neighbors = List<int>.from(adjacency[from] ?? const <int>[])..sort();
    for (final to in neighbors) {
      final key = graphWeightKey(from, to);
      if (seen.add(key)) {
        edges.add(<int>[from, to]);
      }
    }
  }

  return edges;
}

GraphDefinition traversalGraph() {
  return const GraphDefinition(
    nodes: <int>[0, 1, 2, 3, 4, 5, 6],
    adjacency: <int, List<int>>{
      0: <int>[1, 2],
      1: <int>[0, 3],
      2: <int>[0, 3, 4],
      3: <int>[1, 2, 5],
      4: <int>[2, 5, 6],
      5: <int>[3, 4, 6],
      6: <int>[4, 5],
    },
    weights: <String, int>{},
    startNode: 0,
    goalNode: 6,
  );
}

GraphDefinition generatedTraversalGraph(Random rnd) {
  final nodes = List<int>.generate(7, (index) => index);
  final adjacency = <int, List<int>>{for (final node in nodes) node: <int>[]};

  void connect(int a, int b) {
    if (a == b) return;
    if (!adjacency[a]!.contains(b)) {
      adjacency[a]!.add(b);
      adjacency[b]!.add(a);
    }
  }

  for (var node = 0; node < nodes.length - 1; node++) {
    connect(node, node + 1);
  }

  final extraEdges = <List<int>>[
    <int>[0, 2],
    <int>[1, 3],
    <int>[2, 4],
    <int>[3, 5],
    <int>[4, 6],
    <int>[0, 3],
    <int>[1, 4],
    <int>[2, 5],
    <int>[3, 6],
  ]..shuffle(rnd);

  for (final edge in extraEdges.take(3)) {
    connect(edge[0], edge[1]);
  }

  for (final node in nodes) {
    adjacency[node]!.sort();
  }

  return GraphDefinition(
    nodes: nodes,
    adjacency: adjacency,
    weights: const <String, int>{},
    startNode: 0,
    goalNode: 6,
  );
}

GraphDefinition weightedShortestPathGraph() {
  return GraphDefinition(
    nodes: const <int>[0, 1, 2, 3, 4, 5, 6],
    adjacency: const <int, List<int>>{
      0: <int>[1, 2],
      1: <int>[0, 2, 3],
      2: <int>[0, 1, 4],
      3: <int>[1, 4, 5],
      4: <int>[2, 3, 5, 6],
      5: <int>[3, 4, 6],
      6: <int>[4, 5],
    },
    weights: <String, int>{
      '0-1': 2,
      '0-2': 4,
      '1-2': 1,
      '1-3': 7,
      '2-4': 3,
      '3-4': 2,
      '3-5': 1,
      '4-5': 5,
      '4-6': 4,
      '5-6': 2,
    },
    heuristics: const <int, int>{0: 7, 1: 6, 2: 5, 3: 3, 4: 2, 5: 1, 6: 0},
    startNode: 0,
    goalNode: 6,
  );
}

GraphDefinition generatedWeightedShortestPathGraph(Random rnd) {
  final nodes = List<int>.generate(7, (index) => index);
  final adjacency = <int, List<int>>{for (final node in nodes) node: <int>[]};
  final weights = <String, int>{};

  void connect(int a, int b, {int? weight}) {
    if (a == b) return;
    if (!adjacency[a]!.contains(b)) {
      adjacency[a]!.add(b);
      adjacency[b]!.add(a);
    }
    weights[graphWeightKey(a, b)] = weight ?? (1 + rnd.nextInt(8));
  }

  for (var node = 0; node < nodes.length - 1; node++) {
    connect(node, node + 1, weight: 1 + rnd.nextInt(4));
  }

  final extraEdges = <List<int>>[
    <int>[0, 2],
    <int>[0, 3],
    <int>[1, 3],
    <int>[1, 4],
    <int>[2, 4],
    <int>[2, 5],
    <int>[3, 5],
    <int>[3, 6],
    <int>[4, 6],
  ]..shuffle(rnd);

  for (final edge in extraEdges.take(4)) {
    connect(edge[0], edge[1], weight: 2 + rnd.nextInt(6));
  }

  for (final node in nodes) {
    adjacency[node]!.sort();
  }

  return GraphDefinition(
    nodes: nodes,
    adjacency: adjacency,
    weights: weights,
    heuristics: const <int, int>{0: 7, 1: 6, 2: 5, 3: 3, 4: 2, 5: 1, 6: 0},
    startNode: 0,
    goalNode: 6,
  );
}
