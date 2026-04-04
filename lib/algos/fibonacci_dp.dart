import 'package:algo_visualizer/models/algo_step.dart';

class FibonacciDp {
  final List<AlgoStep> steps = [];

  List<AlgoStep> performFibonacciDp(List<int> numbers) {
    steps.clear();

    final int n = numbers.isEmpty ? 8 : (numbers.first.abs() % 8) + 5;
    final fib = List<int>.filled(n + 1, 0);

    steps.add(
      AlgoStep(
        numbersSnapshot: List<int>.from(fib),
        opertation: 'Initialize dp table for Fibonacci up to n=$n',
        i: 0,
        j: -1,
        stepType: AlgoStepType.overwrite,
      ),
    );

    if (n >= 1) {
      fib[1] = 1;
      steps.add(
        AlgoStep(
          numbersSnapshot: List<int>.from(fib),
          opertation: 'Set base cases: F(0)=0, F(1)=1',
          i: 1,
          j: 0,
          stepType: AlgoStepType.overwrite,
        ),
      );
    }

    for (int i = 2; i <= n; i++) {
      steps.add(
        AlgoStep(
          numbersSnapshot: List<int>.from(fib),
          opertation: 'Compute F($i) = F(${i - 1}) + F(${i - 2})',
          i: i - 1,
          j: i - 2,
          stepType: AlgoStepType.compare,
        ),
      );

      fib[i] = fib[i - 1] + fib[i - 2];
      steps.add(
        AlgoStep(
          numbersSnapshot: List<int>.from(fib),
          opertation: 'Write F($i) = ${fib[i]}',
          i: i,
          j: i - 1,
          stepType: AlgoStepType.overwrite,
        ),
      );
    }

    steps.add(
      AlgoStep(
        numbersSnapshot: List<int>.from(fib),
        opertation: 'Fibonacci result: F($n) = ${fib[n]}',
        i: n,
        j: -1,
        stepType: AlgoStepType.done,
      ),
    );

    return steps;
  }
}
