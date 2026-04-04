import 'package:algo_visualizer/models/algorithms.dart';
import 'package:algo_visualizer/models/algo_step.dart';

List<String> pseudocodeForAlgorithm(Algorithm algorithm) {
  switch (algorithm.type) {
    case AlgorithmType.Bubble:
      return const [
        'for i from 0 to n - 2:',
        '  swapped = false',
        '  for j from 0 to n - i - 2:',
        '    if arr[j] > arr[j + 1]:',
        '      swap arr[j], arr[j + 1]',
        '      swapped = true',
        '    else:',
        '      no swap',
        '  if not swapped:',
        '    break',
      ];
    case AlgorithmType.Insert:
      return const [
        'for i from 1 to n - 1:',
        '  key = arr[i]',
        '  j = i - 1',
        '  while j >= 0 and arr[j] > key:',
        '    arr[j + 1] = arr[j]',
        '    j = j - 1',
        '  // no shift needed, exit while',
        '  arr[j + 1] = key',
      ];
    case AlgorithmType.Merge:
      return const [
        'function mergeSort(left, right):',
        '  if left >= right: return',
        '  mid = (left + right) / 2',
        '  mergeSort(left, mid)',
        '  mergeSort(mid + 1, right)',
        '  merge(left, mid, right)',
        '',
        'function merge(left, mid, right):',
        '  copy left and right halves',
        '  merge back to arr in sorted order',
      ];
    case AlgorithmType.Quick:
      return const [
        'function quickSort(left, right):',
        '  if left < right:',
        '    pi = partition(left, right)',
        '    quickSort(left, pi - 1)',
        '    quickSort(pi + 1, right)',
        '',
        'function partition(left, right):',
        '  pivot = arr[right]',
        '  i = left - 1',
        '  for j from left to right - 1:',
        '    if arr[j] < pivot: swap and increment i',
        '  swap pivot to position i + 1',
      ];
    case AlgorithmType.Selection:
      return const [
        'for i from 0 to n - 2:',
        '  minIdx = i',
        '  for j from i + 1 to n - 1:',
        '    if arr[j] < arr[minIdx]:',
        '      minIdx = j',
        '  if minIdx != i:',
        '    swap arr[i] with arr[minIdx]',
        '  else:',
        '    no swap needed',
      ];
    case AlgorithmType.Heap:
      return const [
        'function heapSort(arr):',
        '  build max-heap from arr',
        '  for i from n - 1 down to 1:',
        '    swap arr[0] with arr[i]',
        '    heapify down from root with heap size i',
        '',
        'function heapify(i, heapSize):',
        '  largest = i',
        '  if left child > largest: largest = left',
        '  if right child > largest: largest = right',
        '  if largest != i: swap and recurse',
      ];
    case AlgorithmType.LisDp:
      return const [
        'dp[i] = 1 for all i',
        'for i from 1 to n - 1:',
        '  for j from 0 to i - 1:',
        '    if arr[j] < arr[i] and dp[j] + 1 > dp[i]:',
        '      dp[i] = dp[j] + 1',
        '      parent[i] = j',
        'bestIndex = index with largest dp value',
        'reconstruct LIS using parent links',
      ];
    case AlgorithmType.HouseRobberDp:
      return const [
        'dp[0] = houses[0]',
        'dp[1] = max(houses[0], houses[1])',
        'for i from 2 to n - 1:',
        '  take = dp[i - 2] + houses[i]',
        '  skip = dp[i - 1]',
        '  dp[i] = max(take, skip)',
        'answer = dp[n - 1]',
      ];
    case AlgorithmType.FibonacciDp:
      return const [
        'dp[0] = 0, dp[1] = 1',
        'for i from 2 to n:',
        '  dp[i] = dp[i - 1] + dp[i - 2]',
        'return dp[n]',
      ];
    case AlgorithmType.CoinChangeDp:
      return const [
        'dp[0] = 0, dp[others] = INF',
        'for value from 1 to amount:',
        '  for each coin in coins:',
        '    if coin <= value:',
        '      dp[value] = min(dp[value], dp[value - coin] + 1)',
        'return dp[amount] or not reachable',
      ];
    case AlgorithmType.PermutationsBacktracking:
      return const [
        'function backtrack(start):',
        '  if start == n: record permutation and return',
        '  for i from start to n - 1:',
        '    choose index i for current position',
        '    swap arr[start], arr[i]',
        '    backtrack(start + 1)',
        '    swap arr[start], arr[i]  // undo choice',
      ];
    case AlgorithmType.SubsetSumBacktracking:
      return const [
        'target = sum(arr) / 2 (or chosen target)',
        'function search(index, currentSum):',
        '  if currentSum == target: return found',
        '  if index == n or currentSum > target: return false',
        '  include arr[index] and recurse',
        '  exclude arr[index] and recurse',
        'return found/not found',
      ];
    case AlgorithmType.NQueensBacktracking:
      return const [
        'placeQueen(row):',
        '  if row == n: solution found',
        '  for col in 0..n-1:',
        '    if safe(row, col):',
        '      place queen at (row, col)',
        '      if placeQueen(row + 1): return true',
        '      remove queen (backtrack)',
        'return false',
      ];
    case AlgorithmType.BstSearch:
      return const [
        'build BST from input values',
        'target = value to search',
        'current = root',
        'while current is not null:',
        '  if target == current.value: return found',
        '  if target < current.value: current = current.left',
        '  else: current = current.right',
        'return not found',
      ];
    case AlgorithmType.Bfs:
      return const [
        'build BST from input values',
        'queue = [root]',
        'while queue is not empty:',
        '  current = queue.popFront()',
        '  visit current',
        '  if current.left exists: queue.push(current.left)',
        '  if current.right exists: queue.push(current.right)',
        'return traversal complete',
      ];
    case AlgorithmType.Dfs:
      return const [
        'build BST from input values',
        'stack = [root]',
        'while stack is not empty:',
        '  current = stack.pop()',
        '  visit current',
        '  if current.right exists: stack.push(current.right)',
        '  if current.left exists: stack.push(current.left)',
        'return traversal complete',
      ];
    case AlgorithmType.AvlRotation:
      return const [
        'for each value in insertion order:',
        '  insert as BST node',
        '  update node heights bottom-up',
        '  compute balance factor',
        '  if LL case: rightRotate(node)',
        '  if RR case: leftRotate(node)',
        '  if LR case: leftRotate(node.left), rightRotate(node)',
        '  if RL case: rightRotate(node.right), leftRotate(node)',
        'continue to next value',
        'return AVL tree complete',
      ];
    case AlgorithmType.GraphBfs:
      return const [
        'queue = [start]',
        'visited = {start}',
        'while queue is not empty:',
        '  current = queue.popFront()',
        '  visit current',
        '  for neighbor in adjacency[current]:',
        '    if neighbor not visited: mark visited and enqueue',
        'return traversal order',
      ];
    case AlgorithmType.GraphDfs:
      return const [
        'stack = [start]',
        'visited = {start}',
        'while stack is not empty:',
        '  current = stack.pop()',
        '  visit current',
        '  for neighbor in reverse(adjacency[current]):',
        '    if neighbor not visited: mark visited and push',
        'return traversal order',
      ];
    case AlgorithmType.Dijkstra:
      return const [
        'dist[start] = 0, dist[others] = inf',
        'unvisited = all nodes',
        'while unvisited is not empty:',
        '  current = node with smallest tentative distance',
        '  remove current from unvisited',
        '  for each neighbor of current in unvisited:',
        '    candidate = dist[current] + weight(current, neighbor)',
        '    if candidate < dist[neighbor]: update dist and parent',
        'reconstruct shortest path to goal',
      ];
    case AlgorithmType.AStar:
      return const [
        'openSet = {start}',
        'g[start] = 0, f[start] = h(start)',
        'while openSet is not empty:',
        '  current = node in openSet with lowest f-score',
        '  if current == goal: reconstruct path',
        '  move current from openSet to closedSet',
        '  for each neighbor of current:',
        '    tentative = g[current] + weight(current, neighbor)',
        '    if tentative < g[neighbor]: update parent, g, f and add to openSet',
        'if loop ends: path not found',
      ];
  }
}

