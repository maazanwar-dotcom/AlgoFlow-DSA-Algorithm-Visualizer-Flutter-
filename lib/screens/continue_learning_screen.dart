import 'package:algo_visualizer/controllers/continue_learning_controller.dart';
import 'package:algo_visualizer/models/algorithms.dart';
import 'package:algo_visualizer/models/learning_progress.dart';
import 'package:algo_visualizer/named_routes/routes.dart';
import 'package:algo_visualizer/widgets/category_pill.dart';
import 'package:algo_visualizer/widgets/difficulty_container.dart';
import 'package:algo_visualizer/widgets/search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ContinueLearningScreen extends ConsumerStatefulWidget {
  const ContinueLearningScreen({super.key});

  @override
  ConsumerState<ContinueLearningScreen> createState() =>
      _ContinueLearningScreenState();
}

class _ContinueLearningScreenState
    extends ConsumerState<ContinueLearningScreen> {
  final List<String> categories = const [
    'All Nodes',
    'Sorting',
    'Graphs',
    'Trees',
    'Dynamic Programming',
    'Backtracking',
  ];
  int selectedIndex = 0;
  String searchText = '';
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(continueLearningControllerProvider.notifier).ensureLoaded();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  AlgorithmCategory? _selectedAlgorithmCategory(int index) {
    switch (index) {
      case 1:
        return AlgorithmCategory.Sorting;
      case 2:
        return AlgorithmCategory.Graph;
      case 3:
        return AlgorithmCategory.Trees;
      case 4:
        return AlgorithmCategory.DynamicProgramming;
      case 5:
        return AlgorithmCategory.Backtracking;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final progressMap = ref.watch(continueLearningControllerProvider);
    final inProgress = progressMap.values.where((p) => !p.isCompleted).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    final selectedCategory = _selectedAlgorithmCategory(selectedIndex);
    final filteredByCategory = selectedCategory == null
        ? inProgress
        : inProgress
              .where((p) => p.algorithm.category == selectedCategory)
              .toList();

    final q = searchText.trim().toLowerCase();
    final List<LearningProgress> finalList = q.isEmpty
        ? filteredByCategory
        : filteredByCategory.where((p) {
            final algo = p.algorithm;
            return algo.name.toLowerCase().contains(q) ||
                algo.tagline.toLowerCase().contains(q) ||
                algo.timeComplexity.toLowerCase().contains(q) ||
                algo.spaceComplexity.toLowerCase().contains(q);
          }).toList();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0x9E2E243F),
                      borderRadius: BorderRadius.circular(60),
                    ),
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, size: 22),
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Continue Learning',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0x9E2E243F),
                      borderRadius: BorderRadius.circular(60),
                    ),
                    child: IconButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/settings-screen');
                      },
                      icon: const Icon(Icons.settings, size: 22),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              getSearchBar('> Search continue learning..', searchController, (
                value,
              ) {
                setState(() {
                  searchText = value;
                });
              }),
              const SizedBox(height: 20),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (int i = 0; i < categories.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: categoryPill(
                          categories[i],
                          i == selectedIndex,
                          () {
                            setState(() {
                              selectedIndex = i;
                            });
                          },
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (finalList.isEmpty)
                const Expanded(
                  child: Center(
                    child: Text(
                      'No matching continue learning sessions.',
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: finalList.length,
                    itemBuilder: (context, index) {
                      final progress = finalList[index];
                      final algo = progress.algorithm;
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      algo.name,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  getDifficulty(algo.difficulty),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Text(algo.tagline),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 30,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF0D2130),
                                        border: Border.all(
                                          width: 2,
                                          color: const Color(0x6D00EEFF),
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          algo.category
                                              .toString()
                                              .split('.')
                                              .last,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Color(0xFF00EEFF),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: const Color.fromARGB(
                                          87,
                                          104,
                                          58,
                                          183,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(3.0),
                                        child: Text(
                                          algo.timeComplexity,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    tooltip: 'Resume',
                                    onPressed: () {
                                      Navigator.pushNamed(
                                        context,
                                        '/algorithm-detail-screen',
                                        arguments: AlgorithmDetailArgs(
                                          selectedAlgo: algo,
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.play_circle_outline),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              LinearProgressIndicator(
                                value: progress.completion,
                                color: Colors.purpleAccent,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Step ${progress.stepIndex + 1}/${progress.steps.length}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white70,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
