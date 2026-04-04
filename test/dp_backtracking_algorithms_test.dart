import 'package:algo_visualizer/algos/house_robber_dp.dart';
import 'package:algo_visualizer/algos/longest_increasing_subsequence.dart';
import 'package:algo_visualizer/algos/n_queens_backtracking.dart';
import 'package:algo_visualizer/algos/permutations_backtracking.dart';
import 'package:algo_visualizer/algos/subset_sum_backtracking.dart';
import 'package:algo_visualizer/algos/fibonacci_dp.dart';
import 'package:algo_visualizer/algos/coin_change_dp.dart';
import 'package:algo_visualizer/models/algo_step.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('LIS DP emits updates and reports correct LIS length', () {
    final steps = LongestIncreasingSubsequenceDp().performLisDp(<int>[
      10,
      9,
      2,
      5,
      3,
      7,
      101,
      18,
    ]);

    expect(steps, isNotEmpty);
    expect(steps.last.stepType, AlgoStepType.done);
    expect(steps.last.opertation.contains('LIS length = 4'), isTrue);
    expect(steps.any((s) => s.stepType == AlgoStepType.compare), isTrue);
    expect(steps.any((s) => s.stepType == AlgoStepType.overwrite), isTrue);
  });

  test('House Robber DP computes maximum non-adjacent sum', () {
    final steps = HouseRobberDp().performHouseRobberDp(<int>[2, 7, 9, 3, 1]);

    expect(steps, isNotEmpty);
    expect(steps.last.stepType, AlgoStepType.done);
    expect(steps.last.opertation.contains('12'), isTrue);
    expect(steps.any((s) => s.stepType == AlgoStepType.compare), isTrue);
  });

  test('Permutation backtracking generates all permutations', () {
    final steps = PermutationsBacktracking().performPermutations(<int>[
      1,
      2,
      3,
    ]);

    expect(steps, isNotEmpty);
    expect(steps.last.stepType, AlgoStepType.done);
    expect(steps.last.opertation.contains('(6 permutations)'), isTrue);
    expect(steps.any((s) => s.stepType == AlgoStepType.swap), isTrue);
  });

  test('Subset-sum backtracking can find a valid subset', () {
    final steps = SubsetSumBacktracking().performSubsetSumBacktracking(<int>[
      3,
      1,
      2,
      2,
      4,
    ]);

    expect(steps, isNotEmpty);
    expect(steps.last.stepType, AlgoStepType.done);
    expect(steps.last.searchHit, isTrue);
    expect(steps.any((s) => s.stepType == AlgoStepType.compare), isTrue);
  });

  test('Fibonacci DP computes and records final fibonacci value', () {
    final steps = FibonacciDp().performFibonacciDp(<int>[9]);

    expect(steps, isNotEmpty);
    expect(steps.last.stepType, AlgoStepType.done);
    expect(steps.last.opertation.contains('Fibonacci result'), isTrue);
    expect(steps.any((s) => s.stepType == AlgoStepType.overwrite), isTrue);
  });

  test('Coin Change DP computes minimum coin count when reachable', () {
    final steps = CoinChangeDp().performCoinChangeDp(<int>[11, 2, 5, 7]);

    expect(steps, isNotEmpty);
    expect(steps.last.stepType, AlgoStepType.done);
    expect(steps.last.searchHit, isTrue);
    expect(steps.last.targetValue, greaterThanOrEqualTo(0));
    expect(steps.any((s) => s.stepType == AlgoStepType.compare), isTrue);
  });

  test('N-Queens backtracking reaches a valid solved configuration', () {
    final steps = NQueensBacktracking().performNQueensBacktracking(<int>[4]);

    expect(steps, isNotEmpty);
    expect(steps.last.stepType, AlgoStepType.done);
    expect(steps.last.searchHit, isTrue);
    expect(steps.any((s) => s.stepType == AlgoStepType.compare), isTrue);
    expect(steps.any((s) => s.stepType == AlgoStepType.noSwap), isTrue);
  });
}
