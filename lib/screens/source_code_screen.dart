import 'package:algo_visualizer/controllers/visualizer_controller.dart';
import 'package:algo_visualizer/data/pseudocode_data.dart';
import 'package:algo_visualizer/models/algo_step.dart';
import 'package:algo_visualizer/models/algorithms.dart';
import 'package:algo_visualizer/widgets/graph_chart.dart';
import 'package:algo_visualizer/widgets/miniChart.dart';
import 'package:algo_visualizer/widgets/tree_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SourceCodeScreen extends ConsumerStatefulWidget {
  final Algorithm selectedAlgo;

  const SourceCodeScreen({super.key, required this.selectedAlgo});

  @override
  ConsumerState<SourceCodeScreen> createState() => _SourceCodeScreenState();
}

class _SourceCodeScreenState extends ConsumerState<SourceCodeScreen> {
  final ScrollController _codeScrollController = ScrollController();
  int? _lastScrolledLine;

  static const double _approxLineHeight = 38;

  void _followHighlightedLine(int? lineIndex) {
    if (lineIndex == null || lineIndex < 0) return;
    if (_lastScrolledLine == lineIndex) return;
    _lastScrolledLine = lineIndex;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_codeScrollController.hasClients) return;

      final viewport = _codeScrollController.position.viewportDimension;
      final targetOffset =
          (lineIndex * _approxLineHeight) -
          (viewport / 2) +
          (_approxLineHeight / 2);
      final clampedOffset = targetOffset.clamp(
        0.0,
        _codeScrollController.position.maxScrollExtent,
      );

