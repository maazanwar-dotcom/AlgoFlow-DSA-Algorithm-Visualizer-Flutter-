import 'dart:async';
import 'dart:math';

import 'package:algo_visualizer/algos/a_star_pathfinding.dart';
import 'package:algo_visualizer/algos/avl_rotation.dart';
import 'package:algo_visualizer/algos/bfs_traversal.dart';
import 'package:algo_visualizer/algos/bst_search.dart';
import 'package:algo_visualizer/algos/bubble_sort.dart';
import 'package:algo_visualizer/algos/coin_change_dp.dart';
import 'package:algo_visualizer/algos/dijkstra_shortest_path.dart';
import 'package:algo_visualizer/algos/dfs_traversal.dart';
import 'package:algo_visualizer/algos/fibonacci_dp.dart';
import 'package:algo_visualizer/algos/graph_common.dart';
import 'package:algo_visualizer/algos/graph_bfs.dart';
import 'package:algo_visualizer/algos/graph_dfs.dart';
import 'package:algo_visualizer/algos/house_robber_dp.dart';
import 'package:algo_visualizer/algos/insertion_sort.dart';
import 'package:algo_visualizer/algos/longest_increasing_subsequence.dart';
import 'package:algo_visualizer/algos/merge_sort.dart';
import 'package:algo_visualizer/algos/n_queens_backtracking.dart';
import 'package:algo_visualizer/algos/permutations_backtracking.dart';
import 'package:algo_visualizer/algos/quick_sort.dart';
import 'package:algo_visualizer/algos/selection_sort.dart';
import 'package:algo_visualizer/algos/subset_sum_backtracking.dart';
import 'package:algo_visualizer/algos/heap_sort.dart';
import 'package:algo_visualizer/models/algo_step.dart';
import 'package:algo_visualizer/models/algorithms.dart';
import 'package:algo_visualizer/states/visualizer_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final visualizerControllerProvier =
    NotifierProvider<VisualizerController, VisualizerState>(
      VisualizerController.new,
    );

class VisualizerController extends Notifier<VisualizerState> {
  final Random rnd = Random();
  Timer? timer;
  int _playSessionId = 0;

  static const int _minSpeedMs = 150;
  static const int _maxSpeedMs = 2000;

  // Re-initialize safely multiple times.
  List<AlgoStep> algoSteps = [];
  List<int> numbers = [];

  ({int comparisons, int swaps}) _metricsAtStep(int stepIndex) {
    if (state.steps.isEmpty || stepIndex < 0) {
      return (comparisons: 0, swaps: 0);
    }

    final int safeIndex = min(stepIndex, state.steps.length - 1);
    int comparisons = 0;
    int swaps = 0;

    for (int i = 0; i <= safeIndex; i++) {
      final type = state.steps[i].stepType;
      if (type == AlgoStepType.compare || type == AlgoStepType.noSwap) {
        comparisons++;
      } else if (type == AlgoStepType.swap || type == AlgoStepType.overwrite) {
        swaps++;
      }
    }

    return (comparisons: comparisons, swaps: swaps);
  }

