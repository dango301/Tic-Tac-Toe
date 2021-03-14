# Tic Tac Toe with AI opponents
## *The standard Tic-Tac-Toe-Game & Matryoshka-Variation, each as multiplayer games and with AI opponents are included, respectively.*
##### written in Processing (Version 3.5.4)

### How to Play
##### Standard Tic Tac Toe
Both the multiplayer and AI versions are self-explanatory in their uses. Naughts and crosses are set on fields by clicking on them. The player beginning with the symbol X, is alternated after every finished game. Ending states are detected automatically. Nevertheless, the game can be reset at any point in time by pressing SPACE, in which case the beginning player is switched again.

##### Matryoshka-Variation
Similarly to the original game, a player must place three of his marks in a diagonal, horizontal or vertical row to win. However, players each receive a pair of three figures, which have different sizes. Besides empty fields, a figure may be placed on top of another figure (including one's own figures) **assuming it is of a bigger size**, similar to matryoshka dolls. The figures are dragged and dropped on fields from the sidebars, which indicate how many figures of each size the players have left, respectively. Illicit moves are highlighted as a figure is being dragged. It may be dropped outside of a valid field to choose another figure.

Unfortunately, *calculating all possible solutions for this variation of the game takes an indefinate, very long amount of time*, which is why the variable `int timeout` may be set by the user to *limit the amount of time the AI may take* to calculate its moves. It was intentionally introduced as not to merely limit the computing time by depth but by time aswell, as if the computer were a real player and forced to act, despite not having 'finished his thought', i.e. being interrupted without finishing to search at a constant depth on all branches of the search tree. If one wishes to receive more accurate responses by the AI, it must be limited via the maximum depth at which it should search, called the *horizon*. To do so, the public variable `int maxDepth` as well as the following code block must be considered:
```java
if (playerFigures[0] + playerFigures[1] + playerFigures[2] + botFigures[0] + botFigures[1] + botFigures[2] >= 2 * 3 * figsPerSize - 3) {
  if (depth >= maxDepth)
    return w;
}
```
The code above exclusively prevents the first two moves by the AI (until three figures have been played) from exceeding the initial horizon. In this sense, the depth of search is variable. Chiefly, choosing a reasonable value for maxDepth is very important: it should be set to the highest integer possible to find the best solution, of course, but **only as long as the AI does not time out before reaching the maximum depth**. If the console prints _'The Computer reached his maximum computing time. He is now forced to play'_, the AI will not have searched all branches of the search tree evenly and thus be likely to make a flawed move. As a consequence, the combination of the two public variables `timeout` and `maxDepth` should always be tested for this condition, should one expect an optimal game by the AI.

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

###### Note: Console logs within the minimax function slow down the computation considerably and should be avoided.
###### Icons designed by https://www.flaticon.com/de/autoren/nikita-golubev and https://www.flaticon.com/de/autoren/those-icons from www.flaticon.com
