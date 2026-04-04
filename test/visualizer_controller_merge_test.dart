import 'package:algo_visualizer/controllers/visualizer_controller.dart';
import 'package:algo_visualizer/models/algorithms.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'VisualizerController drives merge sort with synced metrics and reset',
    () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final sub = container.listen(visualizerControllerProvier, (_, __) {});
      addTearDown(sub.close);

      final notifier = container.read(visualizerControllerProvier.notifier);
      const merge = Algorithm(
        name: 'Merge Sort',
        tagline: 'Divide and Conquer Stable Sort',
        difficulty: Difficulty.medium,
        timeComplexity: 'O(n log n)',
        spaceComplexity: 'O(n)',
        type: AlgorithmType.Merge,
        category: AlgorithmCategory.Sorting,
      );

      notifier.initialize(merge, <int>[7, 2, 6, 3, 9, 1]);
      var state = container.read(visualizerControllerProvier);

      expect(state.steps, isNotEmpty);
      expect(state.selectedAlgorithm?.name, 'Merge Sort');

      int safety = 0;
      while (state.stepIndex < state.steps.length - 1 && safety < 700) {
        final prevComparisons = state.comparisons;
        final prevSwaps = state.swaps;
        notifier.nextStep();
        state = container.read(visualizerControllerProvier);

        expect(state.comparisons >= prevComparisons, isTrue);
        expect(state.swaps >= prevSwaps, isTrue);
        safety++;
      }

      expect(safety < 700, isTrue);
      expect(state.stepIndex, state.steps.length - 1);
      expect(state.steps.last.numbersSnapshot, <int>[1, 2, 3, 6, 7, 9]);

      notifier.reset();
      state = container.read(visualizerControllerProvier);
      expect(state.stepIndex, 0);
      expect(state.isPlaying, isFalse);
    },
  );
}
