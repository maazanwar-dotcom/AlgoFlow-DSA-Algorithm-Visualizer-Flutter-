import 'package:algo_visualizer/algos/merge_sort.dart';
import 'package:algo_visualizer/models/algo_step.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Merge sort produces sorted final snapshot and overwrite steps', () {
    final sorter = MergeSort();
    final input = <int>[8, 4, 5, 2, 1, 9, 3];

    final steps = sorter.performMergeSort(List<int>.from(input));

    expect(steps, isNotEmpty);
    expect(steps.last.stepType, AlgoStepType.done);
    expect(steps.last.numbersSnapshot, <int>[1, 2, 3, 4, 5, 8, 9]);
    expect(steps.any((s) => s.stepType == AlgoStepType.compare), isTrue);
    expect(steps.any((s) => s.stepType == AlgoStepType.overwrite), isTrue);
  });
}
