import 'package:algo_visualizer/models/algo_step.dart';

class PermutationsBacktracking {
  final List<AlgoStep> steps = [];
  final List<List<int>> _permutations = [];

  List<AlgoStep> performPermutations(List<int> numbers) {
    steps.clear();
    _permutations.clear();

    if (numbers.isEmpty) {
      steps.add(
        const AlgoStep(
          numbersSnapshot: <int>[],
          opertation: 'No input values available for permutation generation',
          i: -1,
          j: -1,
          stepType: AlgoStepType.done,
        ),
      );
      return steps;
    }

    final int size = numbers.length > 4 ? 4 : numbers.length;
    final values = List<int>.from(numbers.take(size));

    _backtrack(values, 0);

    steps.add(
      AlgoStep(
        numbersSnapshot: List<int>.from(values),
        opertation:
            'Permutation generation complete (${_permutations.length} permutations)',
        i: -1,
        j: -1,
        stepType: AlgoStepType.done,
      ),
    );

    return steps;
  }

  void _backtrack(List<int> values, int start) {
    if (start == values.length) {
      _permutations.add(List<int>.from(values));
      steps.add(
        AlgoStep(
          numbersSnapshot: List<int>.from(values),
          opertation:
              'Permutation ${_permutations.length}: ${values.join(', ')}',
          i: values.length - 1,
          j: -1,
          stepType: AlgoStepType.overwrite,
        ),
      );
      return;
    }

    for (int i = start; i < values.length; i++) {
      steps.add(
        AlgoStep(
          numbersSnapshot: List<int>.from(values),
          opertation: 'Choose value at index $i for position $start',
          i: start,
          j: i,
          stepType: AlgoStepType.compare,
        ),
      );

      _swap(values, start, i);
      steps.add(
        AlgoStep(
          numbersSnapshot: List<int>.from(values),
          opertation: 'Swap index $start with index $i',
          i: start,
          j: i,
          stepType: AlgoStepType.swap,
        ),
      );

      _backtrack(values, start + 1);

      _swap(values, start, i);
      steps.add(
        AlgoStep(
          numbersSnapshot: List<int>.from(values),
          opertation: 'Backtrack: restore index $start and index $i',
          i: start,
          j: i,
          stepType: AlgoStepType.noSwap,
        ),
      );
    }
  }

  void _swap(List<int> values, int i, int j) {
    final temp = values[i];
    values[i] = values[j];
    values[j] = temp;
  }
}
