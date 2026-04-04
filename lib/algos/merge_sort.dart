import 'package:algo_visualizer/models/algo_step.dart';

class MergeSort {
  final List<AlgoStep> steps = [];

  List<AlgoStep> performMergeSort(List<int> numbers) {
    steps.clear();
    if (numbers.isNotEmpty) {
      _mergeSort(numbers, 0, numbers.length - 1);
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

  void _mergeSort(List<int> arr, int left, int right) {
    if (left >= right) return;

    final mid = left + (right - left) ~/ 2;
    _mergeSort(arr, left, mid);
    _mergeSort(arr, mid + 1, right);
    _merge(arr, left, mid, right);
  }

  void _merge(List<int> arr, int left, int mid, int right) {
    final leftPart = arr.sublist(left, mid + 1);
    final rightPart = arr.sublist(mid + 1, right + 1);

    int i = 0;
    int j = 0;
    int k = left;

    while (i < leftPart.length && j < rightPart.length) {
      final leftIndex = left + i;
      final rightIndex = mid + 1 + j;

      steps.add(
        AlgoStep(
          numbersSnapshot: List<int>.from(arr),
          opertation:
              'Compare left[$leftIndex]=${leftPart[i]} with right[$rightIndex]=${rightPart[j]}',
          i: leftIndex,
          j: rightIndex,
          stepType: AlgoStepType.compare,
        ),
      );

      if (leftPart[i] <= rightPart[j]) {
        arr[k] = leftPart[i];
        steps.add(
          AlgoStep(
            numbersSnapshot: List<int>.from(arr),
            opertation: 'Write ${leftPart[i]} to arr[$k] from left[$leftIndex]',
            i: k,
            j: leftIndex,
            stepType: AlgoStepType.overwrite,
          ),
        );
        i++;
      } else {
        arr[k] = rightPart[j];
        steps.add(
          AlgoStep(
            numbersSnapshot: List<int>.from(arr),
            opertation:
                'Write ${rightPart[j]} to arr[$k] from right[$rightIndex]',
            i: k,
            j: rightIndex,
            stepType: AlgoStepType.overwrite,
          ),
        );
        j++;
      }

      k++;
    }

    while (i < leftPart.length) {
      final leftIndex = left + i;
      arr[k] = leftPart[i];
      steps.add(
        AlgoStep(
          numbersSnapshot: List<int>.from(arr),
          opertation:
              'Drain left: write ${leftPart[i]} to arr[$k] from left[$leftIndex]',
          i: k,
          j: leftIndex,
          stepType: AlgoStepType.overwrite,
        ),
      );
      i++;
      k++;
    }

    while (j < rightPart.length) {
      final rightIndex = mid + 1 + j;
      arr[k] = rightPart[j];
      steps.add(
        AlgoStep(
          numbersSnapshot: List<int>.from(arr),
          opertation:
              'Drain right: write ${rightPart[j]} to arr[$k] from right[$rightIndex]',
          i: k,
          j: rightIndex,
          stepType: AlgoStepType.overwrite,
        ),
      );
      j++;
      k++;
    }
  }
}
