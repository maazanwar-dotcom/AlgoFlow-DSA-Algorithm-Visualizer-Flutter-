import 'dart:math';

import 'package:algo_visualizer/models/algo_step.dart';

class _AvlNode {
  final int value;
  int height = 1;
  int index = 1;
  _AvlNode? left;
  _AvlNode? right;

  _AvlNode({required this.value});
}

class _RotationEvent {
  final String caseName;
  final int pivotValue;
  final int newRootValue;

  const _RotationEvent({
    required this.caseName,
    required this.pivotValue,
    required this.newRootValue,
  });
}

class _InsertTrace {
  final _AvlNode? root;
  final bool inserted;
  final List<int> visitedValues;
  final List<_RotationEvent> rotations;

  const _InsertTrace({
    required this.root,
    required this.inserted,
    required this.visitedValues,
    required this.rotations,
  });
}

class AvlRotation {
  final List<AlgoStep> steps = [];

  List<AlgoStep> performAvlRotation(List<int> numbers) {
    steps.clear();

    final insertionOrder = _prepareValues(numbers);
    if (insertionOrder.isEmpty) {
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

    _AvlNode? root;

    for (final value in insertionOrder) {
      final trace = _insertAndRebalance(root, value);
      root = trace.root;

      if (!trace.inserted || root == null) {
        continue;
      }

      _assignIndices(root, 1);
      final snapshot = _treeSnapshot(root);
      final pathIndices = <int>[];

      for (final visitedValue in trace.visitedValues) {
        final index = _findIndexByValue(snapshot, visitedValue);
        if (index < 0) continue;
        if (pathIndices.isEmpty || pathIndices.last != index) {
          pathIndices.add(index);
        }

        steps.add(
          AlgoStep(
            numbersSnapshot: List<int>.from(insertionOrder),
            opertation: 'Compare insert value $value with node $visitedValue',
            i: index,
            j: -1,
            stepType: AlgoStepType.compare,
            treeSnapshot: Map<int, int>.from(snapshot),
            activeNodeIndex: index,
            traversalPathIndices: List<int>.from(pathIndices),
          ),
        );
      }

      final insertedIndex = _findIndexByValue(snapshot, value);
      final insertionPath =
          insertedIndex >= 0 && !pathIndices.contains(insertedIndex)
          ? <int>[...pathIndices, insertedIndex]
          : List<int>.from(pathIndices);

      steps.add(
        AlgoStep(
          numbersSnapshot: List<int>.from(insertionOrder),
          opertation: 'Insert $value and update heights',
          i: insertedIndex,
          j: -1,
          stepType: AlgoStepType.overwrite,
          treeSnapshot: Map<int, int>.from(snapshot),
          activeNodeIndex: insertedIndex,
          traversalPathIndices: insertionPath,
        ),
      );

      for (final rotation in trace.rotations) {
        final rotationIndex = _findIndexByValue(
          snapshot,
          rotation.newRootValue,
        );
        steps.add(
          AlgoStep(
            numbersSnapshot: List<int>.from(insertionOrder),
            opertation:
                '${rotation.caseName} rotation at node ${rotation.pivotValue}',
            i: rotationIndex,
            j: -1,
            stepType: AlgoStepType.swap,
            treeSnapshot: Map<int, int>.from(snapshot),
            activeNodeIndex: rotationIndex,
            traversalPathIndices: insertionPath,
          ),
        );
      }
    }

    if (root != null) {
      _assignIndices(root, 1);
    }
    final finalSnapshot = _treeSnapshot(root);
    final finalTraversal = finalSnapshot.keys.toList()..sort();

    steps.add(
      AlgoStep(
        numbersSnapshot: List<int>.from(insertionOrder),
        opertation: 'AVL insertion and rotations complete',
        i: -1,
        j: -1,
        stepType: AlgoStepType.done,
        treeSnapshot: Map<int, int>.from(finalSnapshot),
        activeNodeIndex: -1,
        traversalPathIndices: finalTraversal,
      ),
    );

    return steps;
  }

  List<int> _prepareValues(List<int> numbers) {
    final seen = <int>{};
    final unique = <int>[];
    for (final value in numbers) {
      if (seen.add(value)) {
        unique.add(value);
      }
    }

    if (unique.isEmpty) {
      return unique;
    }

    unique.sort();
    while (unique.length < 6) {
      unique.add(unique.last + 7);
    }

    if (unique.length < 6) {
      return unique;
    }

    final ordered = <int>[];
    final used = <int>{};

    void pushAt(int index) {
      if (index < 0 || index >= unique.length) return;
      final value = unique[index];
      if (used.add(value)) {
        ordered.add(value);
      }
    }

    pushAt(2);
    pushAt(1);
    pushAt(0);
    pushAt(3);
    pushAt(4);
    pushAt(5);

    for (int i = 6; i < unique.length; i++) {
      pushAt(i);
    }

    return ordered;
  }

  _InsertTrace _insertAndRebalance(_AvlNode? root, int value) {
    if (root == null) {
      return _InsertTrace(
        root: _AvlNode(value: value),
        inserted: true,
        visitedValues: const <int>[],
        rotations: const <_RotationEvent>[],
      );
    }

    final visitedValues = <int>[];
    final path = <_AvlNode>[];
    _AvlNode? current = root;

    while (current != null) {
      visitedValues.add(current.value);
      path.add(current);

      if (value < current.value) {
        if (current.left == null) {
          current.left = _AvlNode(value: value);
          path.add(current.left!);
          break;
        }
        current = current.left;
      } else if (value > current.value) {
        if (current.right == null) {
          current.right = _AvlNode(value: value);
          path.add(current.right!);
          break;
        }
        current = current.right;
      } else {
        return _InsertTrace(
          root: root,
          inserted: false,
          visitedValues: visitedValues,
          rotations: const <_RotationEvent>[],
        );
      }
    }

    final rotations = <_RotationEvent>[];

    for (int i = path.length - 2; i >= 0; i--) {
      final node = path[i];
      _updateHeight(node);

      final balance = _balance(node);
      final parent = i > 0 ? path[i - 1] : null;
      _AvlNode newSubRoot = node;
      String? caseName;

      if (balance > 1 && node.left != null && value < node.left!.value) {
        newSubRoot = _rightRotate(node);
        caseName = 'LL';
      } else if (balance < -1 &&
          node.right != null &&
          value > node.right!.value) {
        newSubRoot = _leftRotate(node);
        caseName = 'RR';
      } else if (balance > 1 && node.left != null && value > node.left!.value) {
        node.left = _leftRotate(node.left!);
        newSubRoot = _rightRotate(node);
        caseName = 'LR';
      } else if (balance < -1 &&
          node.right != null &&
          value < node.right!.value) {
        node.right = _rightRotate(node.right!);
        newSubRoot = _leftRotate(node);
        caseName = 'RL';
      }

      if (caseName != null) {
        if (parent == null) {
          root = newSubRoot;
        } else if (identical(parent.left, node)) {
          parent.left = newSubRoot;
        } else if (identical(parent.right, node)) {
          parent.right = newSubRoot;
        }

        rotations.add(
          _RotationEvent(
            caseName: caseName,
            pivotValue: node.value,
            newRootValue: newSubRoot.value,
          ),
        );
        path[i] = newSubRoot;
      }
    }

    if (root != null) {
      _updateAllHeights(root);
    }

    return _InsertTrace(
      root: root,
      inserted: true,
      visitedValues: visitedValues,
      rotations: rotations,
    );
  }

  int _height(_AvlNode? node) => node?.height ?? 0;

  void _updateHeight(_AvlNode node) {
    node.height = 1 + max(_height(node.left), _height(node.right));
  }

  int _balance(_AvlNode? node) {
    if (node == null) return 0;
    return _height(node.left) - _height(node.right);
  }

  _AvlNode _leftRotate(_AvlNode x) {
    final y = x.right!;
    final t2 = y.left;

    y.left = x;
    x.right = t2;

    _updateHeight(x);
    _updateHeight(y);

    return y;
  }

  _AvlNode _rightRotate(_AvlNode y) {
    final x = y.left!;
    final t2 = x.right;

    x.right = y;
    y.left = t2;

    _updateHeight(y);
    _updateHeight(x);

    return x;
  }

  void _updateAllHeights(_AvlNode? node) {
    if (node == null) return;
    _updateAllHeights(node.left);
    _updateAllHeights(node.right);
    _updateHeight(node);
  }

  void _assignIndices(_AvlNode? node, int index) {
    if (node == null) return;
    node.index = index;
    _assignIndices(node.left, index * 2);
    _assignIndices(node.right, index * 2 + 1);
  }

  Map<int, int> _treeSnapshot(_AvlNode? root) {
    if (root == null) return <int, int>{};
    final snapshot = <int, int>{};

    void walk(_AvlNode? node) {
      if (node == null) return;
      snapshot[node.index] = node.value;
      walk(node.left);
      walk(node.right);
    }

    walk(root);
    return snapshot;
  }

  int _findIndexByValue(Map<int, int> snapshot, int value) {
    for (final entry in snapshot.entries) {
      if (entry.value == value) return entry.key;
    }
    return -1;
  }
}
