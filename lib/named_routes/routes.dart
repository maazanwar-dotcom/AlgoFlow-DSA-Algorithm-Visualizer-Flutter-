import 'package:algo_visualizer/models/algorithms.dart';
import 'package:algo_visualizer/screens/algorithm_detail_screen.dart';
import 'package:algo_visualizer/screens/continue_learning_screen.dart';
import 'package:algo_visualizer/screens/home_screen.dart';
import 'package:algo_visualizer/screens/saved_screen.dart';
import 'package:algo_visualizer/screens/settings_screen.dart';
import 'package:algo_visualizer/screens/sorting_list_data.dart';
import 'package:algo_visualizer/screens/splash_screen.dart';
import 'package:flutter/material.dart';

class AlgorithmDetailArgs {
  final Algorithm selectedAlgo;
  final List<int>? numbersList;
  final bool forceFresh;
  final bool fromDailyAlgorithm;

  const AlgorithmDetailArgs({
    required this.selectedAlgo,
    this.numbersList,
    this.forceFresh = false,
    this.fromDailyAlgorithm = false,
  });
}

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/splash-screen':
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case '/home-screen':
        return MaterialPageRoute(builder: (_) => HomeScreen());

      case '/sorting-list-screen':
        return MaterialPageRoute(builder: (_) => Sortinglistscreen());

      case '/saved-screen':
        return MaterialPageRoute(builder: (_) => const SavedScreen());

      case '/continue-learning-screen':
        return MaterialPageRoute(
          builder: (_) => const ContinueLearningScreen(),
        );

      case '/settings-screen':
        return MaterialPageRoute(builder: (_) => const SettingsScreen());

      case '/algorithm-detail-screen':
        final args = settings.arguments;
        if (args is AlgorithmDetailArgs) {
          return MaterialPageRoute(
            builder: (_) => AlgorithmDetailsScreen(
              selectedAlgo: args.selectedAlgo,
              numbersList: args.numbersList,
              forceFresh: args.forceFresh,
              fromDailyAlgorithm: args.fromDailyAlgorithm,
            ),
          );
        }
        return _errorRoute('Invalid arguments for algorithm detail screen.');

      default:
        return _errorRoute('No such route exists.');
    }
  }

  static Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text(message)),
      ),
    );
  }
}

Map<String, WidgetBuilder> getAllRoutes() {
  return {
    "splash-screen-route": (context) => const SplashScreen(),
    "home-screen-route": (context) => HomeScreen(),
    "sorting-list-route": (context) => Sortinglistscreen(),
    "saved-screen-route": (context) => const SavedScreen(),
    "continue-learning-route": (context) => const ContinueLearningScreen(),
  };
}
