import 'package:algo_visualizer/models/algo_step.dart';

class NQueensBacktracking {
  final List<AlgoStep> steps = [];

  List<AlgoStep> performNQueensBacktracking(List<int> numbers) {
    steps.clear();

    final int n = 4;
    final cols = List<int>.filled(n, -1);

    steps.add(
      AlgoStep(
        numbersSnapshot: _boardSnapshot(cols),
        opertation: 'Start N-Queens search on a $n x $n board',
        i: -1,
        j: -1,
        stepType: AlgoStepType.overwrite,
      ),
    );

    final solved = _placeQueen(row: 0, cols: cols, n: n);

    steps.add(
      AlgoStep(
        numbersSnapshot: _boardSnapshot(cols),
        opertation: solved
            ? 'N-Queens solved: one valid arrangement found'
            : 'No valid arrangement found for N=$n',
        i: -1,
        j: -1,
        stepType: AlgoStepType.done,
        searchHit: solved,
      ),
    );

    return steps;
  }

  bool _placeQueen({
    required int row,
    required List<int> cols,
    required int n,
  }) {
    if (row == n) {
      steps.add(
        AlgoStep(
          numbersSnapshot: _boardSnapshot(cols),
          opertation: 'Placed all queens successfully',
          i: row - 1,
          j: -1,
          stepType: AlgoStepType.overwrite,
        ),
      );
      return true;
    }

    for (int col = 0; col < n; col++) {
      steps.add(
        AlgoStep(
          numbersSnapshot: _boardSnapshot(cols),
          opertation: 'Try queen at row $row, col $col',
          i: row,
          j: col,
          stepType: AlgoStepType.compare,
        ),
      );

      if (_isSafe(row, col, cols)) {
        cols[row] = col;
        steps.add(
          AlgoStep(
            numbersSnapshot: _boardSnapshot(cols),
            opertation: 'Place queen at row $row, col $col',
            i: row,
            j: col,
            stepType: AlgoStepType.overwrite,
          ),
        );

        if (_placeQueen(row: row + 1, cols: cols, n: n)) {
          return true;
        }

        cols[row] = -1;
        steps.add(
          AlgoStep(
            numbersSnapshot: _boardSnapshot(cols),
            opertation: 'Backtrack from row $row, col $col',
            i: row,
            j: col,
            stepType: AlgoStepType.noSwap,
          ),
        );
      } else {
        steps.add(
          AlgoStep(
            numbersSnapshot: _boardSnapshot(cols),
            opertation: 'Conflict at row $row, col $col',
            i: row,
            j: col,
            stepType: AlgoStepType.noSwap,
          ),
        );
      }
    }

    return false;
  }

  bool _isSafe(int row, int col, List<int> cols) {
    for (int prevRow = 0; prevRow < row; prevRow++) {
      final prevCol = cols[prevRow];
      if (prevCol == col) return false;
      if ((prevRow - row).abs() == (prevCol - col).abs()) return false;
    }
    return true;
  }

  List<int> _boardSnapshot(List<int> cols) {
    return cols.map((col) => col < 0 ? 0 : col + 1).toList();
  }
}