List<int> highlightedPseudocodeLines({
  required Algorithm algorithm,
  required AlgoStep? step,
}) {
  if (step == null) return const [];

  switch (algorithm.type) {
    case AlgorithmType.Bubble:
      switch (step.stepType) {
        case AlgoStepType.compare:
          return const [3];
        case AlgoStepType.swap:
          return const [4, 5];
        case AlgoStepType.noSwap:
          return const [6, 7];
        case AlgoStepType.done:
          return const [8, 9];
        default:
          return const [0];
      }

    case AlgorithmType.Insert:
      switch (step.stepType) {
        case AlgoStepType.compare:
          return const [3];
        case AlgoStepType.swap:
          if (step.opertation.startsWith('Shift')) {
            return const [4, 5];
          }
          return const [7];
        case AlgoStepType.noSwap:
          return const [6];
        case AlgoStepType.done:
          return const [7];
        default:
          return const [0];
      }

    case AlgorithmType.Merge:
      switch (step.stepType) {
        case AlgoStepType.compare:
          return const [9];
        case AlgoStepType.overwrite:
          return const [9];
        case AlgoStepType.done:
          return const [9];
        default:
          return const [5, 7];
      }

    case AlgorithmType.Quick:
      switch (step.stepType) {
        case AlgoStepType.compare:
          return const [9, 10];
        case AlgoStepType.swap:
          return const [10, 11];
        case AlgoStepType.overwrite:
          return const [11];
        case AlgoStepType.done:
          return const [0, 1];
        default:
          return const [6, 7];
      }

    case AlgorithmType.Selection:
      switch (step.stepType) {
        case AlgoStepType.compare:
          return const [3, 4];
        case AlgoStepType.swap:
          return const [6];
        case AlgoStepType.noSwap:
          return const [8];
        case AlgoStepType.done:
          return const [0];
        default:
          return const [1, 2];
      }

    case AlgorithmType.Heap:
      switch (step.stepType) {
        case AlgoStepType.compare:
          return const [7, 8, 9];
        case AlgoStepType.swap:
          return const [4, 10];
        case AlgoStepType.overwrite:
          return const [3, 4];
        case AlgoStepType.done:
          return const [0, 1];
        default:
          return const [2, 3];
      }

    case AlgorithmType.LisDp:
      switch (step.stepType) {
        case AlgoStepType.compare:
          return const [2, 3];
        case AlgoStepType.overwrite:
          return const [4, 5];
        case AlgoStepType.noSwap:
          return const [3];
        case AlgoStepType.done:
          return const [6, 7];
        default:
          return const [0, 1];
      }

    case AlgorithmType.HouseRobberDp:
      switch (step.stepType) {
        case AlgoStepType.compare:
          return const [3, 4];
        case AlgoStepType.overwrite:
          return const [5];
        case AlgoStepType.noSwap:
          return const [5];
        case AlgoStepType.done:
          return const [6];
        default:
          return const [0, 1, 2];
      }

    case AlgorithmType.FibonacciDp:
      switch (step.stepType) {
        case AlgoStepType.compare:
          return const [1, 2];
        case AlgoStepType.overwrite:
          return const [0, 2];
        case AlgoStepType.done:
          return const [3];
        default:
          return const [0, 1];
      }

    case AlgorithmType.CoinChangeDp:
      switch (step.stepType) {
        case AlgoStepType.compare:
          return const [2, 3, 4];
        case AlgoStepType.overwrite:
          return const [4];
        case AlgoStepType.noSwap:
          return const [3, 4];
        case AlgoStepType.done:
          return const [5];
        default:
          return const [0, 1];
      }

    case AlgorithmType.PermutationsBacktracking:
      switch (step.stepType) {
        case AlgoStepType.compare:
          return const [2, 3];
        case AlgoStepType.swap:
          return const [4, 6];
        case AlgoStepType.noSwap:
          return const [6];
        case AlgoStepType.overwrite:
          return const [1];
        case AlgoStepType.done:
          return const [0, 1];
        default:
          return const [0];
      }

    case AlgorithmType.SubsetSumBacktracking:
      switch (step.stepType) {
        case AlgoStepType.compare:
          return const [4];
        case AlgoStepType.overwrite:
          return const [2];
        case AlgoStepType.noSwap:
          return const [3, 5];
        case AlgoStepType.done:
          return const [6];
        default:
          return const [0, 1];
      }

    case AlgorithmType.NQueensBacktracking:
      switch (step.stepType) {
        case AlgoStepType.compare:
          return const [2, 3];
        case AlgoStepType.overwrite:
          return const [4, 5];
        case AlgoStepType.noSwap:
          return const [6, 7];
        case AlgoStepType.done:
          return const [1];
        default:
          return const [0];
      }

    case AlgorithmType.BstSearch:
      switch (step.stepType) {
        case AlgoStepType.compare:
          return const [3, 4];
        case AlgoStepType.noSwap:
          if (step.opertation.toLowerCase().contains('left')) {
            return const [5];
          }
          return const [6];
        case AlgoStepType.done:
          if (step.searchHit) {
            return const [4];
          }
          return const [7];
        default:
          return const [2];
      }

    case AlgorithmType.Bfs:
      switch (step.stepType) {
        case AlgoStepType.compare:
          return const [3, 4];
        case AlgoStepType.noSwap:
          if (step.opertation.toLowerCase().contains('left')) {
            return const [5];
          }
          if (step.opertation.toLowerCase().contains('right')) {
            return const [6];
          }
          return const [2];
        case AlgoStepType.done:
          return const [7];
        default:
          return const [1];
      }

    case AlgorithmType.Dfs:
      switch (step.stepType) {
        case AlgoStepType.compare:
          return const [3, 4];
        case AlgoStepType.noSwap:
          if (step.opertation.toLowerCase().contains('right')) {
            return const [5];
          }
          if (step.opertation.toLowerCase().contains('left')) {
            return const [6];
          }
          return const [2];
        case AlgoStepType.done:
          return const [7];
        default:
          return const [1];
      }

    case AlgorithmType.AvlRotation:
      switch (step.stepType) {
        case AlgoStepType.compare:
          return const [1];
        case AlgoStepType.overwrite:
          return const [1, 2, 3];
        case AlgoStepType.swap:
          if (step.opertation.contains('LL')) return const [4];
          if (step.opertation.contains('RR')) return const [5];
          if (step.opertation.contains('LR')) return const [6];
          if (step.opertation.contains('RL')) return const [7];
          return const [3];
        case AlgoStepType.done:
          return const [9];
        default:
          return const [0];
      }

    case AlgorithmType.GraphBfs:
      switch (step.stepType) {
        case AlgoStepType.overwrite:
          return const [0, 1];
        case AlgoStepType.compare:
          return const [2, 3, 4];
        case AlgoStepType.noSwap:
          return const [5, 6];
        case AlgoStepType.done:
          return const [7];
        default:
          return const [2];
      }

    case AlgorithmType.GraphDfs:
      switch (step.stepType) {
        case AlgoStepType.overwrite:
          return const [0, 1];
        case AlgoStepType.compare:
          return const [2, 3, 4];
        case AlgoStepType.noSwap:
          return const [5, 6];
        case AlgoStepType.done:
          return const [7];
        default:
          return const [2];
      }

    case AlgorithmType.Dijkstra:
      switch (step.stepType) {
        case AlgoStepType.overwrite:
          if (step.opertation.toLowerCase().contains('initialize')) {
            return const [0, 1];
          }
          return const [7];
        case AlgoStepType.compare:
          if (step.opertation.toLowerCase().contains('pick node')) {
            return const [3, 4];
          }
          return const [5, 6];
        case AlgoStepType.noSwap:
          return const [7];
        case AlgoStepType.done:
          return const [8];
        default:
          return const [2];
      }

    case AlgorithmType.AStar:
      switch (step.stepType) {
        case AlgoStepType.overwrite:
          if (step.opertation.toLowerCase().contains('initialize')) {
            return const [0, 1];
          }
          return const [8];
        case AlgoStepType.compare:
          if (step.opertation.toLowerCase().contains('choose node')) {
            return const [3];
          }
          return const [6, 7];
        case AlgoStepType.noSwap:
          return const [8];
        case AlgoStepType.done:
          if (step.searchHit) {
            return const [4];
          }
          return const [9];
        default:
          return const [2];
      }
  }
}
