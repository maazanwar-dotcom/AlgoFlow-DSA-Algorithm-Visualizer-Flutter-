import 'package:algo_visualizer/data/algorithms_data.dart';
import 'package:algo_visualizer/controllers/saved_algorithms_controller.dart';
import 'package:algo_visualizer/models/algorithms.dart';
import 'package:algo_visualizer/named_routes/routes.dart';
import 'package:algo_visualizer/widgets/bottom_nav_bar.dart';
import 'package:algo_visualizer/widgets/category_pill.dart';
import 'package:algo_visualizer/widgets/difficulty_container.dart';
import 'package:algo_visualizer/widgets/header.dart';
import 'package:algo_visualizer/widgets/search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Sortinglistscreen extends ConsumerStatefulWidget {
  final AlgorithmCategory? initialCategory;
  final List<String> categories = [
    "All Nodes",
    "Sorting",
    "Graphs",
    "Trees",
    "Dynamic Programming",
    "Backtracking",
  ];
  final algos = getAlgorithms();

  Sortinglistscreen({super.key, this.initialCategory});

  @override
  ConsumerState<Sortinglistscreen> createState() => _SortinglistscreenState();
}

class _SortinglistscreenState extends ConsumerState<Sortinglistscreen> {
  int bottomNavIndex = 1;

  int selectedIndex = 0;
  final TextEditingController searchController = TextEditingController();
  String searchText = "";
  routeForIndex(int index) {
    switch (index) {
      case 0:
        return '/home-screen';
      case 1:
        return '/sorting-list-screen';
      case 2:
        return '/saved-screen';
      default:
        return '';
    }
  }

  int _indexForCategory(AlgorithmCategory? category) {
    switch (category) {
      case AlgorithmCategory.Sorting:
        return 1;
      case AlgorithmCategory.Graph:
        return 2;
      case AlgorithmCategory.Trees:
        return 3;
      case AlgorithmCategory.DynamicProgramming:
        return 4;
      case AlgorithmCategory.Backtracking:
        return 5;
      default:
        return 0;
    }
  }

  @override
  void initState() {
    super.initState();
    selectedIndex = _indexForCategory(widget.initialCategory);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(savedAlgorithmsControllerProvider.notifier).ensureLoaded();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final savedNames = ref.watch(savedAlgorithmsControllerProvider);

    AlgorithmCategory? selectedAlgorithmCategory(int index) {
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

    final AlgorithmCategory? selectedCategory = selectedAlgorithmCategory(
      selectedIndex,
    );

    final List<Algorithm> filteredAlgos = (selectedCategory == null)
        ? widget.algos
        : widget.algos.where((a) => a.category == selectedCategory).toList();
    final String q = searchText.trim().toLowerCase();

    final List<Algorithm> finalFilteredAlgos = (q.isEmpty)
        ? filteredAlgos
        : filteredAlgos.where((a) {
            final name = a.name.toLowerCase();
            final time = a.timeComplexity.toLowerCase();
            final space = a.spaceComplexity.toLowerCase();
            a.category.toString().split('.').last.toLowerCase();
            a.type.toString().split('.').last.toLowerCase();

            return name.contains(q) || time.contains(q) || space.contains(q);
          }).toList();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //Header
              getHeader(
                "Algorithm Library",
                onSettingsTap: () {
                  Navigator.pushNamed(context, '/settings-screen');
                },
              ),
              SizedBox(height: 20),
              //SearchBar
              getSearchBar(
                "> Filter by name or complexity..",
                searchController,
                (value) {
                  setState(() {
                    searchText = value;
                  });
                },
              ),
              //Categories
              SizedBox(height: 30),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (int i = 0; i < widget.categories.length; i++)
                      categoryPill(
                        widget.categories[i],
                        i == selectedIndex,
                        () {
                          setState(() {
                            selectedIndex = i;
                          });
                        },
                      ),
                  ],
                ),
              ),

              SizedBox(height: 20),
              if (finalFilteredAlgos.isEmpty)
                Expanded(
                  child: Center(
                    child: Text(
                      "No algorithm found!!",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: finalFilteredAlgos.length,
                    itemBuilder: (context, index) {
                      final algo = finalFilteredAlgos[index];
                      final bool isSaved = savedNames.contains(algo.name);

                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      algo.name,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  getDifficulty(algo.difficulty),
                                ],
                              ),
                              SizedBox(height: 5),
                              Text(algo.tagline),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  Container(
                                    width: 100,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: Color(0xFF0D2130),
                                      border: Border.all(
                                        width: 2,
                                        color: _getCategoryColor(
                                          algo.category,
                                        ).withAlpha(200),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        _getCategoryDisplayName(algo.category),
                                        style: TextStyle(
                                          color: _getCategoryColor(
                                            algo.category,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 5),
                                  Expanded(
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
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 40,
                                    child: IconButton(
                                      tooltip: isSaved
                                          ? 'Remove from saved'
                                          : 'Save algorithm',
                                      onPressed: () {
                                        ref
                                            .read(
                                              savedAlgorithmsControllerProvider
                                                  .notifier,
                                            )
                                            .toggleSaved(algo.name);
                                      },
                                      icon: Icon(
                                        isSaved
                                            ? Icons.bookmark
                                            : Icons.bookmark_border,
                                        color: isSaved
                                            ? Colors.cyanAccent
                                            : Colors.white70,
                                      ),
                                      padding: EdgeInsets.zero,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 40,
                                    child: IconButton(
                                      onPressed: () {
                                        Navigator.pushNamed(
                                          context,
                                          '/algorithm-detail-screen',
                                          arguments: AlgorithmDetailArgs(
                                            selectedAlgo: algo,
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.arrow_forward_ios),
                                      padding: EdgeInsets.zero,
                                    ),
                                  ),
                                ],
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
      bottomNavigationBar: getBottomNavBar(bottomNavIndex, (int newIndex) {
        setState(() {
          bottomNavIndex = newIndex;
        });
        final route = routeForIndex(newIndex);
        if (route.isNotEmpty && route != '/sorting-list-screen') {
          Navigator.pushNamed(context, route);
        }
      }),
    );
  }

  /// Returns a subtle color based on the algorithm category
  Color _getCategoryColor(AlgorithmCategory category) {
    return switch (category) {
      AlgorithmCategory.Sorting => const Color(0xFF00D9FF), // Cyan
      AlgorithmCategory.Graph => const Color(0xFFAD7C4E), // Warm brown
      AlgorithmCategory.Trees => const Color(0xFF9C7BD4), // Soft purple
      AlgorithmCategory.DynamicProgramming => const Color(
        0xFF7FB3A3,
      ), // Muted teal
      AlgorithmCategory.Backtracking => const Color(
        0xFFD4956D,
      ), // Warm orange-brown
    };
  }

  /// Returns the display name for a category, shortening long names
  String _getCategoryDisplayName(AlgorithmCategory category) {
    return switch (category) {
      AlgorithmCategory.Sorting => 'Sorting',
      AlgorithmCategory.Graph => 'Graphs',
      AlgorithmCategory.Trees => 'Trees',
      AlgorithmCategory.DynamicProgramming => 'Dynamic Prog',
      AlgorithmCategory.Backtracking => 'Backtracking',
    };
  }
}
