import 'package:algo_visualizer/models/algo_step.dart';

class CoinChangeDp {
  final List<AlgoStep> steps = [];

  List<AlgoStep> performCoinChangeDp(List<int> numbers) {
    steps.clear();

    final coins = _coinsFromInput(numbers);
    final amount = numbers.isEmpty ? 11 : (numbers.first.abs() % 8) + 6;
    final inf = amount + 1;
    final dp = List<int>.filled(amount + 1, inf);
    dp[0] = 0;

    steps.add(
      AlgoStep(
        numbersSnapshot: _snapshot(dp, inf),
        opertation:
            'Initialize dp with INF for amount $amount using coins ${coins.join(', ')}',
        i: 0,
        j: -1,
        stepType: AlgoStepType.overwrite,
      ),
    );

    for (int value = 1; value <= amount; value++) {
      for (final coin in coins) {
        if (coin > value) {
          steps.add(
            AlgoStep(
              numbersSnapshot: _snapshot(dp, inf),
              opertation: 'Coin $coin is too large for amount $value',
              i: value,
              j: coin,
              stepType: AlgoStepType.noSwap,
            ),
          );
          continue;
        }

        final candidate = dp[value - coin] + 1;
        steps.add(
          AlgoStep(
            numbersSnapshot: _snapshot(dp, inf),
            opertation:
                'Compare dp[$value]=${dp[value] >= inf ? 'INF' : dp[value]} with candidate $candidate using coin $coin',
            i: value,
            j: value - coin,
            stepType: AlgoStepType.compare,
          ),
        );

        if (candidate < dp[value]) {
          dp[value] = candidate;
          steps.add(
            AlgoStep(
              numbersSnapshot: _snapshot(dp, inf),
              opertation: 'Update dp[$value] to $candidate',
              i: value,
              j: value - coin,
              stepType: AlgoStepType.overwrite,
            ),
          );
        } else {
          steps.add(
            AlgoStep(
              numbersSnapshot: _snapshot(dp, inf),
              opertation: 'No update for dp[$value] with coin $coin',
              i: value,
              j: value - coin,
              stepType: AlgoStepType.noSwap,
            ),
          );
        }
      }
    }

    final reachable = dp[amount] < inf;
    steps.add(
      AlgoStep(
        numbersSnapshot: _snapshot(dp, inf),
        opertation: reachable
            ? 'Minimum coins for amount $amount = ${dp[amount]}'
            : 'Amount $amount is not reachable with given coins',
        i: amount,
        j: -1,
        stepType: AlgoStepType.done,
        searchHit: reachable,
        targetValue: reachable ? dp[amount] : -1,
      ),
    );

    return steps;
  }

  List<int> _coinsFromInput(List<int> numbers) {
    final raw = numbers.isEmpty
        ? <int>[1, 2, 5]
        : numbers.take(4).map((n) => (n.abs() % 7) + 1).toSet().toList();
    raw.sort();
    return raw.isEmpty ? <int>[1, 2, 5] : raw;
  }

  List<int> _snapshot(List<int> dp, int inf) {
    return dp.map((v) => v >= inf ? inf : v).toList();
  }
}
