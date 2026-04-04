import 'package:algo_visualizer/models/algo_step.dart';

class QuickSort {
  final List<AlgoStep> steps = [];

  List<AlgoStep> performQuickSort(List<int> numbers) {
    steps.clear();
    _quickSort(numbers, 0, numbers.length - 1);

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

  void _quickSort(List<int> arr, int left, int right) {
    if (left < right) {
      final pi = _partition(arr, left, right);
      _quickSort(arr, left, pi - 1);
      _quickSort(arr, pi + 1, right);
    }
  }

  int _partition(List<int> arr, int left, int right) {
    final pivot = arr[right];
    int i = left - 1;

    for (int j = left; j < right; j++) {
      steps.add(
        AlgoStep(
          numbersSnapshot: List.from(arr),
          opertation: 'Compare ${arr[j]} with pivot $pivot',
          i: j,
          j: right,
          stepType: AlgoStepType.compare,
        ),
      );

      if (arr[j] < pivot) {
        i++;
        // Swap
        final temp = arr[i];
        arr[i] = arr[j];
        arr[j] = temp;

        steps.add(
          AlgoStep(
            numbersSnapshot: List.from(arr),
            opertation: 'SWAP arr[$i] and arr[$j]',
            i: i,
            j: j,
            stepType: AlgoStepType.swap,
          ),
        );
      } else {
        steps.add(
          AlgoStep(
            numbersSnapshot: List.from(arr),
            opertation: 'NO SWAP needed',
            i: j,
            j: right,
            stepType: AlgoStepType.noSwap,
          ),
        );
      }
    }

    // Place pivot in its correct position
    final temp = arr[i + 1];
    arr[i + 1] = arr[right];
    arr[right] = temp;

    steps.add(
      AlgoStep(
        numbersSnapshot: List.from(arr),
        opertation: 'Pivot placed at position ${i + 1}',
        i: i + 1,
        j: right,
        stepType: AlgoStepType.overwrite,
      ),
    );

    return i + 1;
  }
}
