import 'dart:math';

import 'package:algo_visualizer/models/algo_step.dart';

class HouseRobberDp {
  final List<AlgoStep> steps = [];

  List<AlgoStep> performHouseRobberDp(List<int> houses) {
    steps.clear();

    if (houses.isEmpty) {
      steps.add(
        const AlgoStep(
          numbersSnapshot: <int>[],
          opertation: 'No houses available to evaluate',
          i: -1,
          j: -1,
          stepType: AlgoStepType.done,
        ),
      );
      return steps;
    }

    final maxLoot = List<int>.filled(houses.length, 0);
    maxLoot[0] = houses[0];

    steps.add(
      AlgoStep(
        numbersSnapshot: List<int>.from(maxLoot),
        opertation: 'Initialize dp[0] = ${houses[0]}',
        i: 0,
        j: -1,
        stepType: AlgoStepType.overwrite,
      ),
    );

    if (houses.length > 1) {
      steps.add(
        AlgoStep(
          numbersSnapshot: List<int>.from(maxLoot),
          opertation: 'Compare first two houses: ${houses[0]} and ${houses[1]}',
          i: 1,
          j: 0,
          stepType: AlgoStepType.compare,
        ),
      );

      maxLoot[1] = max(houses[0], houses[1]);
      steps.add(
        AlgoStep(
          numbersSnapshot: List<int>.from(maxLoot),
          opertation: 'Set dp[1] = ${maxLoot[1]}',
          i: 1,
          j: 0,
          stepType: AlgoStepType.overwrite,
        ),
      );
    }

    for (int i = 2; i < houses.length; i++) {
      final take = maxLoot[i - 2] + houses[i];
      final skip = maxLoot[i - 1];

      steps.add(
        AlgoStep(
          numbersSnapshot: List<int>.from(maxLoot),
          opertation:
              'At index $i compare take=$take (dp[${i - 2}] + ${houses[i]}) vs skip=$skip',
          i: i,
          j: i - 1,
          stepType: AlgoStepType.compare,
        ),
      );

      if (take > skip) {
        maxLoot[i] = take;
        steps.add(
          AlgoStep(
            numbersSnapshot: List<int>.from(maxLoot),
            opertation: 'Choose rob at index $i, dp[$i] = $take',
            i: i,
            j: i - 2,
            stepType: AlgoStepType.overwrite,
          ),
        );
      } else {
        maxLoot[i] = skip;
        steps.add(
          AlgoStep(
            numbersSnapshot: List<int>.from(maxLoot),
            opertation: 'Skip index $i, carry forward dp[$i] = $skip',
            i: i,
            j: i - 1,
            stepType: AlgoStepType.noSwap,
          ),
        );
      }
    }

    steps.add(
      AlgoStep(
        numbersSnapshot: List<int>.from(maxLoot),
        opertation:
            'Maximum non-adjacent loot = ${maxLoot[maxLoot.length - 1]}',
        i: maxLoot.length - 1,
        j: -1,
        stepType: AlgoStepType.done,
      ),
    );

    return steps;
  }
}
