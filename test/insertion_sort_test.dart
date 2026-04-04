import 'package:algo_visualizer/algos/insertion_sort.dart';
import 'package:algo_visualizer/models/algo_step.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Insertion sort produces sorted final snapshot and done step', () {
    final sorter = InsertionSort();
    final input = <int>[5, 2, 4, 6, 1, 3];

    final steps = sorter.performInsertionSort(List<int>.from(input));

    expect(steps, isNotEmpty);
    expect(steps.last.stepType, AlgoStepType.done);
    expect(steps.last.numbersSnapshot, <int>[1, 2, 3, 4, 5, 6]);
    expect(steps.any((s) => s.stepType == AlgoStepType.compare), isTrue);
    expect(steps.any((s) => s.stepType == AlgoStepType.swap), isTrue);
  });
}
