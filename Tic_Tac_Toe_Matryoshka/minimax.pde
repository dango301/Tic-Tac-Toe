// decided not to limit by depth but by time, as if the bot were a real player and forced to move despite not having 'finished his thought', i.e. he is interrupted without even finishing to search at a certain broadth

//int maxDepth;
int t0; // timestamp (long isn't needed since Integer works for a few days) for when bot begins calculating each time
int timeout = 10000;

void botResponse() {
  print("\nThe Computer is calculating a response...\t");
  t0 = millis();

  int bestMoveX = -1;
  int bestMoveY = -1;
  int bestSize = -1;
  double maxScore = Double.NEGATIVE_INFINITY;

  for (int i = 0; i < gridSize; i++) {
    for (int j = 0; j < gridSize; j++) {

      for (int size = 0; size < 3; size++) {
        if (botFigures[size] > 0) { // check each field with each available figure of every size

          if (abs(grid[i][j]) < abs(size + 1)) { // check each field, which has a smaller figure (or none) on it, so new figure can be set on top

            int[][] _grid = clone2D(grid);
            int[] _playerFigures = clone(playerFigures);
            int[] _botFigures = clone(botFigures); 

            _grid[i][j] = size + 1;
            _botFigures[size] = _botFigures[size] - 1;

            double score = minimax(1, false, _grid, _playerFigures, _botFigures);
            if (score > maxScore) {
              maxScore = score;
              bestMoveX = i;
              bestMoveY = j;
              bestSize = size;
            }
          }
        }
      }
    }
  }


  int t = millis() - t0;
  if (t >= timeout) print(" The Computer reached his maximum computing time. He is now forced to play:");

  if (bestMoveX == -1 || bestMoveY == -1 || bestSize == -1) {
    println("No best move could be found by the computer");
    for (int size = 0; size < 3; size++) {
      if (botFigures[size] == 0) continue;

      for (int i = 0; i < gridSize; i++) {
        for (int j = 0; j < gridSize; j++) {
          if (grid[i][j] == 0) {
            grid[i][j] = size + 1;
            botFigures[size] = botFigures[size] - 1;
            return;
          }
        }
      }
    }
  }

  print(" Done after " + t + "ms.");
  grid[bestMoveX][bestMoveY] = bestSize + 1;
  botFigures[bestSize] = botFigures[bestSize] - 1;
}

double minimax(int depth, boolean isMaximizing, int[][] _grid, int[] _playerFigures, int[] _botFigures) {

  int w = checkWinner(_grid);
  if (millis() - t0 >= timeout /* || depth >= maxDepth || */ || w != 0 || noMoreMoves(_grid, !isMaximizing, _playerFigures, _botFigures)) { // terminal condition: if we have a clear winner or the board is full (no more moves to play)
    return w;
  }


  if (isMaximizing) {
    double maxScore = Double.NEGATIVE_INFINITY;

    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {

        for (int size = 0; size < 3; size++) {
          if (_botFigures[size] > 0) { // check each field with each available figure of every size

            if (abs(_grid[i][j]) < abs(size + 1)) { // check each field, which has a smaller figure (or none) on it, so new figure can be set on top

              int[][] __grid = clone2D(_grid);
              int[] __playerFigures = clone(_playerFigures);
              int[] __botFigures = clone(_botFigures); 

              __grid[i][j] = size + 1;
              __botFigures[size] = __botFigures[size] - 1;

              double score = minimax(depth + 1, false, __grid, __playerFigures, __botFigures);
              if (score > maxScore) maxScore = score;
            }
          }
        }
      }
    }


    return maxScore;
    //
  } else {
    double minScore = Double.POSITIVE_INFINITY;

    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {

        for (int size = 0; size < 3; size++) {
          if (_playerFigures[size] > 0) { // check each field with each available figure of every size

            if (abs(_grid[i][j]) < abs(size + 1)) { // check each field, which has a smaller figure (or none) on it, so new figure can be set on top

              int[][] __grid = clone2D(_grid);
              int[] __playerFigures = clone(_playerFigures);
              int[] __botFigures = clone(_botFigures); 

              __grid[i][j] = -size - 1;
              __playerFigures[size] = __playerFigures[size] - 1;

              double score = minimax(depth + 1, true, __grid, __playerFigures, __botFigures);
              if (score < minScore) minScore = score;
            }
          }
        }
      }
    }

    return minScore;
    //
  }
  //
}





int[] clone(int[] arr) {
  int[] res = new int[3];

  for (int i = 0; i < 3; i++)
    res[i] = arr[i];

  return res;
}

int[][] clone2D(int[][] arr) {
  int[][] res = new int[gridSize][gridSize];

  for ( int i = 0; i < gridSize; i++) {
    for ( int j = 0; j < gridSize; j++) {
      res[i][j] = arr[i][j];
    }
  }

  return res;
}
