import 'package:algo_visualizer/controllers/visualizer_controller.dart';
import 'package:algo_visualizer/controllers/app_settings_controller.dart';
import 'package:algo_visualizer/controllers/continue_learning_controller.dart';
import 'package:algo_visualizer/models/algo_step.dart';
import 'package:algo_visualizer/models/algorithms.dart';
import 'package:algo_visualizer/screens/source_code_screen.dart';
import 'package:algo_visualizer/states/visualizer_state.dart';
import 'package:algo_visualizer/widgets/graph_chart.dart';
import 'package:algo_visualizer/widgets/miniChart.dart';
import 'package:algo_visualizer/widgets/tree_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AlgorithmDetailsScreen extends ConsumerStatefulWidget {
  final Algorithm selectedAlgo;
  final List<int>? numbersList;
  final bool forceFresh;
  final bool fromDailyAlgorithm;
  const AlgorithmDetailsScreen({
    super.key,
    required this.selectedAlgo,
    this.numbersList,
    this.forceFresh = false,
    this.fromDailyAlgorithm = false,
  });

  @override
  ConsumerState<AlgorithmDetailsScreen> createState() =>
      _AlgorithmDetailsScreenState();
}

class _AlgorithmDetailsScreenState
    extends ConsumerState<AlgorithmDetailsScreen> {
  ProviderSubscription<VisualizerState>? _visualizerSubscription;

  Future<void> _initializeOrResumeSession() async {
    if (!mounted) return;

    final visualizer = ref.read(visualizerControllerProvier.notifier);
    final continueNotifier = ref.read(
      continueLearningControllerProvider.notifier,
    );
    await continueNotifier.ensureLoaded();

    final existing = continueNotifier.progressFor(widget.selectedAlgo.name);
    final bool shouldResume =
        !widget.forceFresh && existing != null && existing.steps.isNotEmpty;

    if (shouldResume) {
      visualizer.loadSession(
        algorithm: existing.algorithm,
        initialNumbers: existing.initialNumbers,
        steps: existing.steps,
        stepIndex: existing.stepIndex,
        speedMs: existing.speedMs,
      );
    } else {
      // Initialize steps immediately for chart availability.
      visualizer.initialize(widget.selectedAlgo, widget.numbersList);
    }

    try {
      final appSettings = await ref
          .read(appSettingsControllerProvider.notifier)
          .ensureLoaded();

      if (!mounted) return;

      if (!shouldResume) {
        visualizer.setSpeed(appSettings.defaultSpeedMs);
        if (appSettings.autoPlayOnOpen) {
          visualizer.play();
        }
      }
    } catch (_) {
      // Keep defaults/settings fallback behavior.
    }
  }

  void _startFreshRun() {
    final visualizer = ref.read(visualizerControllerProvier.notifier);
    final settings = ref.read(appSettingsControllerProvider);
    visualizer.initialize(widget.selectedAlgo, null);
    visualizer.setSpeed(settings.defaultSpeedMs);
    if (settings.autoPlayOnOpen) {
      visualizer.play();
    }
  }

  Future<void> _showRefreshOptionsDialog() async {
    final controller = ref.read(visualizerControllerProvier.notifier);

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1B1429),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFF2E243F), width: 1.2),
          ),
          title: const Text(
            'Refresh Options',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          content: const Text(
            'Choose how you want to continue with this algorithm.',
            style: TextStyle(fontSize: 13, color: Colors.white70),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          actions: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0x6D00EEFF)),
                foregroundColor: const Color(0xFF00EEFF),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
              ),
              onPressed: () {
                Navigator.pop(dialogContext);
                controller.reset();
              },
              child: const Text('Reset Algorithm'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.purpleAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
              ),
              onPressed: () {
                Navigator.pop(dialogContext);
                _startFreshRun();
              },
              child: const Text('Refresh with new data'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    final continueNotifier = ref.read(
      continueLearningControllerProvider.notifier,
    );
    _visualizerSubscription = ref.listenManual(visualizerControllerProvier, (
      previous,
      next,
    ) {
      if (!mounted) return;
      final selected = next.selectedAlgorithm;
      if (selected == null || next.steps.isEmpty) return;

      continueNotifier.upsertProgress(
        algorithm: selected,
        initialNumbers: next.array,
        steps: next.steps,
        stepIndex: next.stepIndex,
        speedMs: next.speedMs,
      );
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeOrResumeSession();
    });
  }

  @override
  void dispose() {
    _visualizerSubscription?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(visualizerControllerProvier);
    final controller = ref.read(visualizerControllerProvier.notifier);
    final showMetrics = ref.watch(
      appSettingsControllerProvider.select((s) => s.showMetrics),
    );
    final animationScaleSetting = ref.watch(
      appSettingsControllerProvider.select((s) => s.animationScale),
    );
    final hasSteps = state.steps.isNotEmpty;
    final isAtStart = !hasSteps || state.stepIndex == 0;
    final isAtEnd = hasSteps && state.stepIndex >= state.steps.length - 1;
    final currentStep = hasSteps ? state.steps[state.stepIndex] : null;
    final bool isSortingAlgorithm =
        widget.selectedAlgo.category == AlgorithmCategory.Sorting;
    final bool isTreeAlgorithm =
        widget.selectedAlgo.category == AlgorithmCategory.Trees;
    final bool isGraphAlgorithm =
        widget.selectedAlgo.category == AlgorithmCategory.Graph;
    final double animationScale = animationScaleSetting.clamp(0.5, 1.5);
    Duration scaledDuration(int baseMs) {
      final int raw = (baseMs * animationScale).round();
      return Duration(milliseconds: raw.clamp(100, 3000));
    }

    final String currentEvent = isTreeAlgorithm
        ? switch (currentStep?.stepType) {
            AlgoStepType.compare => 'Compare',
            AlgoStepType.noSwap => 'Traverse',
            AlgoStepType.swap => 'Rotate',
            AlgoStepType.overwrite => 'Update',
            AlgoStepType.done when currentStep?.searchHit == true => 'Found',
            AlgoStepType.done => 'Done',
            _ => 'Visit',
          }
        : isGraphAlgorithm
        ? switch (currentStep?.stepType) {
            AlgoStepType.compare => 'Visit',
            AlgoStepType.noSwap => 'Explore',
            AlgoStepType.overwrite => 'Relax',
            AlgoStepType.done when currentStep?.searchHit == true => 'Found',
            AlgoStepType.done => 'Done',
            _ => 'Step',
          }
        : switch (currentStep?.stepType) {
            AlgoStepType.compare => 'Compare',
            AlgoStepType.swap => 'Swap',
            AlgoStepType.overwrite => 'Overwrite',
            AlgoStepType.noSwap => 'No Swap',
            AlgoStepType.done => 'Done',
            _ => 'Unknown',
          };
    final Map<int, Color> highlightMap = (isTreeAlgorithm || isGraphAlgorithm)
        ? const <int, Color>{}
        : switch (currentStep?.stepType) {
            AlgoStepType.overwrite when currentStep != null => {
              if (currentStep.i >= 0) currentStep.i: Colors.greenAccent,
              if (currentStep.j >= 0) currentStep.j: Colors.orangeAccent,
            },
            AlgoStepType.compare ||
            AlgoStepType.swap ||
            AlgoStepType.noSwap when currentStep != null => {
              if (currentStep.i >= 0) currentStep.i: Colors.purple,
              if (currentStep.j >= 0) currentStep.j: Colors.cyan,
            },
            _ => const <int, Color>{},
          };
    final Map<int, String> markerLabels = (isTreeAlgorithm || isGraphAlgorithm)
        ? const <int, String>{}
        : switch (currentStep?.stepType) {
            AlgoStepType.overwrite when currentStep != null => {
              if (currentStep.i >= 0) currentStep.i: 'write',
              if (currentStep.j >= 0 && currentStep.j != currentStep.i)
                currentStep.j: 'src',
            },
            _ => {
              if (currentStep != null && currentStep.i >= 0) currentStep.i: 'i',
              if (currentStep != null &&
                  currentStep.j >= 0 &&
                  currentStep.j != currentStep.i)
                currentStep.j: 'j',
            },
          };

    String activeTreeNodeValue() {
      if (currentStep == null) return '?';
      if (currentStep.activeNodeIndex < 0) return '?';
      return (currentStep.treeSnapshot[currentStep.activeNodeIndex] ?? '?')
          .toString();
    }

    String graphNodeLabel(int index) {
      if (index < 0) return '?';
      if (index >= 0 && index <= 25) {
        return String.fromCharCode(65 + index);
      }
      return '$index';
    }

    final String operationTarget = isTreeAlgorithm
        ? switch (currentStep?.stepType) {
            AlgoStepType.compare when currentStep != null =>
              currentStep.targetValue >= 0
                  ? 'Node ${activeTreeNodeValue()} vs Target ${currentStep.targetValue}'
                  : 'Node ${activeTreeNodeValue()}',
            AlgoStepType.noSwap when currentStep != null =>
              currentStep.targetValue >= 0
                  ? 'Target ${currentStep.targetValue}'
                  : 'Traversal path',
            AlgoStepType.swap when currentStep != null =>
              'Rotation at Node ${activeTreeNodeValue()}',
            AlgoStepType.done
                when currentStep != null && currentStep.searchHit =>
              'Target ${currentStep.targetValue} found',
            AlgoStepType.done when currentStep != null =>
              currentStep.targetValue >= 0
                  ? 'Target ${currentStep.targetValue} not found'
                  : 'Traversal completed',
            _ => 'Tree traversal',
          }
        : isGraphAlgorithm
        ? switch (currentStep?.stepType) {
            AlgoStepType.compare
                when currentStep != null && currentStep.i >= 0 =>
              'Node ${graphNodeLabel(currentStep.i)}',
            AlgoStepType.overwrite
                when currentStep != null &&
                    currentStep.i >= 0 &&
                    currentStep.j >= 0 =>
              '${graphNodeLabel(currentStep.i)} -> ${graphNodeLabel(currentStep.j)}',
            AlgoStepType.noSwap
                when currentStep != null &&
                    currentStep.i >= 0 &&
                    currentStep.j >= 0 =>
              '${graphNodeLabel(currentStep.i)} -> ${graphNodeLabel(currentStep.j)}',
            AlgoStepType.done
                when currentStep != null && currentStep.searchHit =>
              'Path to ${graphNodeLabel(currentStep.targetNodeIndex)}',
            AlgoStepType.done when currentStep != null =>
              'Target ${graphNodeLabel(currentStep.targetNodeIndex)} unreachable',
            _ => 'Graph traversal',
          }
        : switch (currentStep?.stepType) {
            AlgoStepType.overwrite
                when currentStep != null && currentStep.i >= 0 =>
              'arr[${currentStep.i}] <- arr[${currentStep.j}]',
            _
                when currentStep == null ||
                    currentStep.i < 0 ||
                    currentStep.j < 0 =>
              'No active indices',
            _ => 'arr[${currentStep.i}], arr[${currentStep.j}]',
          };
    String valueAt(int index) {
      if (currentStep == null) return '?';
      if (index < 0 || index >= currentStep.numbersSnapshot.length) return '?';
      return currentStep.numbersSnapshot[index].toString();
    }

    final String chartNarration = isTreeAlgorithm
        ? switch (currentStep?.stepType) {
            AlgoStepType.compare when currentStep != null =>
              currentStep.targetValue >= 0
                  ? 'Comparing target ${currentStep.targetValue} with current node ${activeTreeNodeValue()}.'
                  : 'Visiting node ${activeTreeNodeValue()} as part of traversal.',
            AlgoStepType.noSwap when currentStep != null =>
              currentStep.opertation,
            AlgoStepType.swap when currentStep != null =>
              'Performing AVL rotation to rebalance the tree.',
            AlgoStepType.done
                when currentStep != null && currentStep.searchHit =>
              'Target ${currentStep.targetValue} found in the BST.',
            AlgoStepType.done when currentStep != null =>
              currentStep.targetValue >= 0
                  ? 'Target ${currentStep.targetValue} does not exist in the BST.'
                  : 'Traversal completed for current tree snapshot.',
            _ => 'Generate steps to start visualizing tree traversal flow.',
          }
        : isGraphAlgorithm
        ? (currentStep?.opertation ??
              'Generate steps to start visualizing graph exploration.')
        : switch (currentStep?.stepType) {
            AlgoStepType.compare when currentStep != null =>
              'Comparing index ${currentStep.i} (value ${valueAt(currentStep.i)}) with '
                  'index ${currentStep.j} (value ${valueAt(currentStep.j)}).',
            AlgoStepType.swap when currentStep != null =>
              'Swapping values around indices ${currentStep.i} and ${currentStep.j}.',
            AlgoStepType.noSwap when currentStep != null =>
              'No swap needed at indices ${currentStep.i} and ${currentStep.j}.',
            AlgoStepType.overwrite when currentStep != null =>
              'Writing value into index ${currentStep.i} using source index ${currentStep.j}.',
            AlgoStepType.done =>
              isSortingAlgorithm
                  ? 'Sorting is complete. Final order reached.'
                  : 'Execution is complete for this algorithm.',
            _ => 'Generate steps to start visualizing the algorithm flow.',
          };
    const int minSpeedMs = 150;
    const int maxSpeedMs = 2000;
    final double speedSliderValue = state.speedMs
        .clamp(minSpeedMs, maxSpeedMs)
        .toDouble();
    final int traversalCount = !hasSteps
        ? 0
        : (isTreeAlgorithm || isGraphAlgorithm)
        ? ((currentStep?.traversalPathIndices.isNotEmpty ?? false)
              ? currentStep!.traversalPathIndices.length
              : state.steps
                    .take(state.stepIndex + 1)
                    .where(
                      (s) =>
                          s.stepType == AlgoStepType.compare ||
                          s.stepType == AlgoStepType.noSwap,
                    )
                    .length)
        : 0;

    return WillPopScope(
      onWillPop: () async {
        if (state.isPlaying) {
          controller.pause();
        }
        return true;
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Color(0x9E2E243F),
                          borderRadius: BorderRadius.circular(60),
                        ),
                        child: IconButton(
                          onPressed: () {
                            if (state.isPlaying) {
                              controller.pause();
                            }
                            Navigator.pop(context);
                          },
                          icon: Icon(Icons.arrow_back, size: 20),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          widget.selectedAlgo.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      widget.fromDailyAlgorithm
                          ? SizedBox(width: 40, height: 40)
                          : Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Color(0x9E2E243F),
                                borderRadius: BorderRadius.circular(60),
                              ),
                              child: IconButton(
                                tooltip: 'Refresh with new data',
                                onPressed: _showRefreshOptionsDialog,
                                icon: Icon(Icons.refresh, size: 20),
                              ),
                            ),
                    ],
                  ),
                  SizedBox(height: 25),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  width: 2,
                                  color: const Color.fromARGB(141, 54, 54, 54),
                                ),
                                color: Colors.transparent,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: "Snaps ",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      TextSpan(
                                        text: ": ${state.steps.length} ",
                                        style: TextStyle(color: Colors.cyan),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                width: 2,
                                color: const Color.fromARGB(141, 54, 54, 54),
                              ),
                              color: Colors.transparent,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "Time: ",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    TextSpan(
                                      text: ": 0.45ms ",
                                      style: TextStyle(color: Colors.cyan),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          if (currentStep != null &&
                              isGraphAlgorithm &&
                              currentStep.treeSnapshot.isNotEmpty)
                            GraphChart(
                              nodes: currentStep.treeSnapshot,
                              edges: currentStep.graphEdges,
                              weights: currentStep.graphWeights,
                              costs: currentStep.graphCosts,
                              activeNodeIndex: currentStep.activeNodeIndex,
                              targetNodeIndex: currentStep.targetNodeIndex,
                              activeEdgeFrom: currentStep.i,
                              activeEdgeTo: currentStep.j,
                              frontierNodeIndices:
                                  currentStep.frontierNodeIndices,
                              traversalPathIndices:
                                  currentStep.traversalPathIndices,
                              searchHit: currentStep.searchHit,
                              animationDuration: scaledDuration(450),
                            )
                          else if (currentStep != null &&
                              isTreeAlgorithm &&
                              currentStep.treeSnapshot.isNotEmpty)
                            TreeChart(
                              nodes: currentStep.treeSnapshot,
                              activeNodeIndex: currentStep.activeNodeIndex,
                              targetValue: currentStep.targetValue,
                              targetNodeIndex: currentStep.targetNodeIndex,
                              traversalPathIndices:
                                  currentStep.traversalPathIndices,
                              searchHit: currentStep.searchHit,
                              animationDuration: scaledDuration(450),
                            )
                          else if (currentStep != null)
                            Minichart(
                              numbers: currentStep.numbersSnapshot,
                              highLightMap: highlightMap,
                              markerLabels: markerLabels,
                              defaultColor: Color(0xFF2F2542),
                              animationDuration: scaledDuration(500),
                              colorAnimationDuration: scaledDuration(750),
                            )
                          else
                            SizedBox(
                              height: 140,
                              child: Center(
                                child: Text(
                                  'No steps available',
                                  style: TextStyle(color: Colors.white70),
                                ),
                              ),
                            ),
                          SizedBox(height: 10),
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white24),
                              color: const Color.fromARGB(20, 255, 255, 255),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            child: Text(
                              chartNarration,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white70,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        hasSteps
                            ? "Step ${state.stepIndex + 1}/${state.steps.length}"
                            : "Step 0/0",
                        style: TextStyle(fontSize: 12, color: Colors.cyan),
                      ),
                      Text(
                        isAtEnd ? "Completed" : "In Progress",
                        style: TextStyle(
                          fontSize: 12,
                          color: isAtEnd
                              ? Colors.greenAccent
                              : Colors.purpleAccent,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                  if (isAtEnd)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        "Done: reached final step",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.greenAccent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: hasSteps
                        ? ((state.stepIndex + 1) / state.steps.length).clamp(
                            0.0,
                            1.0,
                          )
                        : 0.0,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.purpleAccent,
                  ),
                  SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Color(0x9E2E243F),
                          borderRadius: BorderRadius.circular(60),
                        ),
                        child: IconButton(
                          onPressed: isAtStart
                              ? null
                              : () {
                                  if (state.isPlaying) controller.pause();
                                  controller.previousStep();
                                },
                          icon: Icon(Icons.skip_previous, size: 30),
                        ),
                      ),
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: hasSteps
                              ? Colors.purpleAccent
                              : Color(0x9E2E243F),
                          borderRadius: BorderRadius.circular(60),
                        ),
                        child: AnimatedSwitcher(
                          duration: scaledDuration(100),
                          transitionBuilder: (child, animation) =>
                              ScaleTransition(scale: animation, child: child),
                          child: IconButton(
                            key: ValueKey(
                              '${state.isPlaying}-$isAtEnd-$hasSteps',
                            ),
                            icon: state.isPlaying
                                ? Icon(Icons.pause_circle_outline, size: 50)
                                : (isAtEnd
                                      ? Icon(
                                          Icons.replay_circle_filled_outlined,
                                          size: 50,
                                        )
                                      : Icon(
                                          Icons.play_circle_outline,
                                          size: 50,
                                        )),
                            onPressed: !hasSteps
                                ? null
                                : (state.isPlaying
                                      ? () {
                                          controller.pause();
                                        }
                                      : (isAtEnd
                                            ? () {
                                                controller.reset();
                                                controller.play();
                                              }
                                            : () {
                                                controller.play();
                                              })),
                          ),
                        ),
                      ),
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Color(0x9E2E243F),
                          borderRadius: BorderRadius.circular(60),
                        ),
                        child: IconButton(
                          onPressed: isAtEnd
                              ? null
                              : () {
                                  if (state.isPlaying) controller.pause();
                                  controller.nextStep();
                                },
                          icon: Icon(Icons.skip_next, size: 30),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    !hasSteps
                        ? "No steps to visualize"
                        : isAtEnd
                        ? "Playback completed. Press Reset Button to replay."
                        : state.isPlaying
                        ? "Auto-play running"
                        : "Manual mode",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  if (showMetrics) ...[
                    SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _MetricCard(
                            label: "Comparisons",
                            value: state.comparisons.toString(),
                            accent: Colors.cyanAccent,
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: _MetricCard(
                            label: isTreeAlgorithm
                                ? "Traversals"
                                : isGraphAlgorithm
                                ? "Visited"
                                : isSortingAlgorithm
                                ? "Swaps"
                                : "Updates",
                            value: (isTreeAlgorithm || isGraphAlgorithm)
                                ? traversalCount.toString()
                                : state.swaps.toString(),
                            accent: Colors.purpleAccent,
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: _MetricCard(
                            label: "Event",
                            value: currentEvent,
                            accent: Colors.greenAccent,
                          ),
                        ),
                      ],
                    ),
                  ],
                  SizedBox(height: 14),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: Colors.cyan,
                                  borderRadius: BorderRadius.circular(60),
                                ),
                                child: Icon(
                                  Icons.navigate_next_outlined,
                                  size: 20,
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  "Current Operation",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                width: 75,
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(30, 0, 238, 255),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.cyanAccent,
                                    width: 1.2,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    currentEvent,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.cyanAccent,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Container(
                            width: double.infinity,
                            height: 118,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.black,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  RichText(
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    text: TextSpan(
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.blueGrey,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: "$currentEvent  ",
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.purpleAccent,
                                          ),
                                        ),
                                        TextSpan(text: operationTarget),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    currentStep?.opertation ??
                                        state.explanation,
                                    style: TextStyle(fontSize: 14),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 150,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: Color(0xFF0D2130),
                                  border: Border.all(
                                    width: 2,
                                    color: Colors.purple,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    "Time: ${widget.selectedAlgo.timeComplexity}",
                                    style: TextStyle(
                                      color: Colors.purpleAccent,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 125,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: Color(0xFF0D2130),
                                  border: Border.all(
                                    width: 2,
                                    color: Color(0x6D00EEFF),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    "Space: ${widget.selectedAlgo.spaceComplexity}",
                                    style: TextStyle(color: Color(0xFF00EEFF)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Playback Speed",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                "${state.speedMs} ms/step",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.cyanAccent,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _PresetButton(
                                label: "0.5x",
                                speedMs: 2000,
                                isActive: state.speedMs == 2000,
                                onPressed: hasSteps
                                    ? () => controller.setSpeed(2000)
                                    : null,
                              ),
                              _PresetButton(
                                label: "1x",
                                speedMs: 1000,
                                isActive: state.speedMs == 1000,
                                onPressed: hasSteps
                                    ? () => controller.setSpeed(1000)
                                    : null,
                              ),
                              _PresetButton(
                                label: "2x",
                                speedMs: 500,
                                isActive: state.speedMs == 500,
                                onPressed: hasSteps
                                    ? () => controller.setSpeed(500)
                                    : null,
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Slider(
                            value: speedSliderValue,
                            min: minSpeedMs.toDouble(),
                            max: maxSpeedMs.toDouble(),
                            divisions: 37,
                            label: "${state.speedMs} ms",
                            onChanged: hasSteps
                                ? (value) {
                                    controller.setSpeed(value.round());
                                  }
                                : null,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Fast",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white70,
                                ),
                              ),
                              Text(
                                "Slow",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 1,
          onTap: (index) {
            if (state.isPlaying) {
              controller.pause();
            }
            if (index == 0) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/home-screen',
                (route) => false,
              );
            } else if (index == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      SourceCodeScreen(selectedAlgo: widget.selectedAlgo),
                ),
              );
            }
          },
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(
              icon: Icon(Icons.stacked_bar_chart),
              label: "Visualize",
            ),
            BottomNavigationBarItem(icon: Icon(Icons.code), label: "Source"),
          ],
        ),
      ),
    );
  }
}

class _PresetButton extends StatelessWidget {
  final String label;
  final int speedMs;
  final bool isActive;
  final VoidCallback? onPressed;

  const _PresetButton({
    required this.label,
    required this.speedMs,
    required this.isActive,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isActive ? Colors.cyanAccent : Colors.white30,
              width: isActive ? 2 : 1,
            ),
            color: isActive
                ? const Color.fromARGB(40, 0, 238, 255)
                : Colors.transparent,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.cyanAccent : Colors.white70,
            ),
          ),
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final Color accent;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0x9E2E243F),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: accent.withValues(alpha: 0.65), width: 1.3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.white70),
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: accent,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
