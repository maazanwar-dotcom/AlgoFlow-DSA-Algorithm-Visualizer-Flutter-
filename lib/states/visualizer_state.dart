import 'package:algo_visualizer/models/algo_step.dart';
import 'package:algo_visualizer/models/algorithms.dart';

class VisualizerState {
  final List<int> array;
  final List<AlgoStep> steps;
  final int stepIndex;
  final bool isPlaying;
  final int speedMs;
  final Algorithm? selectedAlgorithm;
  final int comparisons;
  final int swaps;
  final String explanation;

  VisualizerState({
    required this.array,
    required this.steps,
    required this.stepIndex,
    required this.isPlaying,
    required this.speedMs,
    required this.selectedAlgorithm,
    required this.comparisons,
    required this.swaps,
    required this.explanation,
  });
  static VisualizerState initial() {
    return VisualizerState(
      array: [],
      steps: [],
      stepIndex: 0,
      isPlaying: false,
      speedMs: 1000,
      selectedAlgorithm: null,
      comparisons: 0,
      swaps: 0,
      explanation: '',
    );
  }

  VisualizerState copywith({
    List<int>? array,
    List<AlgoStep>? steps,
    int? stepIndex,
    bool? isPlaying,
    int? speedMs,
    Algorithm? selectedAlgorithm,
    int? comparisons,
    int? swaps,
    String? explanation,
  }) {
    return VisualizerState(
      array: array ?? this.array,
      steps: steps ?? this.steps,
      stepIndex: stepIndex ?? this.stepIndex,
      isPlaying: isPlaying ?? this.isPlaying,
      speedMs: speedMs ?? this.speedMs,
      selectedAlgorithm: selectedAlgorithm ?? this.selectedAlgorithm,
      comparisons: comparisons ?? this.comparisons,
      swaps: swaps ?? this.swaps,
      explanation: explanation ?? this.explanation,
    );
  }
}
