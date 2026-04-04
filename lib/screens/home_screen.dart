import 'dart:convert';
import 'dart:math';

import 'package:algo_visualizer/data/algorithms_data.dart';
import 'package:algo_visualizer/controllers/continue_learning_controller.dart';
import 'package:algo_visualizer/models/algorithms.dart';
import 'package:algo_visualizer/named_routes/routes.dart';
import 'package:algo_visualizer/screens/sorting_list_data.dart';
import 'package:algo_visualizer/widgets/bottom_nav_bar.dart';
import 'package:algo_visualizer/widgets/conitnue_learning_card.dart';
import 'package:algo_visualizer/widgets/data_structures_card.dart';
import 'package:algo_visualizer/widgets/header.dart';
import 'package:algo_visualizer/widgets/miniChart.dart';
import 'package:algo_visualizer/widgets/search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  static const _dailyDateKey = 'home.daily.date';
  static const _dailyAlgoIndexKey = 'home.daily.algo.index';
  static const _dailyNumbersKey = 'home.daily.chart.numbers';

  int bottomNavIndex = 0;
  final TextEditingController searchController = TextEditingController();
  String searchText = "";
  final Random rnd = Random();
  final List<Algorithm> _allAlgorithms = getAlgorithms();
  Algorithm? _dailyAlgorithm;
  List<int> _dailyNumbers = const [];
  bool _isDailyReady = false;

  @override
  void initState() {
    super.initState();
    _loadDailyAlgorithm();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(continueLearningControllerProvider.notifier).ensureLoaded();
    });
  }

  String _toDayKey(DateTime date) {
    final String month = date.month.toString().padLeft(2, '0');
    final String day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  List<int> _generateDailyNumbers() {
    const int min = 20;
    const int max = 100;
    return List<int>.generate(10, (_) => min + rnd.nextInt(max - min + 1));
  }

  List<int>? _decodeNumbers(String? encoded) {
    if (encoded == null || encoded.isEmpty) return null;
    try {
      final decoded = jsonDecode(encoded);
      if (decoded is! List) return null;

      final parsed = <int>[];
      for (final value in decoded) {
        if (value is num) {
          parsed.add(value.toInt());
        } else {
          return null;
        }
      }

      return parsed.isEmpty ? null : parsed;
    } catch (_) {
      return null;
    }
  }

  Future<void> _loadDailyAlgorithm() async {
    if (_allAlgorithms.isEmpty) {
      if (!mounted) return;
      setState(() {
        _isDailyReady = true;
      });
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final String todayKey = _toDayKey(DateTime.now());
    final String? savedDayKey = prefs.getString(_dailyDateKey);

    int algoIndex;
    List<int> chartNumbers;

    if (savedDayKey == todayKey) {
      final savedIndex = prefs.getInt(_dailyAlgoIndexKey);
      algoIndex = (savedIndex ?? rnd.nextInt(_allAlgorithms.length)).clamp(
        0,
        _allAlgorithms.length - 1,
      );
      if (savedIndex == null) {
        await prefs.setInt(_dailyAlgoIndexKey, algoIndex);
      }

      final parsedNumbers = _decodeNumbers(prefs.getString(_dailyNumbersKey));
      if (parsedNumbers == null) {
        chartNumbers = _generateDailyNumbers();
        await prefs.setString(_dailyNumbersKey, jsonEncode(chartNumbers));
      } else {
        chartNumbers = parsedNumbers;
      }
    } else {
      algoIndex = rnd.nextInt(_allAlgorithms.length);
      chartNumbers = _generateDailyNumbers();
      await prefs.setString(_dailyDateKey, todayKey);
      await prefs.setInt(_dailyAlgoIndexKey, algoIndex);
      await prefs.setString(_dailyNumbersKey, jsonEncode(chartNumbers));
    }

    if (!mounted) return;
    setState(() {
      _dailyAlgorithm = _allAlgorithms[algoIndex];
      _dailyNumbers = chartNumbers;
      _isDailyReady = true;
    });
  }

  String _difficultyLabel(Difficulty difficulty) {
    return difficulty.toString().split('.').last.toUpperCase();
  }

  void _openLibraryWithCategory(AlgorithmCategory category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Sortinglistscreen(initialCategory: category),
      ),
    );
  }

  String routeForIndex(int index) {
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

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progressMap = ref.watch(continueLearningControllerProvider);
    final inProgress = progressMap.values.where((p) => !p.isCompleted).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    final Map<AlgorithmCategory, int> categoryCounts = {
      for (final category in AlgorithmCategory.values)
        category: _allAlgorithms.where((a) => a.category == category).length,
    };

    final dailyAlgorithm = _dailyAlgorithm;
    final String difficultyText = dailyAlgorithm == null
        ? '...'
        : _difficultyLabel(dailyAlgorithm.difficulty);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //Header
                getHeader(
                  _getTimeBasedGreeting(),
                  onSettingsTap: () {
                    Navigator.pushNamed(context, '/settings-screen');
                  },
                ),
                SizedBox(height: 20),
                //Search Bar
                getSearchBar("> Search Algorithms..", searchController, (
                  value,
                ) {
                  setState(() {
                    searchText = value;
                  });
                }),
                SizedBox(height: 30),
                //Daily Algorithm
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Daily Algorithm",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      width: 170,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Color(0xFF0D2130),
                        border: Border.all(width: 2, color: Color(0x6D00EEFF)),
                      ),
                      child: Center(
                        child: Text(
                          "DIFFICULTY: $difficultyText",
                          style: TextStyle(color: Color(0xFF00EEFF)),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: !_isDailyReady
                        ? const SizedBox(
                            height: 180,
                            child: Center(child: CircularProgressIndicator()),
                          )
                        : (dailyAlgorithm == null
                              ? const SizedBox(
                                  height: 120,
                                  child: Center(
                                    child: Text('No algorithms available'),
                                  ),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          dailyAlgorithm.name,
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        Icon(Icons.sort),
                                      ],
                                    ),
                                    SizedBox(height: 3),
                                    Text(
                                      dailyAlgorithm.tagline,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                    Minichart(
                                      numbers: _dailyNumbers,
                                      highLightMap: {
                                        if (_dailyNumbers.length > 1)
                                          0: Colors.purple,
                                        if (_dailyNumbers.length > 2)
                                          1: Colors.cyan,
                                      },
                                    ),
                                    SizedBox(height: 15),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pushNamed(
                                          context,
                                          '/algorithm-detail-screen',
                                          arguments: AlgorithmDetailArgs(
                                            selectedAlgo: dailyAlgorithm,
                                            numbersList: _dailyNumbers,
                                            fromDailyAlgorithm: true,
                                          ),
                                        );
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.play_arrow_outlined,
                                            size: 20,
                                          ),
                                          Text(
                                            "Visualize Execution",
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )),
                  ),
                ),
                SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Algorithm Categories",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/sorting-list-screen'),
                      child: Text(
                        "View All",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.purpleAccent,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final double availableWidth = constraints.maxWidth;
                    final double cardWidth = ((availableWidth - 10) / 2).clamp(
                      0.0,
                      double.infinity,
                    );

                    return Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        SizedBox(
                          width: cardWidth,
                          child: DataStructuresCard(
                            title: "Sorting",
                            subTitle:
                                "${categoryCounts[AlgorithmCategory.Sorting] ?? 0} Algorithms",
                            icon: Icon(Icons.sort),
                            color: Colors.cyan,
                            onTap: () => _openLibraryWithCategory(
                              AlgorithmCategory.Sorting,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: DataStructuresCard(
                            title: "Trees",
                            subTitle:
                                "${categoryCounts[AlgorithmCategory.Trees] ?? 0} Algorithms",
                            icon: Icon(Icons.terminal_rounded),
                            color: Colors.deepPurple,
                            onTap: () => _openLibraryWithCategory(
                              AlgorithmCategory.Trees,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: DataStructuresCard(
                            title: "Graphs",
                            subTitle:
                                "${categoryCounts[AlgorithmCategory.Graph] ?? 0} Algorithms",
                            icon: Icon(Icons.graphic_eq),
                            color: const Color.fromARGB(255, 139, 95, 29),
                            onTap: () => _openLibraryWithCategory(
                              AlgorithmCategory.Graph,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: DataStructuresCard(
                            title: "Backtracking",
                            subTitle:
                                "${categoryCounts[AlgorithmCategory.Backtracking] ?? 0} Algorithms",
                            icon: Icon(Icons.route_rounded),
                            color: const Color.fromARGB(255, 184, 105, 64),
                            onTap: () => _openLibraryWithCategory(
                              AlgorithmCategory.Backtracking,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Continue Learning",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(
                        context,
                        '/continue-learning-screen',
                      ),
                      child: Text(
                        "View All",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.purpleAccent,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                if (inProgress.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Text(
                        "No active algorithm session yet. Start one from the library.",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white70,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  )
                else
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (final progress in inProgress) ...[
                          ConitnueLearningCard(
                            icon: Icon(Icons.sort),
                            complexity: progress.algorithm.timeComplexity,
                            algorithm: progress.algorithm.name,
                            completionValue: progress.completion,
                            completionText:
                                "Step ${progress.stepIndex + 1}/${progress.steps.length}",
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/algorithm-detail-screen',
                                arguments: AlgorithmDetailArgs(
                                  selectedAlgo: progress.algorithm,
                                ),
                              );
                            },
                          ),
                          SizedBox(width: 12),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),

      bottomNavigationBar: getBottomNavBar(bottomNavIndex, (int newIndex) {
        setState(() {
          bottomNavIndex = newIndex;
        });
        final route = routeForIndex(newIndex);
        if (route.isNotEmpty) Navigator.pushNamed(context, route);
      }),
    );
  }

  /// Returns a time-based greeting
  String _getTimeBasedGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 18) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }
}
