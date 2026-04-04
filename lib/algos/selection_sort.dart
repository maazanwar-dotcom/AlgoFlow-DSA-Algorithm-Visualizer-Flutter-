import 'package:algo_visualizer/models/algo_step.dart';

class SelectionSort {
  final List<AlgoStep> steps = [];

  List<AlgoStep> performSelectionSort(List<int> numbers) {
    steps.clear();

    for (int i = 0; i < numbers.length - 1; i++) {
      int minIdx = i;

      for (int j = i + 1; j < numbers.length; j++) {
        steps.add(
          AlgoStep(
            numbersSnapshot: List.from(numbers),
            opertation: 'Compare ${numbers[j]} with min ${numbers[minIdx]}',
            i: j,
            j: minIdx,
            stepType: AlgoStepType.compare,
          ),
        );

        if (numbers[j] < numbers[minIdx]) {
          minIdx = j;
        }
      }

      // Swap minimum element with current position
      if (minIdx != i) {
        final temp = numbers[i];
        numbers[i] = numbers[minIdx];
        numbers[minIdx] = temp;

        steps.add(
          AlgoStep(
            numbersSnapshot: List.from(numbers),
            opertation: 'SWAP arr[$i] with min element at arr[$minIdx]',
            i: i,
            j: minIdx,
            stepType: AlgoStepType.swap,
          ),
        );
      } else {
        steps.add(
          AlgoStep(
            numbersSnapshot: List.from(numbers),
            opertation: 'Element at position $i is already in correct place',
            i: i,
            j: minIdx,
            stepType: AlgoStepType.noSwap,
          ),
        );
      }
    }

    steps.add(
      AlgoStep(
        numbersSnapshot: List.from(numbers),
        opertation: 'Sorting completed',
        i: -1,
        j: -1,
        stepType: AlgoStepType.done,
      ),
    );

    return steps;
  }
}
