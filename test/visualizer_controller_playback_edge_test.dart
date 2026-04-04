import 'package:algo_visualizer/controllers/visualizer_controller.dart';
import 'package:algo_visualizer/models/algorithms.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const insertion = Algorithm(
    name: 'Insertion Sort',
    tagline: 'Insertion Based Sort',
    difficulty: Difficulty.medium,
    timeComplexity: 'O(n^2)',
    spaceComplexity: 'O(1)',
    type: AlgorithmType.Insert,
    category: AlgorithmCategory.Sorting,
  );

  test('pause during autoplay prevents further stepping', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final sub = container.listen(visualizerControllerProvier, (_, __) {});
    addTearDown(sub.close);

    final notifier = container.read(visualizerControllerProvier.notifier);
    notifier.initialize(insertion, <int>[9, 5, 2, 7]);
    notifier.setSpeed(150);

    fakeAsync((async) {
      notifier.play();
      async.elapse(const Duration(milliseconds: 200));

      var state = container.read(visualizerControllerProvier);
      final steppedIndex = state.stepIndex;
      expect(state.isPlaying, isTrue);
      expect(steppedIndex, greaterThan(0));

      notifier.pause();
      state = container.read(visualizerControllerProvier);
      expect(state.isPlaying, isFalse);

      async.elapse(const Duration(milliseconds: 800));
      state = container.read(visualizerControllerProvier);
      expect(state.stepIndex, steppedIndex);
      expect(state.isPlaying, isFalse);
    });
  });

  test('reset during autoplay returns to step zero and stays stopped', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final sub = container.listen(visualizerControllerProvier, (_, __) {});
    addTearDown(sub.close);

    final notifier = container.read(visualizerControllerProvier.notifier);
    notifier.initialize(insertion, <int>[8, 4, 1, 3]);
    notifier.setSpeed(150);

    fakeAsync((async) {
      notifier.play();
      async.elapse(const Duration(milliseconds: 220));

      var state = container.read(visualizerControllerProvier);
      expect(state.stepIndex, greaterThan(0));
      expect(state.isPlaying, isTrue);

      notifier.reset();
      state = container.read(visualizerControllerProvier);
      expect(state.stepIndex, 0);
      expect(state.isPlaying, isFalse);

      async.elapse(const Duration(milliseconds: 1000));
      state = container.read(visualizerControllerProvier);
      expect(state.stepIndex, 0);
      expect(state.isPlaying, isFalse);
    });
  });
}
