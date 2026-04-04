import 'package:algo_visualizer/algos/bst_search.dart';
import 'package:algo_visualizer/models/algo_step.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('BST search emits compare steps and ends with found target', () {
    final bst = BstSearch();
    final input = <int>[8, 4, 12, 2, 6];

    final steps = bst.performBstSearch(List<int>.from(input));

    expect(steps, isNotEmpty);
    expect(steps.any((s) => s.stepType == AlgoStepType.compare), isTrue);
    expect(steps.last.stepType, AlgoStepType.done);
    expect(steps.last.searchHit, isTrue);
    expect(steps.last.treeSnapshot, isNotEmpty);
    expect(steps.last.targetValue, equals(12));
    expect(steps.last.targetNodeIndex, greaterThan(0));
    expect(steps.last.traversalPathIndices, isNotEmpty);
  });
}
