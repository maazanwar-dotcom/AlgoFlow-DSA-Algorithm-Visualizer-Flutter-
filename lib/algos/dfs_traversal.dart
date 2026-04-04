import 'package:algo_visualizer/models/algo_step.dart';

class _DfsNode {
  final int value;
  final int index;
  _DfsNode? left;
  _DfsNode? right;

  _DfsNode({required this.value, required this.index});
}

class DfsTraversal {
  final List<AlgoStep> steps = [];

  List<AlgoStep> performDfsTraversal(List<int> numbers) {
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

    final stack = <_DfsNode>[root];
    final visitedPath = <int>[];

    while (stack.isNotEmpty) {
      final node = stack.removeLast();
      visitedPath.add(node.index);

      steps.add(
        AlgoStep(
          numbersSnapshot: List<int>.from(values),
          opertation: 'Visit node ${node.value} (DFS preorder)',
          i: node.index,
          j: -1,
          stepType: AlgoStepType.compare,
          treeSnapshot: Map<int, int>.from(snapshot),
          activeNodeIndex: node.index,
          traversalPathIndices: List<int>.from(visitedPath),
        ),
      );

      if (node.right != null) {
        stack.add(node.right!);
        steps.add(
          AlgoStep(
            numbersSnapshot: List<int>.from(values),
            opertation: 'Push right child ${node.right!.value} to stack',
            i: node.right!.index,
            j: -1,
            stepType: AlgoStepType.noSwap,
            treeSnapshot: Map<int, int>.from(snapshot),
            activeNodeIndex: node.right!.index,
            traversalPathIndices: List<int>.from(visitedPath),
          ),
        );
      }

      if (node.left != null) {
        stack.add(node.left!);
        steps.add(
          AlgoStep(
            numbersSnapshot: List<int>.from(values),
            opertation: 'Push left child ${node.left!.value} to stack',
            i: node.left!.index,
            j: -1,
            stepType: AlgoStepType.noSwap,
            treeSnapshot: Map<int, int>.from(snapshot),
            activeNodeIndex: node.left!.index,
            traversalPathIndices: List<int>.from(visitedPath),
          ),
        );
      }
    }

    steps.add(
      AlgoStep(
        numbersSnapshot: List<int>.from(values),
        opertation: 'DFS traversal complete',
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

  _DfsNode _buildTree(List<int> values) {
    final root = _DfsNode(value: values.first, index: 1);

    for (int i = 1; i < values.length; i++) {
      _insert(root, values[i]);
    }

    return root;
  }

  void _insert(_DfsNode node, int value) {
    if (value < node.value) {
      if (node.left == null) {
        node.left = _DfsNode(value: value, index: node.index * 2);
      } else {
        _insert(node.left!, value);
      }
      return;
    }

    if (node.right == null) {
      node.right = _DfsNode(value: value, index: node.index * 2 + 1);
    } else {
      _insert(node.right!, value);
    }
  }

  Map<int, int> _treeSnapshot(_DfsNode? root) {
    if (root == null) return <int, int>{};
    final snapshot = <int, int>{};

    void walk(_DfsNode? node) {
      if (node == null) return;
      snapshot[node.index] = node.value;
      walk(node.left);
      walk(node.right);
    }

    walk(root);
    return snapshot;
  }
}
