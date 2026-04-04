import 'package:algo_visualizer/controllers/continue_learning_controller.dart';
import 'package:algo_visualizer/models/algo_step.dart';
import 'package:algo_visualizer/models/algorithms.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test(
    'continue learning progress persists and reloads after restart',
    () async {
      final firstContainer = ProviderContainer();
      addTearDown(firstContainer.dispose);

      final firstNotifier = firstContainer.read(
        continueLearningControllerProvider.notifier,
      );
      await firstNotifier.ensureLoaded();

      const algorithm = Algorithm(
        name: 'BST Search',
        tagline: 'Binary Search Tree Lookup',
        difficulty: Difficulty.easy,
        timeComplexity: 'O(h)',
        spaceComplexity: 'O(1)',
        type: AlgorithmType.BstSearch,
        category: AlgorithmCategory.Trees,
      );

      final steps = <AlgoStep>[
        const AlgoStep(
          numbersSnapshot: <int>[8, 4, 12],
          opertation: 'Compare target 12 with node 8',
          i: 1,
          j: -1,
          stepType: AlgoStepType.compare,
          treeSnapshot: <int, int>{1: 8, 2: 4, 3: 12},
          activeNodeIndex: 1,
          targetValue: 12,
          targetNodeIndex: 3,
          traversalPathIndices: <int>[1],
        ),
        const AlgoStep(
          numbersSnapshot: <int>[8, 4, 12],
          opertation: 'Target 12 found at node 12',
          i: 3,
          j: -1,
          stepType: AlgoStepType.done,
          treeSnapshot: <int, int>{1: 8, 2: 4, 3: 12},
          activeNodeIndex: 3,
          targetValue: 12,
          targetNodeIndex: 3,
          traversalPathIndices: <int>[1, 3],
          searchHit: true,
        ),
      ];

      firstNotifier.upsertProgress(
        algorithm: algorithm,
        initialNumbers: const <int>[8, 4, 12],
        steps: steps,
        stepIndex: 1,
        speedMs: 500,
      );

      await Future<void>.delayed(const Duration(milliseconds: 30));

      final secondContainer = ProviderContainer();
      addTearDown(secondContainer.dispose);

      final secondNotifier = secondContainer.read(
        continueLearningControllerProvider.notifier,
      );
      await secondNotifier.ensureLoaded();

      final restored = secondContainer.read(continueLearningControllerProvider);
      expect(restored.containsKey('BST Search'), isTrue);

      final progress = restored['BST Search']!;
      expect(progress.stepIndex, equals(1));
      expect(progress.speedMs, equals(500));
      expect(progress.initialNumbers, equals(<int>[8, 4, 12]));
      expect(progress.steps.length, equals(2));
      expect(progress.steps.last.searchHit, isTrue);
      expect(progress.steps.last.targetNodeIndex, equals(3));
      expect(progress.steps.last.traversalPathIndices, equals(<int>[1, 3]));
    },
  );
}
