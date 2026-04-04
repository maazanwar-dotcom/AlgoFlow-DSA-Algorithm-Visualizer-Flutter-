import 'dart:math';

import 'package:algo_visualizer/models/algo_step.dart';

class _BstNode {
  final int value;
  final int index;
  _BstNode? left;
  _BstNode? right;

  _BstNode({required this.value, required this.index});
}

class BstSearch {
  final List<AlgoStep> steps = [];

  List<AlgoStep> performBstSearch(List<int> numbers) {
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
    final target = _pickTarget(values);
    final snapshot = _treeSnapshot(root);
    final targetNodeIndex = _findNodeIndexByValue(snapshot, target);
    final visitedPath = <int>[];

    _BstNode? current = root;
    while (current != null) {
      if (visitedPath.isEmpty || visitedPath.last != current.index) {
        visitedPath.add(current.index);
      }

      steps.add(
        AlgoStep(
          numbersSnapshot: List<int>.from(values),
          opertation: 'Compare target $target with node ${current.value}',
          i: current.index,
          j: -1,
          stepType: AlgoStepType.compare,
          treeSnapshot: Map<int, int>.from(snapshot),
          activeNodeIndex: current.index,
          targetValue: target,
          targetNodeIndex: targetNodeIndex,
          traversalPathIndices: List<int>.from(visitedPath),
        ),
      );

      if (target == current.value) {
        steps.add(
          AlgoStep(
            numbersSnapshot: List<int>.from(values),
            opertation: 'Target $target found at node ${current.value}',
            i: current.index,
            j: -1,
            stepType: AlgoStepType.done,
            treeSnapshot: Map<int, int>.from(snapshot),
            activeNodeIndex: current.index,
            targetValue: target,
            targetNodeIndex: targetNodeIndex,
            traversalPathIndices: List<int>.from(visitedPath),
            searchHit: true,
          ),
        );
        return steps;
      }

      final goLeft = target < current.value;
      steps.add(
        AlgoStep(
          numbersSnapshot: List<int>.from(values),
          opertation: goLeft
              ? 'Target $target is smaller, move to left child'
              : 'Target $target is greater, move to right child',
          i: current.index,
          j: -1,
          stepType: AlgoStepType.noSwap,
          treeSnapshot: Map<int, int>.from(snapshot),
          activeNodeIndex: current.index,
          targetValue: target,
          targetNodeIndex: targetNodeIndex,
          traversalPathIndices: List<int>.from(visitedPath),
        ),
      );

      current = goLeft ? current.left : current.right;
    }

    steps.add(
      AlgoStep(
        numbersSnapshot: List<int>.from(values),
        opertation: 'Target $target not found in BST',
        i: -1,
        j: -1,
        stepType: AlgoStepType.done,
        treeSnapshot: Map<int, int>.from(snapshot),
        activeNodeIndex: -1,
        targetValue: target,
        targetNodeIndex: targetNodeIndex,
        traversalPathIndices: List<int>.from(visitedPath),
        searchHit: false,
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

  int _pickTarget(List<int> values) {
    final sum = values.fold<int>(0, (prev, value) => prev + value);
    if (sum.isEven) {
      return values[sum % values.length];
    }

    int candidate = values.reduce(max) + 7;
    final existing = values.toSet();
    while (existing.contains(candidate)) {
      candidate++;
    }
    return candidate;
  }

  _BstNode _buildTree(List<int> values) {
    final root = _BstNode(value: values.first, index: 1);

    for (int i = 1; i < values.length; i++) {
      _insert(root, values[i]);
    }

    return root;
  }

  void _insert(_BstNode node, int value) {
    if (value < node.value) {
      if (node.left == null) {
        node.left = _BstNode(value: value, index: node.index * 2);
      } else {
        _insert(node.left!, value);
      }
      return;
    }

    if (node.right == null) {
      node.right = _BstNode(value: value, index: node.index * 2 + 1);
    } else {
      _insert(node.right!, value);
    }
  }

  Map<int, int> _treeSnapshot(_BstNode? root) {
    if (root == null) return <int, int>{};
    final snapshot = <int, int>{};

    void walk(_BstNode? node) {
      if (node == null) return;
      snapshot[node.index] = node.value;
      walk(node.left);
      walk(node.right);
    }

    walk(root);
    return snapshot;
  }

  int _findNodeIndexByValue(Map<int, int> snapshot, int value) {
    for (final entry in snapshot.entries) {
      if (entry.value == value) return entry.key;
    }
    return -1;
  }
}
