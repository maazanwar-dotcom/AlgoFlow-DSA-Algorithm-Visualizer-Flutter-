import 'package:algo_visualizer/models/algo_step.dart';

class InsertionSort {
  final List<AlgoStep> steps = [];

  List<AlgoStep> performInsertionSort(List<int> numbers) {
    steps.clear();

    for (int i = 1; i < numbers.length; i++) {
      final key = numbers[i];
      int j = i - 1;

      while (j >= 0) {
        steps.add(
          AlgoStep(
            numbersSnapshot: List<int>.from(numbers),
            opertation: 'Compare ${numbers[j]} and $key',
            i: j,
            j: j + 1,
            stepType: AlgoStepType.compare,
          ),
        );

        if (numbers[j] > key) {
          numbers[j + 1] = numbers[j];
          steps.add(
            AlgoStep(
              numbersSnapshot: List<int>.from(numbers),
              opertation: 'Shift ${numbers[j]} to index ${j + 1}',
              i: j,
              j: j + 1,
              stepType: AlgoStepType.swap,
            ),
          );
          j--;
        } else {
          steps.add(
            AlgoStep(
              numbersSnapshot: List<int>.from(numbers),
              opertation: 'Compare ${numbers[j]} and $key => NO SHIFT',
              i: j,
              j: j + 1,
              stepType: AlgoStepType.noSwap,
            ),
          );
          break;
        }
      }

      numbers[j + 1] = key;
      if (j + 1 != i) {
        steps.add(
          AlgoStep(
            numbersSnapshot: List<int>.from(numbers),
            opertation: 'Insert $key at index ${j + 1}',
            i: j + 1,
            j: i,
            stepType: AlgoStepType.swap,
          ),
        );
      }
    }

    steps.add(
      AlgoStep(
        numbersSnapshot: List<int>.from(numbers),
        opertation: 'Sorting completed',
        i: -1,
        j: -1,
        stepType: AlgoStepType.done,
      ),
    );

    return steps;
  }
}