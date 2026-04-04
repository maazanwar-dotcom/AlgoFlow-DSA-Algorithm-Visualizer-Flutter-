import 'package:algo_visualizer/controllers/saved_algorithms_controller.dart';
import 'package:algo_visualizer/data/algorithms_data.dart';
import 'package:algo_visualizer/named_routes/routes.dart';
import 'package:algo_visualizer/widgets/bottom_nav_bar.dart';
import 'package:algo_visualizer/widgets/difficulty_container.dart';
import 'package:algo_visualizer/widgets/header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SavedScreen extends ConsumerStatefulWidget {
  const SavedScreen({super.key});

  @override
  ConsumerState<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends ConsumerState<SavedScreen> {
  int bottomNavIndex = 2;

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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(savedAlgorithmsControllerProvider.notifier).ensureLoaded();
    });
  }

  @override
  Widget build(BuildContext context) {
    final savedNames = ref.watch(savedAlgorithmsControllerProvider);
    final all = getAlgorithms();
    final savedAlgorithms = all
        .where((a) => savedNames.contains(a.name))
        .toList();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              getHeader(
                'Saved Algorithms',
                onSettingsTap: () {
                  Navigator.pushNamed(context, '/settings-screen');
                },
              ),
              const SizedBox(height: 20),
              if (savedAlgorithms.isEmpty)
                const Expanded(
                  child: Center(
                    child: Text(
                      'No saved algorithms yet. Save from the library.',
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: savedAlgorithms.length,
                    itemBuilder: (context, index) {
                      final algo = savedAlgorithms[index];
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
                                  Container(
                                    width: 100,
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
                                        style: const TextStyle(
                                          color: Color(0xFF00EEFF),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Container(
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
                                      child: Text(algo.timeComplexity),
                                    ),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    tooltip: 'Open',
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
        if (route.isNotEmpty && route != '/saved-screen') {
          Navigator.pushNamed(context, route);
        }
      }),
    );
  }
}
