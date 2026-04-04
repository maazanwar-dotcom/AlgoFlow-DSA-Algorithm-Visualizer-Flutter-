enum Difficulty { easy, medium, hard }

enum AlgorithmCategory {
  Sorting,
  Graph,
  Trees,
  DynamicProgramming,
  Backtracking,
}

enum AlgorithmType {
  Quick,
  Merge,
  Bfs,
  Dfs,
  GraphBfs,
  GraphDfs,
  Dijkstra,
  AStar,
  Insert,
  Bubble,
  BstSearch,
  AvlRotation,
  Selection,
  Heap,
  LisDp,
  HouseRobberDp,
  FibonacciDp,
  CoinChangeDp,
  PermutationsBacktracking,
  SubsetSumBacktracking,
  NQueensBacktracking,
}

class Algorithm {
  final String name;
  final String tagline;
  final Difficulty difficulty;
  final String timeComplexity;
  final String spaceComplexity;
  final AlgorithmType type;
  final AlgorithmCategory category;

  const Algorithm({
    required this.name,
    required this.tagline,
    required this.difficulty,
    required this.timeComplexity,
    required this.spaceComplexity,
    required this.type,
    required this.category,
  });
}
