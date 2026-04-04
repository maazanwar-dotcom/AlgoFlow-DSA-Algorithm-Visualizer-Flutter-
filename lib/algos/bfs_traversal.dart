import 'package:algo_visualizer/models/algo_step.dart';

class _BfsNode {
  final int value;
  final int index;
  _BfsNode? left;
  _BfsNode? right;

  _BfsNode({required this.value, required this.index});
}

class BfsTraversal {
  final List<AlgoStep> steps = [];

  List<AlgoStep> performBfsTraversal(List<int> numbers) {
    steps.clear();

    final values = _uniqueValues(numbers);
    if (values.isEmpty) {
      steps.add(
        const AlgoStep(
          numbersSnapshot: <int>[],
          opertation: 'Tree is empty',
          i: -1,
          j: -1,
          stepType: AlgoStepType.done,
        ),
      );
      return steps;
    }

    final root = _buildTree(values);
    final snapshot = _treeSnapshot(root);

    final queue = <_BfsNode>[root];
    final visitedPath = <int>[];

    while (queue.isNotEmpty) {
      final node = queue.removeAt(0);
      visitedPath.add(node.index);

      steps.add(
        AlgoStep(
          numbersSnapshot: List<int>.from(values),
          opertation: 'Visit node ${node.value} from queue',
          i: node.index,
          j: -1,
          stepType: AlgoStepType.compare,
          treeSnapshot: Map<int, int>.from(snapshot),
          activeNodeIndex: node.index,
          traversalPathIndices: List<int>.from(visitedPath),
        ),
      );

      if (node.left != null) {
        queue.add(node.left!);
        steps.add(
          AlgoStep(
            numbersSnapshot: List<int>.from(values),
            opertation: 'Queue left child ${node.left!.value}',
            i: node.left!.index,
            j: -1,
            stepType: AlgoStepType.noSwap,
            treeSnapshot: Map<int, int>.from(snapshot),
            activeNodeIndex: node.left!.index,
            traversalPathIndices: List<int>.from(visitedPath),
          ),
        );
      }

      if (node.right != null) {
        queue.add(node.right!);
        steps.add(
          AlgoStep(
            numbersSnapshot: List<int>.from(values),
            opertation: 'Queue right child ${node.right!.value}',
            i: node.right!.index,
            j: -1,
            stepType: AlgoStepType.noSwap,
            treeSnapshot: Map<int, int>.from(snapshot),
            activeNodeIndex: node.right!.index,
            traversalPathIndices: List<int>.from(visitedPath),
          ),
        );
      }
    }

    steps.add(
      AlgoStep(
        numbersSnapshot: List<int>.from(values),
        opertation: 'BFS traversal complete',
        i: -1,
        j: -1,
        stepType: AlgoStepType.done,
        treeSnapshot: Map<int, int>.from(snapshot),
        activeNodeIndex: -1,
        traversalPathIndices: List<int>.from(visitedPath),
      ),
    );

    return steps;
  }

  List<int> _uniqueValues(List<int> numbers) {
    final set = <int>{};
    final values = <int>[];
    for (final value in numbers) {
      if (set.add(value)) {
        values.add(value);
      }
    }
    return values;
  }

  _BfsNode _buildTree(List<int> values) {
    final root = _BfsNode(value: values.first, index: 1);

    for (int i = 1; i < values.length; i++) {
      _insert(root, values[i]);
    }

    return root;
  }

  void _insert(_BfsNode node, int value) {
    if (value < node.value) {
      if (node.left == null) {
        node.left = _BfsNode(value: value, index: node.index * 2);
      } else {
        _insert(node.left!, value);
      }
      return;
    }

    if (node.right == null) {
      node.right = _BfsNode(value: value, index: node.index * 2 + 1);
    } else {
      _insert(node.right!, value);
    }
  }

  Map<int, int> _treeSnapshot(_BfsNode? root) {
    if (root == null) return <int, int>{};
    final snapshot = <int, int>{};

    void walk(_BfsNode? node) {
      if (node == null) return;
      snapshot[node.index] = node.value;
      walk(node.left);
      walk(node.right);
    }

    walk(root);
    return snapshot;
  }
}
