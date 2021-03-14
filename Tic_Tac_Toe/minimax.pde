// confer https://de.wikipedia.org/wiki/Minimax-Algorithmus#Implementierung, Stand: 12.03.2021

void botResponse() {

  int bestMoveX = -1;
  int bestMoveY = -1;
  double maxScore = Double.NEGATIVE_INFINITY;

  for (int i = 0; i < gridSize; i++) {
    for (int j = 0; j < gridSize; j++) {
      if (grid[i][j] == ' ') {
        char[][] _grid = clone(grid);
        _grid[i][j] = botSymbol;
        double score = minimax(_grid, 0, false);

        if (score > maxScore) {
          maxScore = score;
          bestMoveX = i;
          bestMoveY = j;
        }
      }
    }
  }
  
  
  if (bestMoveX == -1 || bestMoveY == -1) {
    println("No best move could be found by the computer");
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        if (grid[i][j] == ' ') {
          grid[i][j] = botSymbol;
          return;
        }
      }
    }
  }


  grid[bestMoveX][bestMoveY] = botSymbol;
}

double minimax(char[][] _grid, int depth, boolean isMaximizing) {

  int w = checkWinner(_grid); 
  if (w != 0 || noMoreMoves(_grid)) { // terminal condition: if we have a clear winner or the board is full (no more moves to play)
    //print("\nScore:", w);
    //printGrid(_grid); //alle Spielausgänge sehen
    return w;
  }


  if (isMaximizing) {
    double maxScore = Double.NEGATIVE_INFINITY;

    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {

        if (_grid[i][j] == ' ') {
          char[][] __grid = clone(_grid);
          __grid[i][j] = botSymbol;
          double score = minimax(__grid, depth + 1, false);
          if (score > maxScore) maxScore = score;
        }
        //
      }
    }


    return maxScore;
    //
  } else {
    double minScore = Double.POSITIVE_INFINITY;

    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        if (_grid[i][j] == ' ') {
          char[][] __grid = clone(_grid);
          __grid[i][j] = playerSymbol;
          double score = minimax(__grid, depth + 1, true);
          if (score < minScore) minScore = score;
        }

        //
      }
    }


    return minScore;
    //
  }
  //
}
