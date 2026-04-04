import 'dart:async';
import 'dart:convert';

import 'package:algo_visualizer/models/algo_step.dart';
import 'package:algo_visualizer/models/algorithms.dart';
import 'package:algo_visualizer/models/learning_progress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final continueLearningControllerProvider =
    NotifierProvider<ContinueLearningController, Map<String, LearningProgress>>(
      ContinueLearningController.new,
    );

class ContinueLearningController
    extends Notifier<Map<String, LearningProgress>> {
  static const String _progressStorageKey = 'continue.learning.progress.v1';
  bool _loaded = false;
  Future<void>? _loadFuture;

  @override
  Map<String, LearningProgress> build() {
    if (!_loaded) {
      unawaited(ensureLoaded());
    }
    return <String, LearningProgress>{};
  }

  Future<void> ensureLoaded() {
    if (_loaded) {
      return Future.value();
    }
    if (_loadFuture != null) {
      return _loadFuture!;
    }

    _loadFuture = _loadFromStorage();
    return _loadFuture!;
  }

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_progressStorageKey);
      if (raw == null || raw.isEmpty) {
        state = <String, LearningProgress>{};
        return;
      }

      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        state = <String, LearningProgress>{};
        return;
      }

      final loaded = <String, LearningProgress>{};

      for (final item in decoded) {
        if (item is! Map) continue;
        final parsed = _progressFromJson(Map<String, dynamic>.from(item));
        if (parsed == null) continue;
        loaded[parsed.algorithm.name] = parsed;
      }

      state = loaded;
    } catch (_) {
      state = <String, LearningProgress>{};
    } finally {
      _loaded = true;
      _loadFuture = null;
    }
  }

  Future<void> _persistState(Map<String, LearningProgress> source) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = source.values.toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      final payload = jsonEncode(
        list.map((progress) => _progressToJson(progress)).toList(),
      );
      await prefs.setString(_progressStorageKey, payload);
    } catch (_) {
      // Best-effort persistence; keep in-memory state even if disk write fails.
    }
  }

  LearningProgress? progressFor(String algorithmName) {
    return state[algorithmName];
  }

  void upsertProgress({
    required Algorithm algorithm,
    required List<int> initialNumbers,
    required List<AlgoStep> steps,
    required int stepIndex,
    required int speedMs,
  }) {
    if (steps.isEmpty) return;

    final normalizedStepIndex = stepIndex.clamp(0, steps.length - 1);

    final progress = LearningProgress(
      algorithm: algorithm,
      initialNumbers: List<int>.from(initialNumbers),
      steps: List<AlgoStep>.from(steps),
      stepIndex: normalizedStepIndex,
      speedMs: speedMs,
      updatedAt: DateTime.now(),
    );

    final next = {...state, algorithm.name: progress};
    state = next;
    unawaited(_persistState(next));
  }

  void removeProgress(String algorithmName) {
    if (!state.containsKey(algorithmName)) return;
    final next = Map<String, LearningProgress>.from(state);
    next.remove(algorithmName);
    state = next;
    unawaited(_persistState(next));
  }

  Map<String, dynamic> _progressToJson(LearningProgress progress) {
    return <String, dynamic>{
      'algorithm': _algorithmToJson(progress.algorithm),
      'initialNumbers': progress.initialNumbers,
      'steps': progress.steps.map((step) => _algoStepToJson(step)).toList(),
      'stepIndex': progress.stepIndex,
      'speedMs': progress.speedMs,
      'updatedAt': progress.updatedAt.toIso8601String(),
    };
  }

  LearningProgress? _progressFromJson(Map<String, dynamic> json) {
    final algorithmRaw = json['algorithm'];
    if (algorithmRaw is! Map) return null;
    final algorithm = _algorithmFromJson(
      Map<String, dynamic>.from(algorithmRaw),
    );
    if (algorithm == null) return null;

    final initialRaw = json['initialNumbers'];
    final stepsRaw = json['steps'];
    if (initialRaw is! List || stepsRaw is! List) return null;

    final initialNumbers = <int>[];
    for (final value in initialRaw) {
      if (value is! num) return null;
      initialNumbers.add(value.toInt());
    }

    final steps = <AlgoStep>[];
    for (final rawStep in stepsRaw) {
      if (rawStep is! Map) continue;
      final parsedStep = _algoStepFromJson(Map<String, dynamic>.from(rawStep));
      if (parsedStep != null) {
        steps.add(parsedStep);
      }
    }
    if (steps.isEmpty) return null;

    final int stepIndex = (json['stepIndex'] is num)
        ? (json['stepIndex'] as num).toInt().clamp(0, steps.length - 1)
        : 0;
    final int speedMs = (json['speedMs'] is num)
        ? (json['speedMs'] as num).toInt()
        : 1000;
    final String updatedAtRaw = (json['updatedAt'] ?? '').toString();
    final DateTime updatedAt =
        DateTime.tryParse(updatedAtRaw) ?? DateTime.now();

    return LearningProgress(
      algorithm: algorithm,
      initialNumbers: initialNumbers,
      steps: steps,
      stepIndex: stepIndex,
      speedMs: speedMs,
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> _algorithmToJson(Algorithm algorithm) {
    return <String, dynamic>{
      'name': algorithm.name,
      'tagline': algorithm.tagline,
      'difficulty': algorithm.difficulty.name,
      'timeComplexity': algorithm.timeComplexity,
      'spaceComplexity': algorithm.spaceComplexity,
      'type': algorithm.type.name,
      'category': algorithm.category.name,
    };
  }

  Algorithm? _algorithmFromJson(Map<String, dynamic> json) {
    final name = json['name']?.toString();
    final tagline = json['tagline']?.toString();
    final timeComplexity = json['timeComplexity']?.toString();
    final spaceComplexity = json['spaceComplexity']?.toString();
    final difficulty = _enumFromName(
      Difficulty.values,
      json['difficulty']?.toString(),
    );
    final type = _enumFromName(AlgorithmType.values, json['type']?.toString());
    final category = _enumFromName(
      AlgorithmCategory.values,
      json['category']?.toString(),
    );

    if (name == null ||
        tagline == null ||
        timeComplexity == null ||
        spaceComplexity == null ||
        difficulty == null ||
        type == null ||
        category == null) {
      return null;
    }

    return Algorithm(
      name: name,
      tagline: tagline,
      difficulty: difficulty,
      timeComplexity: timeComplexity,
      spaceComplexity: spaceComplexity,
      type: type,
      category: category,
    );
  }

  Map<String, dynamic> _algoStepToJson(AlgoStep step) {
    return <String, dynamic>{
      'numbersSnapshot': step.numbersSnapshot,
      'operation': step.opertation,
      'i': step.i,
      'j': step.j,
      'stepType': step.stepType.name,
      'treeSnapshot': step.treeSnapshot.map(
        (key, value) => MapEntry(key.toString(), value),
      ),
      'graphEdges': step.graphEdges,
      'graphWeights': step.graphWeights,
      'graphCosts': step.graphCosts.map(
        (key, value) => MapEntry(key.toString(), value),
      ),
      'frontierNodeIndices': step.frontierNodeIndices,
      'activeNodeIndex': step.activeNodeIndex,
      'targetValue': step.targetValue,
      'targetNodeIndex': step.targetNodeIndex,
      'traversalPathIndices': step.traversalPathIndices,
      'searchHit': step.searchHit,
    };
  }

  AlgoStep? _algoStepFromJson(Map<String, dynamic> json) {
    final numbersRaw = json['numbersSnapshot'];
    if (numbersRaw is! List) return null;

    final numbers = <int>[];
    for (final value in numbersRaw) {
      if (value is! num) return null;
      numbers.add(value.toInt());
    }

    final treeSnapshot = <int, int>{};
    final treeSnapshotRaw = json['treeSnapshot'];
    if (treeSnapshotRaw is Map) {
      for (final entry in treeSnapshotRaw.entries) {
        final int? index = int.tryParse(entry.key.toString());
        final value = entry.value;
        if (index == null || value is! num) continue;
        treeSnapshot[index] = value.toInt();
      }
    }

    final traversalPath = <int>[];
    final traversalRaw = json['traversalPathIndices'];
    if (traversalRaw is List) {
      for (final value in traversalRaw) {
        if (value is! num) continue;
        traversalPath.add(value.toInt());
      }
    }

    final graphEdges = <List<int>>[];
    final graphEdgesRaw = json['graphEdges'];
    if (graphEdgesRaw is List) {
      for (final rawEdge in graphEdgesRaw) {
        if (rawEdge is! List || rawEdge.length != 2) continue;
        final first = rawEdge[0];
        final second = rawEdge[1];
        if (first is! num || second is! num) continue;
        graphEdges.add(<int>[first.toInt(), second.toInt()]);
      }
    }

    final graphWeights = <String, int>{};
    final graphWeightsRaw = json['graphWeights'];
    if (graphWeightsRaw is Map) {
      for (final entry in graphWeightsRaw.entries) {
        final value = entry.value;
        if (value is! num) continue;
        graphWeights[entry.key.toString()] = value.toInt();
      }
    }

    final graphCosts = <int, int>{};
    final graphCostsRaw = json['graphCosts'];
    if (graphCostsRaw is Map) {
      for (final entry in graphCostsRaw.entries) {
        final int? key = int.tryParse(entry.key.toString());
        final value = entry.value;
        if (key == null || value is! num) continue;
        graphCosts[key] = value.toInt();
      }
    }

    final frontierNodes = <int>[];
    final frontierRaw = json['frontierNodeIndices'];
    if (frontierRaw is List) {
      for (final value in frontierRaw) {
        if (value is! num) continue;
        frontierNodes.add(value.toInt());
      }
    }

    final operation = (json['operation'] ?? json['opertation'] ?? '')
        .toString();

    return AlgoStep(
      numbersSnapshot: numbers,
      opertation: operation,
      i: (json['i'] is num) ? (json['i'] as num).toInt() : -1,
      j: (json['j'] is num) ? (json['j'] as num).toInt() : -1,
      stepType:
          _enumFromName(AlgoStepType.values, json['stepType']?.toString()) ??
          AlgoStepType.unknown,
      treeSnapshot: treeSnapshot,
      graphEdges: graphEdges,
      graphWeights: graphWeights,
      graphCosts: graphCosts,
      frontierNodeIndices: frontierNodes,
      activeNodeIndex: (json['activeNodeIndex'] is num)
          ? (json['activeNodeIndex'] as num).toInt()
          : -1,
      targetValue: (json['targetValue'] is num)
          ? (json['targetValue'] as num).toInt()
          : -1,
      targetNodeIndex: (json['targetNodeIndex'] is num)
          ? (json['targetNodeIndex'] as num).toInt()
          : -1,
      traversalPathIndices: traversalPath,
      searchHit: json['searchHit'] == true,
    );
  }

  T? _enumFromName<T extends Enum>(List<T> values, String? name) {
    if (name == null || name.isEmpty) return null;
    for (final value in values) {
      if (value.name == name) {
        return value;
      }
    }
    return null;
  }
}