      _codeScrollController.animateTo(
        clampedOffset,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _codeScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(visualizerControllerProvier);
    final controller = ref.read(visualizerControllerProvier.notifier);

    final hasSteps = state.steps.isNotEmpty;
    final isAtStart = !hasSteps || state.stepIndex == 0;
    final isAtEnd = hasSteps && state.stepIndex >= state.steps.length - 1;
    final currentStep = hasSteps ? state.steps[state.stepIndex] : null;
    final bool isTreeAlgorithm =
        widget.selectedAlgo.category == AlgorithmCategory.Trees;
    final bool isGraphAlgorithm =
        widget.selectedAlgo.category == AlgorithmCategory.Graph;

    final codeLines = pseudocodeForAlgorithm(widget.selectedAlgo);
    final highlightedLineIndices = highlightedPseudocodeLines(
      algorithm: widget.selectedAlgo,
      step: currentStep,
    );
    final highlightedLines = highlightedLineIndices.toSet();
    final int? activeLine = highlightedLines.isEmpty
        ? null
        : highlightedLineIndices.last;

    final String algorithmExplanation = switch (widget.selectedAlgo.type) {
      AlgorithmType.Bubble =>
        'Bubble Sort repeatedly compares adjacent values and swaps them when they are out of order. '
            'After each pass, the largest unsorted value moves to its final position. '
            'If a full pass makes no swaps, the array is already sorted and the algorithm stops early.',
      AlgorithmType.Insert =>
        'Insertion Sort builds a sorted section from left to right. '
            'Each new value is compared with previous values and shifted left until it reaches the correct position. '
            'It performs well on nearly sorted arrays because fewer shifts are needed.',
      AlgorithmType.Merge =>
        'Merge Sort splits the array into smaller halves, sorts each half recursively, then merges them back in order. '
            'During merge steps, values are overwritten into the main array in sorted sequence. '
            'Its time complexity stays O(n log n) even for large inputs.',
      AlgorithmType.Quick =>
        'Quick Sort picks a pivot, partitions elements into smaller and larger sides, then recursively sorts each side. '
            'Its in-place partitioning is fast on average and widely used in practice. '
            'Worst-case depth can grow, but average performance remains O(n log n).',
      AlgorithmType.Selection =>
        'Selection Sort repeatedly finds the minimum value in the unsorted suffix and swaps it into position. '
            'It performs a predictable number of comparisons regardless of input order. '
            'It is easy to visualize because each pass locks one more value in place.',
      AlgorithmType.Heap =>
        'Heap Sort builds a max-heap, then repeatedly extracts the largest element to the end of the array. '
            'After each extraction, heapify restores the heap property on the reduced range. '
            'It guarantees O(n log n) time with constant extra space.',
      AlgorithmType.LisDp =>
        'Longest Increasing Subsequence DP builds a length table where dp[i] stores the best increasing subsequence ending at i. '
            'Each state checks earlier indices and updates when a better predecessor is found. '
            'The final best length and reconstructed sequence explain the optimal answer.',
      AlgorithmType.HouseRobberDp =>
        'House Robber DP chooses between robbing the current house or skipping it to avoid adjacent selections. '
            'At each index, the state transition compares take vs skip and stores the better total. '
            'The last DP cell gives the maximum non-adjacent loot.',
      AlgorithmType.FibonacciDp =>
        'Fibonacci DP uses tabulation to build values bottom-up from base cases F(0) and F(1). '
            'Each new cell depends on the previous two cells, making transitions easy to visualize. '
            'This avoids recursive recomputation and runs in linear time.',
      AlgorithmType.CoinChangeDp =>
        'Coin Change DP computes the minimum number of coins needed for each amount from 0 to target. '
            'For every amount, each coin proposes a candidate transition from a smaller solved state. '
            'The table reveals whether the target is reachable and the optimal coin count.',
      AlgorithmType.PermutationsBacktracking =>
        'Permutation backtracking fixes one position at a time by swapping a candidate into the active index. '
            'After exploring a branch, swaps are undone so the next choice starts from a clean state. '
            'This choose-explore-unchoose cycle generates all arrangements systematically.',
      AlgorithmType.SubsetSumBacktracking =>
        'Subset Sum backtracking tries include/exclude decisions for each element to reach a target sum. '
            'Branches are pruned when the sum exceeds the target or indices are exhausted. '
            'The trace shows exactly where the search finds or rejects candidate subsets.',
      AlgorithmType.NQueensBacktracking =>
        'N-Queens backtracking places one queen per row and checks column/diagonal safety before committing. '
            'When a placement causes dead-end rows, the algorithm removes queens and explores alternatives. '
            'The process demonstrates classic recursive constraint search with backtracking.',
      AlgorithmType.BstSearch =>
        'BST Search compares the target value with the current node and moves left or right based on the comparison. '
            'The highlighted path shows exactly which nodes were traversed from root to result. '
            'If the target exists, search finishes as soon as a matching node is reached.',
      AlgorithmType.Bfs =>
        'BFS Traversal explores the tree level by level using a queue. '
            'Each visited node is processed before moving deeper into the next level. '
            'This gives a breadth-first visitation order from top to bottom.',
      AlgorithmType.Dfs =>
        'DFS Traversal explores depth-first using a stack in preorder style. '
            'It moves as deep as possible along a branch before visiting siblings. '
            'The highlighted traversal path helps track how depth exploration progresses.',
      AlgorithmType.AvlRotation =>
        'AVL Rotation keeps the tree balanced after insertions by applying LL, RR, LR, or RL rotations. '
            'Each rotation reduces height imbalance so lookup and insertion stay efficient. '
            'You can step through to see exactly when and where rebalancing occurs.',
      AlgorithmType.GraphBfs =>
        'Graph BFS visits nodes layer by layer from a starting node using a queue. '
            'It is ideal for unweighted shortest reachability and level-order exploration. '
            'Watch the frontier queue and visited nodes evolve step-by-step.',
      AlgorithmType.GraphDfs =>
        'Graph DFS explores deeply along one branch before backtracking. '
            'It is useful for traversal, connectivity checks, and topological workflows. '
            'The stack frontier shows which nodes are pending deep exploration.',
      AlgorithmType.Dijkstra =>
        'Dijkstra computes shortest paths in weighted graphs with non-negative edges. '
            'Each relaxation step attempts to improve the best-known distance to neighbors. '
            'The distance badges below nodes show the current shortest estimates.',
      AlgorithmType.AStar =>
        'A* extends shortest-path search with a heuristic to reach the goal faster. '
            'It prioritizes nodes by f = g + h and updates parents when better routes are found. '
            'You can observe the frontier and distance updates as the path converges.',
    };

    _followHighlightedLine(activeLine);

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

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0x9E2E243F),
                      borderRadius: BorderRadius.circular(60),
                    ),
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, size: 20),
                    ),
                  ),
                  const Text(
                    'Source',
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: const Color.fromARGB(30, 0, 238, 255),
                      border: Border.all(color: Colors.cyanAccent),
                    ),
                    child: Text(
                      widget.selectedAlgo.name,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.cyanAccent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isGraphAlgorithm
                            ? 'Live Graph Snapshot'
                            : isTreeAlgorithm
                            ? 'Live Tree Snapshot'
                            : 'Live Array Snapshot',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (currentStep != null)
                        isGraphAlgorithm && currentStep.treeSnapshot.isNotEmpty
                            ? GraphChart(
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
                              )
                            : isTreeAlgorithm &&
                                  currentStep.treeSnapshot.isNotEmpty
                            ? TreeChart(
                                nodes: currentStep.treeSnapshot,
                                activeNodeIndex: currentStep.activeNodeIndex,
                                targetValue: currentStep.targetValue,
                                targetNodeIndex: currentStep.targetNodeIndex,
                                traversalPathIndices:
                                    currentStep.traversalPathIndices,
                                searchHit: currentStep.searchHit,
                              )
                            : Minichart(
                                numbers: currentStep.numbersSnapshot,
                                highLightMap: highlightMap,
                                markerLabels: markerLabels,
                                defaultColor: const Color(0xFF2F2542),
                              )
                      else
                        const SizedBox(
                          height: 140,
                          child: Center(
                            child: Text(
                              'No steps available',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    hasSteps
                        ? 'Step ${state.stepIndex + 1}/${state.steps.length}'
                        : 'Step 0/0',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.cyanAccent,
                    ),
                  ),
                  Text(
                    state.isPlaying
                        ? 'Running'
                        : (isAtEnd ? 'Completed' : 'Paused'),
                    style: TextStyle(
                      fontSize: 12,
                      color: state.isPlaying
                          ? Colors.greenAccent
                          : Colors.white70,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    onPressed: isAtStart
                        ? null
                        : () {
                            if (state.isPlaying) controller.pause();
                            controller.previousStep();
                          },
                    icon: const Icon(Icons.skip_previous),
                  ),
                  IconButton(
                    onPressed: !hasSteps
                        ? null
                        : state.isPlaying
                        ? controller.pause
                        : isAtEnd
                        ? () {
                            controller.reset();
                            controller.play();
                          }
                        : controller.play,
                    icon: Icon(
                      state.isPlaying
                          ? Icons.pause_circle_outline
                          : isAtEnd
                          ? Icons.replay_circle_filled_outlined
                          : Icons.play_circle_outline,
                      size: 30,
                    ),
                  ),
                  IconButton(
                    onPressed: isAtEnd
                        ? null
                        : () {
                            if (state.isPlaying) controller.pause();
                            controller.nextStep();
                          },
                    icon: const Icon(Icons.skip_next),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Live Code Visualization',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                currentStep?.opertation ??
                                    'Press play or step through to see highlighted logic.',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white70,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                height: 250,
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: const Color(0xFF11151E),
                                    border: Border.all(color: Colors.white24),
                                  ),
                                  child: Scrollbar(
                                    controller: _codeScrollController,
                                    thumbVisibility: true,
                                    child: ListView.builder(
                                      controller: _codeScrollController,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 10,
                                      ),
                                      itemCount: codeLines.length,
                                      itemBuilder: (context, index) {
                                        return _LiveCodeLine(
                                          lineNumber: index + 1,
                                          code: codeLines[index],
                                          isActive: highlightedLines.contains(
                                            index,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'How This Algorithm Works',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                algorithmExplanation,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white70,
                                  height: 1.45,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/home-screen',
              (r) => false,
            );
          } else if (index == 1) {
            Navigator.pop(context);
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.stacked_bar_chart),
            label: 'Visualize',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.code), label: 'Source'),
        ],
      ),
    );
  }
}

class _LiveCodeLine extends StatelessWidget {
  final int lineNumber;
  final String code;
  final bool isActive;

  const _LiveCodeLine({
    required this.lineNumber,
    required this.code,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: isActive
            ? const Color.fromARGB(40, 0, 238, 255)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isActive ? Colors.cyanAccent : Colors.transparent,
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 30,
            child: Text(
              '$lineNumber',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: isActive ? Colors.cyanAccent : Colors.white38,
                fontSize: 11,
                fontFamily: 'Courier',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              code,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.white70,
                fontSize: 12,
                height: 1.45,
                fontFamily: 'Courier',
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
