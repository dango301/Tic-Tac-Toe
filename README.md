# Tic Tac Toe with AI opponents
## *The standard Tic-Tac-Toe-Game & Matryoshka-Variation, each as multiplayer games and with AI opponents are included, respectively.*
##### written in Processing (Version 3.5.4)

### How to Play
##### Standard Tic Tac Toe
Both the multiplayer and AI versions are self-explanatory in their uses. Naughts and crosses are set on fields by clicking on them. The player beginning with the symbol X, is alternated after every finished game. Ending states are detected automatically. Nevertheless, the game can be reset at any point in time by pressing SPACE, in which case the beginning player is switched again.
##### Matryoshka-Variation
Similarly to the original game, a player must place three of his marks in a diagonal, horizontal or vertical row to win. However, players each receive a pair of three figures, which have different sizes. Besides empty fields, a figure may be placed on top of another figure (including one's own figures) **assuming it is of a bigger size**, similar to matryoshka dolls. The figures are dragged and dropped on fields from the sidebars, which indicate how many figures of each size the players have left, respectively. Illicit moves are highlighted as a figure is being dragged. It may be dropped outside of a valid field to choose another figure.

### Artificial Intelligence
The AI players are based on the [Minimax-Algorithm](https://en.wikipedia.org/wiki/Minimax "Wikipedia: The Minimax Algorithm"). The algorithm finds the best possible solution for its next move on the playing board. A score is associated with each possible move, where a loss yields -1, a draw 0 and a win +1 being the AI player. Therefore, the AI calculates each and every possible move in a *depth-first-search* until the game is finished, either by a
- win / loss,
- draw, or 
- stalemate, where one player has no possible moves left (e.g. no figures left to play).

In Minimax, it is assumed that each player makes the best possible move, i.e. no mistakes. It begins as the **Maximizer**, who tries to achieve the highest possible score, representing the AI. The same applies for the **Minimizer** analogously, who tries to achieve the lowest score possible, representing the player. Using a recursive function the Maximizer and the Minimizer take turns simulating all possible outcomes. Finally, the move associated with the highest score is chosen by the AI. Confer the following code block to apply the concept:
 
 ```java
double minimax(char[][] _grid, int depth, boolean isMaximizing) {

  int w = checkWinner(_grid); 
  if (w != 0 || noMoreMoves(_grid)) { // terminal condition: if we have a clear winner or the board is full (no more moves to play)
    return w;


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

      }
    }

    return maxScore;

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


      }
    }

    return minScore;
  }
}
 ```

###### Icons designed by https://www.flaticon.com/de/autoren/nikita-golubev and https://www.flaticon.com/de/autoren/those-icons from www.flaticon.com
