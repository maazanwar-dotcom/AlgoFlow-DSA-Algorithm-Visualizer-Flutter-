import 'package:algo_visualizer/models/algo_step.dart';

class HeapSort {
  final List<AlgoStep> steps = [];

  List<AlgoStep> performHeapSort(List<int> numbers) {
    steps.clear();

    // Build heap
    for (int i = numbers.length ~/ 2 - 1; i >= 0; i--) {
      _heapify(numbers, numbers.length, i);
    }

    // Extract elements from heap one by one
    for (int i = numbers.length - 1; i > 0; i--) {
      // Move current root (max) to end
      steps.add(
        AlgoStep(
          numbersSnapshot: List.from(numbers),
          opertation: 'Move root ${numbers[0]} to position $i',
          i: 0,
          j: i,
          stepType: AlgoStepType.compare,
        ),
      );

      final temp = numbers[0];
      numbers[0] = numbers[i];
      numbers[i] = temp;

      steps.add(
        AlgoStep(
          numbersSnapshot: List.from(numbers),
          opertation: 'SWAP root with element at position $i',
          i: 0,
          j: i,
          stepType: AlgoStepType.swap,
        ),
      );

      // Heapify reduced heap
      _heapify(numbers, i, 0);
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

  void _heapify(List<int> arr, int n, int i) {
    int largest = i;
    final left = 2 * i + 1;
    final right = 2 * i + 2;

    if (left < n && arr[left] > arr[largest]) {
      largest = left;
    }

    if (right < n && arr[right] > arr[largest]) {
      largest = right;
    }

    if (largest != i) {
      steps.add(
        AlgoStep(
          numbersSnapshot: List.from(arr),
          opertation: 'Compare heap elements at positions $i and $largest',
          i: i,
          j: largest,
          stepType: AlgoStepType.compare,
        ),
      );

      final temp = arr[i];
      arr[i] = arr[largest];
      arr[largest] = temp;

      steps.add(
        AlgoStep(
          numbersSnapshot: List.from(arr),
          opertation: 'SWAP heap elements',
          i: i,
          j: largest,
          stepType: AlgoStepType.swap,
        ),
      );

      _heapify(arr, n, largest);
    }
  }
}
