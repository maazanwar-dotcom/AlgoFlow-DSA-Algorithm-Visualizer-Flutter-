import 'package:algo_visualizer/models/algo_step.dart';
import 'package:algo_visualizer/models/algorithms.dart';

class LearningProgress {
  final Algorithm algorithm;
  final List<int> initialNumbers;
  final List<AlgoStep> steps;
  final int stepIndex;
  final int speedMs;
  final DateTime updatedAt;

  const LearningProgress({
    required this.algorithm,
    required this.initialNumbers,
    required this.steps,
    required this.stepIndex,
    required this.speedMs,
    required this.updatedAt,
  });

  bool get isCompleted {
    return steps.isNotEmpty && stepIndex >= steps.length - 1;
  }

  double get completion {
    if (steps.isEmpty) return 0.0;
    return ((stepIndex + 1) / steps.length).clamp(0.0, 1.0);
  }

  LearningProgress copyWith({
    Algorithm? algorithm,
    List<int>? initialNumbers,
    List<AlgoStep>? steps,
    int? stepIndex,
    int? speedMs,
    DateTime? updatedAt,
  }) {
    return LearningProgress(
      algorithm: algorithm ?? this.algorithm,
      initialNumbers: initialNumbers ?? this.initialNumbers,
      steps: steps ?? this.steps,
      stepIndex: stepIndex ?? this.stepIndex,
      speedMs: speedMs ?? this.speedMs,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