  List<AlgoStep> algoForName(String name, List<int> source) {
    switch (name) {
      case "Bubble Sort":
        // Use a copy so step generation doesn't mutate the source list.
        return BubbleSort().performBubbleSort(List<int>.from(source));
      case "Insertion Sort":
        return InsertionSort().performInsertionSort(List<int>.from(source));
      case "Merge Sort":
        return MergeSort().performMergeSort(List<int>.from(source));
      case "Quick Sort":
        return QuickSort().performQuickSort(List<int>.from(source));
      case "Selection Sort":
        return SelectionSort().performSelectionSort(List<int>.from(source));
      case "Heap Sort":
        return HeapSort().performHeapSort(List<int>.from(source));
      case "Longest Increasing Subsequence":
        return LongestIncreasingSubsequenceDp().performLisDp(
          List<int>.from(source),
        );
      case "House Robber DP":
        return HouseRobberDp().performHouseRobberDp(List<int>.from(source));
      case "Fibonacci DP":
        return FibonacciDp().performFibonacciDp(List<int>.from(source));
      case "Coin Change DP":
        return CoinChangeDp().performCoinChangeDp(List<int>.from(source));
      case "Permutations":
        return PermutationsBacktracking().performPermutations(
          List<int>.from(source),
        );
      case "Subset Sum":
      case "Subset Sum Backtracking":
        return SubsetSumBacktracking().performSubsetSumBacktracking(
          List<int>.from(source),
        );
      case "N-Queens":
        return NQueensBacktracking().performNQueensBacktracking(
          List<int>.from(source),
        );
      case "BST Search":
        return BstSearch().performBstSearch(List<int>.from(source));
      case "BFS Traversal":
        return BfsTraversal().performBfsTraversal(List<int>.from(source));
      case "DFS Traversal":
        return DfsTraversal().performDfsTraversal(List<int>.from(source));
      case "AVL Rotation":
        return AvlRotation().performAvlRotation(List<int>.from(source));
      case "Graph BFS":
        return GraphBfs().performGraphBfs(generatedTraversalGraph(rnd));
      case "Graph DFS":
        return GraphDfs().performGraphDfs(generatedTraversalGraph(rnd));
      case "Dijkstra":
        return DijkstraShortestPath().performDijkstra(
          generatedWeightedShortestPathGraph(rnd),
        );
      case "A* Pathfinding":
        return AStarPathfinding().performAStar(
          generatedWeightedShortestPathGraph(rnd),
        );
      default:
        return [];
    }
  }

  @override
  VisualizerState build() {
    ref.onDispose(() => timer?.cancel());
    return VisualizerState.initial();
  }

  void initialize(
    Algorithm algorithm,
    List<int>? numbersList, {
    int? initialSpeedMs,
    bool autoPlay = false,
  }) {
    _playSessionId++;
    timer?.cancel(); // safe when reinitializing from another run
    timer = null;

    const int min = 20;
    const int max = 100;

    if (numbersList != null && numbersList.isNotEmpty) {
      numbers = List<int>.from(numbersList);
    } else {
      final int generatedCount = switch (algorithm.category) {
        AlgorithmCategory.Trees => rnd.nextInt(3) + 6,
        AlgorithmCategory.Graph => 7,
        AlgorithmCategory.DynamicProgramming => rnd.nextInt(4) + 6,
        AlgorithmCategory.Backtracking => rnd.nextInt(2) + 4,
        _ => rnd.nextInt(10) + 5,
      };
      numbers = List<int>.generate(
        generatedCount,
        (_) => min + rnd.nextInt(max - min + 1),
      );
    }

    algoSteps = algoForName(algorithm.name, numbers);

    final initialIndex = algoSteps.isNotEmpty ? 0 : -1;
    final metrics = initialIndex >= 0
        ? _metricsAtStepFromList(algoSteps, initialIndex)
        : (comparisons: 0, swaps: 0);

    state = state.copywith(
      array: List<int>.from(numbers), // keep original unsorted source in state
      steps: algoSteps,
      selectedAlgorithm: algorithm,
      stepIndex: 0,
      isPlaying: false,
      explanation: algoSteps.isNotEmpty ? algoSteps.first.opertation : "",
      comparisons: metrics.comparisons,
      swaps: metrics.swaps,
      speedMs: _sanitizeSpeed(initialSpeedMs ?? 1000),
    );

    if (autoPlay && state.steps.length > 1) {
      play();
    }
  }

