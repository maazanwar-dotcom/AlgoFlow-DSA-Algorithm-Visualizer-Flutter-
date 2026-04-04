import 'package:algo_visualizer/models/algo_step.dart';

class LongestIncreasingSubsequenceDp {
  final List<AlgoStep> steps = [];

  List<AlgoStep> performLisDp(List<int> numbers) {
    steps.clear();

    if (numbers.isEmpty) {
      steps.add(
        const AlgoStep(
          numbersSnapshot: <int>[],
          opertation: 'No input values available for LIS',
          i: -1,
          j: -1,
          stepType: AlgoStepType.done,
        ),
      );
      return steps;
    }

    final dp = List<int>.filled(numbers.length, 1);
    final parent = List<int>.filled(numbers.length, -1);

    steps.add(
      AlgoStep(
        numbersSnapshot: List<int>.from(dp),
        opertation: 'Initialize LIS lengths table with 1 for each index',
        i: 0,
        j: -1,
        stepType: AlgoStepType.overwrite,
      ),
    );

    for (int i = 1; i < numbers.length; i++) {
      for (int j = 0; j < i; j++) {
        steps.add(
          AlgoStep(
            numbersSnapshot: List<int>.from(dp),
            opertation:
                'Compare arr[$j]=${numbers[j]} with arr[$i]=${numbers[i]} for increasing subsequence',
            i: i,
            j: j,
            stepType: AlgoStepType.compare,
          ),
        );

        if (numbers[j] < numbers[i] && dp[j] + 1 > dp[i]) {
          dp[i] = dp[j] + 1;
          parent[i] = j;

          steps.add(
            AlgoStep(
              numbersSnapshot: List<int>.from(dp),
              opertation:
                  'Update LIS length at index $i to ${dp[i]} via index $j',
              i: i,
              j: j,
              stepType: AlgoStepType.overwrite,
            ),
          );
        } else {
          steps.add(
            AlgoStep(
              numbersSnapshot: List<int>.from(dp),
              opertation:
                  'No LIS update required at index $i for predecessor $j',
              i: i,
              j: j,
              stepType: AlgoStepType.noSwap,
            ),
          );
        }
      }
    }

    int bestIndex = 0;
    for (int i = 1; i < dp.length; i++) {
      if (dp[i] > dp[bestIndex]) {
        bestIndex = i;
      }
    }

    final sequenceValues = _reconstructSequence(numbers, parent, bestIndex);

    steps.add(
      AlgoStep(
        numbersSnapshot: List<int>.from(dp),
        opertation:
            'LIS length = ${dp[bestIndex]}, sequence = ${sequenceValues.join(' -> ')}',
        i: bestIndex,
        j: -1,
        stepType: AlgoStepType.done,
      ),
    );

    return steps;
  }

  List<int> _reconstructSequence(
    List<int> numbers,
    List<int> parent,
    int endIndex,
  ) {
    final sequence = <int>[];
    int current = endIndex;

    while (current >= 0) {
      sequence.add(numbers[current]);
      current = parent[current];
    }

    return sequence.reversed.toList();
  }
}
