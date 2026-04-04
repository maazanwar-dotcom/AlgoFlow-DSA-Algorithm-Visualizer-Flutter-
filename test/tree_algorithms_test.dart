import 'package:algo_visualizer/algos/avl_rotation.dart';
import 'package:algo_visualizer/algos/bfs_traversal.dart';
import 'package:algo_visualizer/algos/dfs_traversal.dart';
import 'package:algo_visualizer/models/algo_step.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('BFS traversal emits compare steps and completes', () {
    final bfs = BfsTraversal();

    final steps = bfs.performBfsTraversal(<int>[8, 4, 12, 2, 6, 10, 14]);

    expect(steps, isNotEmpty);
    expect(steps.any((s) => s.stepType == AlgoStepType.compare), isTrue);
    expect(steps.last.stepType, AlgoStepType.done);
    expect(steps.last.treeSnapshot, isNotEmpty);
    expect(steps.last.traversalPathIndices, isNotEmpty);
  });

  test('DFS traversal emits compare steps and completes', () {
    final dfs = DfsTraversal();

    final steps = dfs.performDfsTraversal(<int>[8, 4, 12, 2, 6, 10, 14]);

    expect(steps, isNotEmpty);
    expect(steps.any((s) => s.stepType == AlgoStepType.compare), isTrue);
    expect(steps.last.stepType, AlgoStepType.done);
    expect(steps.last.treeSnapshot, isNotEmpty);
    expect(steps.last.traversalPathIndices, isNotEmpty);
  });

  test('AVL rotation emits rotation steps and completes', () {
    final avl = AvlRotation();

    final steps = avl.performAvlRotation(<int>[10, 20, 30, 40, 50, 25]);

    expect(steps, isNotEmpty);
    expect(steps.any((s) => s.stepType == AlgoStepType.swap), isTrue);
    expect(steps.last.stepType, AlgoStepType.done);
    expect(steps.last.treeSnapshot, isNotEmpty);
  });
}
