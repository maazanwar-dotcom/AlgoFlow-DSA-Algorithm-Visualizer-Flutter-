import 'package:algo_visualizer/models/algo_step.dart';

class SubsetSumBacktracking {
  final List<AlgoStep> steps = [];

  List<AlgoStep> performSubsetSumBacktracking(List<int> numbers) {
    steps.clear();

    if (numbers.isEmpty) {
      steps.add(
        const AlgoStep(
          numbersSnapshot: <int>[],
          opertation: 'No input values available for subset-sum search',
          i: -1,
          j: -1,
          stepType: AlgoStepType.done,
        ),
      );
      return steps;
    }

    final int size = numbers.length > 6 ? 6 : numbers.length;
    final values = List<int>.from(numbers.take(size));
    final selected = List<bool>.filled(values.length, false);
    final target = values.reduce((a, b) => a + b) ~/ 2;

    steps.add(
      AlgoStep(
        numbersSnapshot: _selectedSnapshot(values, selected),
        opertation: 'Start subset-sum backtracking with target $target',
        i: -1,
        j: -1,
        stepType: AlgoStepType.overwrite,
      ),
    );

    final found = _search(
      values: values,
      selected: selected,
      index: 0,
      currentSum: 0,
      target: target,
    );

    steps.add(
      AlgoStep(
        numbersSnapshot: _selectedSnapshot(values, selected),
        opertation: found
            ? 'Subset found for target $target'
            : 'No subset found for target $target',
        i: -1,
        j: -1,
        stepType: AlgoStepType.done,
        searchHit: found,
      ),
    );

    return steps;
  }

  bool _search({
    required List<int> values,
    required List<bool> selected,
    required int index,
    required int currentSum,
    required int target,
  }) {
    if (currentSum == target) {
      steps.add(
        AlgoStep(
          numbersSnapshot: _selectedSnapshot(values, selected),
          opertation: 'Reached target sum $target',
          i: index - 1,
          j: -1,
          stepType: AlgoStepType.overwrite,
        ),
      );
      return true;
    }

    if (index >= values.length || currentSum > target) {
      steps.add(
        AlgoStep(
          numbersSnapshot: _selectedSnapshot(values, selected),
          opertation: 'Backtrack at index $index (sum=$currentSum)',
          i: index >= values.length ? values.length - 1 : index,
          j: -1,
          stepType: AlgoStepType.noSwap,
        ),
      );
      return false;
    }

    selected[index] = true;
    steps.add(
      AlgoStep(
        numbersSnapshot: _selectedSnapshot(values, selected),
        opertation: 'Include value ${values[index]} at index $index',
        i: index,
        j: -1,
        stepType: AlgoStepType.compare,
      ),
    );

    if (_search(
      values: values,
      selected: selected,
      index: index + 1,
      currentSum: currentSum + values[index],
      target: target,
    )) {
      return true;
    }

    selected[index] = false;
    steps.add(
      AlgoStep(
        numbersSnapshot: _selectedSnapshot(values, selected),
        opertation: 'Exclude value ${values[index]} and continue search',
        i: index,
        j: -1,
        stepType: AlgoStepType.noSwap,
      ),
    );

    return _search(
      values: values,
      selected: selected,
      index: index + 1,
      currentSum: currentSum,
      target: target,
    );
  }

  List<int> _selectedSnapshot(List<int> values, List<bool> selected) {
    return List<int>.generate(
      values.length,
      (index) => selected[index] ? values[index] : 0,
    );
  }
}
