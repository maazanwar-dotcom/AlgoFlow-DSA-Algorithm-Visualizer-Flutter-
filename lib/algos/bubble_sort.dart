import 'package:algo_visualizer/models/algo_step.dart';

class BubbleSort {
  final List<AlgoStep> steps = [];
  List<AlgoStep> performBubbleSort(List<int> numbers) {
    steps.clear();
    for (int i = 0; i < numbers.length; i++) {
      for (int j = 0; j < numbers.length - i - 1; j++) {
        if (numbers[j] > numbers[j + 1]) {
          // record comparison
          steps.add(
            AlgoStep(
              numbersSnapshot: List.from(numbers),
              opertation: 'Compare ${numbers[j]} and ${numbers[j + 1]}',
              i: j,
              j: j + 1,
              stepType: AlgoStepType.compare,
            ),
          );
          // swap
          final temp = numbers[j];
          numbers[j] = numbers[j + 1];
          numbers[j + 1] = temp;
          //record swap
          steps.add(
            AlgoStep(
              numbersSnapshot: List.from(numbers),
              opertation: 'SWAP',
              i: j,
              j: j + 1,
              stepType: AlgoStepType.swap,
            ),
          );
        } else {
          steps.add(
            AlgoStep(
              numbersSnapshot: List.from(numbers),
              opertation:
                  'Compare ${numbers[j]} and ${numbers[j + 1]} => NO SWAP',
              i: j,
              j: j + 1,
              stepType: AlgoStepType.noSwap,
            ),
          );
        }
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