  void loadSession({
    required Algorithm algorithm,
    required List<int> initialNumbers,
    required List<AlgoStep> steps,
    required int stepIndex,
    required int speedMs,
  }) {
    _playSessionId++;
    timer?.cancel();
    timer = null;

    if (steps.isEmpty) {
      initialize(algorithm, initialNumbers, initialSpeedMs: speedMs);
      return;
    }

    numbers = List<int>.from(initialNumbers);
    algoSteps = List<AlgoStep>.from(steps);

    final normalizedStep = stepIndex.clamp(0, algoSteps.length - 1);
    final metrics = _metricsAtStepFromList(algoSteps, normalizedStep);

    state = state.copywith(
      array: List<int>.from(numbers),
      steps: algoSteps,
      selectedAlgorithm: algorithm,
      stepIndex: normalizedStep,
      isPlaying: false,
      explanation: algoSteps[normalizedStep].opertation,
      comparisons: metrics.comparisons,
      swaps: metrics.swaps,
      speedMs: _sanitizeSpeed(speedMs),
    );
  }

  ({int comparisons, int swaps}) _metricsAtStepFromList(
    List<AlgoStep> steps,
    int stepIndex,
  ) {
    if (steps.isEmpty || stepIndex < 0) {
      return (comparisons: 0, swaps: 0);
    }

    final int safeIndex = min(stepIndex, steps.length - 1);
    int comparisons = 0;
    int swaps = 0;

    for (int i = 0; i <= safeIndex; i++) {
      final type = steps[i].stepType;
      if (type == AlgoStepType.compare || type == AlgoStepType.noSwap) {
        comparisons++;
      } else if (type == AlgoStepType.swap || type == AlgoStepType.overwrite) {
        swaps++;
      }
    }

    return (comparisons: comparisons, swaps: swaps);
  }

  void nextStep() {
    if (state.steps.isEmpty) return;
    final next = min(state.stepIndex + 1, state.steps.length - 1);
    final metrics = _metricsAtStep(next);
    state = state.copywith(
      stepIndex: next,
      explanation: state.steps[next].opertation,
      comparisons: metrics.comparisons,
      swaps: metrics.swaps,
    );
  }

  void previousStep() {
    if (state.steps.isEmpty) return;
    final previous = max(state.stepIndex - 1, 0);
    final metrics = _metricsAtStep(previous);
    state = state.copywith(
      stepIndex: previous,
      explanation: state.steps[previous].opertation,
      comparisons: metrics.comparisons,
      swaps: metrics.swaps,
    );
  }

  void play() {
    if (state.steps.length <= 1 || state.isPlaying) return;
    if (state.stepIndex >= state.steps.length - 1) return;

    _playSessionId++;
    final int localSession = _playSessionId;
    state = state.copywith(isPlaying: true);

    timer?.cancel();
    timer = Timer.periodic(Duration(milliseconds: state.speedMs), (t) {
      if (localSession != _playSessionId) {
        t.cancel();
        return;
      }

      if (state.stepIndex >= state.steps.length - 1) {
        t.cancel();
        timer = null;
        state = state.copywith(isPlaying: false);
        return;
      }
      nextStep();
    });
  }

  void pause() {
    _playSessionId++;
    timer?.cancel();
    timer = null;
    state = state.copywith(isPlaying: false);
  }

  void reset() {
    _playSessionId++;
    timer?.cancel();
    timer = null;
    if (state.steps.isEmpty) {
      state = state.copywith(
        stepIndex: 0,
        isPlaying: false,
        comparisons: 0,
        swaps: 0,
      );
      return;
    }

    final metrics = _metricsAtStep(0);
    state = state.copywith(
      stepIndex: 0,
      isPlaying: false,
      explanation: state.steps.first.opertation,
      comparisons: metrics.comparisons,
      swaps: metrics.swaps,
    );
  }

  void setSpeed(int ms) {
    final int sanitized = _sanitizeSpeed(ms);
    if (state.speedMs == sanitized) return;

    state = state.copywith(speedMs: sanitized);
    if (state.isPlaying) {
      pause();
      play();
    }
  }

  int _sanitizeSpeed(int ms) {
    return ms.clamp(_minSpeedMs, _maxSpeedMs);
  }
}
