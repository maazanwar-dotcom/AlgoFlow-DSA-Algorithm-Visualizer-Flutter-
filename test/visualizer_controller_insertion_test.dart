import 'package:algo_visualizer/controllers/visualizer_controller.dart';
import 'package:algo_visualizer/models/algorithms.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'VisualizerController drives insertion sort with consistent metrics',
    () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final sub = container.listen(visualizerControllerProvier, (_, __) {});
      addTearDown(sub.close);

      final notifier = container.read(visualizerControllerProvier.notifier);
      const insertion = Algorithm(
        name: 'Insertion Sort',
        tagline: 'Insertion Based Sort',
        difficulty: Difficulty.medium,
        timeComplexity: 'O(n^2)',
        spaceComplexity: 'O(1)',
        type: AlgorithmType.Insert,
        category: AlgorithmCategory.Sorting,
      );

      notifier.initialize(insertion, <int>[4, 3, 2, 1]);
      var state = container.read(visualizerControllerProvier);

      expect(state.steps, isNotEmpty);
      expect(state.selectedAlgorithm?.name, 'Insertion Sort');

      int safety = 0;
      while (state.stepIndex < state.steps.length - 1 && safety < 500) {
        final prevComparisons = state.comparisons;
        final prevSwaps = state.swaps;
        notifier.nextStep();
        state = container.read(visualizerControllerProvier);

        expect(state.comparisons >= prevComparisons, isTrue);
        expect(state.swaps >= prevSwaps, isTrue);
        safety++;
      }

      expect(safety < 500, isTrue);
      expect(state.stepIndex, state.steps.length - 1);
      expect(state.steps.last.numbersSnapshot, <int>[1, 2, 3, 4]);

      notifier.reset();
      state = container.read(visualizerControllerProvier);
      expect(state.stepIndex, 0);
      expect(state.isPlaying, isFalse);
    },
  );
}
