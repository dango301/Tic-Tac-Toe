import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import processing.awt.PSurfaceAWT.SmoothCanvas; 
import javax.swing.JFrame; 
import java.awt.Dimension; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class Tic_Tac_Toe_Matryoshka extends PApplet {

// Public Variables
int timeout = 10; // in seconds
int maxDepth = 5; // should be chosen so that AI never times out before reaching maxDepth (test by checking first one or two moves by AI)





// Private Variables
int gridSize = 3; // number of columns and rows
float w;
float h;
float innerHeight;
float dim;
float boxSize;
int figsPerSize = 2;
int[] playerFigures = new int[3];
int[] botFigures = new int[3];
int[][] grid = new int[3][3];
boolean playerBegins = true;
boolean playerTurn;
boolean gameOver = false;


float offsetX;
float offsetY;
float minBarWidth = 150; // in px without barMargin
float barMargin = 16; // margins on each side of the two side bars in px
int bg = color(32, 32, 32);
int crimson = color(220, 20, 60);
int skyblue = color(51, 153, 255);
PShape blueFigure; // Icons by https://www.flaticon.com/de/autoren/nikita-golubev from flaticon.com
PShape redFigure; // Icons by https://www.flaticon.com/de/autoren/those-icons from flaticon.com
PFont font;
int dragging = 0;
boolean drawBeforeResponding = true;
int t0; // timestamp (long isn't needed since Integer works for a few days) for when bot begins calculating each time


public void setup() {
  
  // fullScreen();

  surface.setTitle("\"Tic Tac Toe with Matryoschkas\" by Dennis Paust  © 2021");
  surface.setLocation(0, 0);
  getSurface().setResizable(true);
  // following code block from https://forum.processing.org/two/discussion/15398/limiting-window-resize-to-a-certain-minimum
  SmoothCanvas sc = (SmoothCanvas) getSurface().getNative();
  JFrame jf = (JFrame) sc.getFrame();
  Dimension d = new Dimension(650, 600);
  jf.setMinimumSize(d);


  background(bg);
  shapeMode(CENTER);
  blueFigure = loadShape("matryoshka_male.svg");
  redFigure = loadShape("matryoshka_female.svg");
  font = createFont("Consolas Bold Italic", 12);
  textFont(font);

  reset();
}



public void reset() {
  for (int i = 0; i < gridSize; i++) {
    for (int j = 0; j < gridSize; j++) {
      grid[i][j] = 0;
    }
  }

  for (int i = 0; i < 3; i++) {
    playerFigures[i] = figsPerSize;
    botFigures[i] = figsPerSize;
  }

  println();
  println();
  playerTurn = playerBegins;
  playerBegins = !playerBegins;
  gameOver = false;
}

public void draw() {

  background(bg);
  noStroke();

  w = minBarWidth;
  h = height - 2 * barMargin;
  innerHeight = (h - 2 * barMargin);
  float[] figureMenuSizes = { w / 3, w / 2 + w / 10, w }; //calculated assuming that width is always smaller than height

  fill(skyblue);
  rect(barMargin, barMargin, w, h, 5);
  fill(crimson);
  rect(width - w - barMargin, barMargin, w, h, 5);



  // find smaller size of either available width or height for dimensions of grid and divide by gridSize to get size of each cell
  float dimX = width - 2 * (w + 2 * barMargin);
  float dimY = height - 2 * barMargin;
  dim = min(dimX, dimY);
  boxSize = dim / gridSize;
  offsetX = w + 2 * barMargin + 0.5f * dimX - 0.5f * dim;
  offsetY = barMargin + 0.5f * dimY - 0.5f * dim;
  //println(dimX, dimY, dim, offsetX, offsetY);

  fill(255); // square in center
  rect(offsetX, offsetY, dim, dim, 4);




  // display figures on board
  for (int x = 0; x < gridSize; x++) {
    for (int y = 0; y < gridSize; y++) {

      int val = grid[x][y];
      strokeWeight(1);
      stroke(0);
      noFill();
      rect(offsetX + x * boxSize, offsetY + y * boxSize, boxSize, boxSize, 2);

      if (val != 0) {
        float[] figureBoardSizes = { boxSize / 3, boxSize / 2, 3 * boxSize / 4 };
        float d = figureBoardSizes[abs(val) - 1]; // diameter
        shape(val < 0 ? blueFigure : redFigure, offsetX + x * boxSize + .5f * boxSize, offsetY + y * boxSize + .5f * boxSize, d, d);
      }

      if (dragging != 0 && val != 0 && abs(dragging) <= abs(val)) {
        fill(0, 0, 0, 100);
        rect(offsetX + x * boxSize, offsetY + y * boxSize, boxSize, boxSize, 2);
      }
    }
  }


  if (gameOver) {

    fill(255);
    textAlign(CENTER);
    textSize(34);
    text("Game\nOver", barMargin, barMargin + h / 4, w, (h - 2 * barMargin) / 2);
    text("Game\nOver", width - w - barMargin, barMargin + h / 4, w, (h - 2 * barMargin) / 2);

    String text0 = "Game ends\nin a draw";
    String text1 = "Player\n" + (checkWinner() == -1 ? "wins" : "loses");
    String text2 = "Computer\n" + (checkWinner() == 1 ? "wins" : "loses");
    textSize(20);
    text(checkWinner() == 0 ? text0 : text1, barMargin, barMargin + h * 3 / 4, w, (h - 2 * barMargin) / 2);
    text(checkWinner() == 0 ? text0 : text2, width - w - barMargin, barMargin + h * 3 / 4, w, (h - 2 * barMargin) / 2);

    noStroke();
    fill(0, 0, 0, 200);
    rect(offsetX, offsetY + 1.375f * boxSize, dim, boxSize / 4);
    fill(255);
    textAlign(CENTER, CENTER);
    text("Press SPACE to restart.", offsetX, offsetY + 1.375f * boxSize, dim, boxSize / 4);
  } else {

    noStroke();
    textSize(3 * figureMenuSizes[0] / 4);
    textAlign(CORNER);

    for (int i = 0; i < 3; i++) {
      shape(blueFigure, barMargin + w / 2, barMargin + i * innerHeight / 3 + innerHeight / 6, figureMenuSizes[i], figureMenuSizes[i]);
      fill(255, 255, 255, 200);
      circle(barMargin + w / 2 - figureMenuSizes[0] / 2, barMargin + i * innerHeight / 3 + innerHeight / 6 + figureMenuSizes[i] / 2, figureMenuSizes[0]);
      fill(0);
      int n = playerFigures[i];
      text(str(-dragging == i + 1 ? n - 1 : n), barMargin + w / 2 - 11 * figureMenuSizes[0] / 16, barMargin + i * innerHeight / 3 + innerHeight / 6 + figureMenuSizes[i] / 2 + figureMenuSizes[0] / 4);
    }

    for (int i = 0; i < 3; i++) {
      shape(redFigure, width - barMargin - w / 2, barMargin + i * innerHeight / 3 + innerHeight / 6, figureMenuSizes[i], figureMenuSizes[i]);
      fill(255, 255, 255, 200);
      circle(width - barMargin - w / 2 + figureMenuSizes[0] / 2, barMargin + i * innerHeight / 3 + innerHeight / 6 + figureMenuSizes[i] / 2, figureMenuSizes[0]);
      fill(0);
      int n = botFigures[i];
      text(str(dragging == i + 1 ? n - 1 : n), width - barMargin - w / 2 + 5 * figureMenuSizes[0] / 16, barMargin + i * innerHeight / 3 + innerHeight / 6 + figureMenuSizes[i] / 2 + figureMenuSizes[0] / 4);
    }

    fill(0, 0, 0, 120);
    if (!playerTurn) rect(barMargin, barMargin, w, h, 5);
    else rect(width - w - barMargin, barMargin, w, h, 5);
  }


  int c = ARROW;
  // set cursor for when mouse is over menu bars
  if (mouseY > 2 * barMargin && mouseY < height - barMargin * 2) {
    if (mouseX > 2 * barMargin && mouseX < w && playerTurn) c = HAND;
    else if (mouseX < width - 2 * barMargin && mouseX > width - w && !playerTurn) c = HAND;
  }



  if (dragging != 0) {

    float[] figureBoardSizes = { boxSize / 3, boxSize / 2, 3 * boxSize / 4 };
    float d = figureBoardSizes[abs(dragging) - 1]; // diameter
    shape(dragging < 0 ? blueFigure : redFigure, mouseX, mouseY, d, d);

    // set cursor when dragging
    if (!(mouseX < offsetX || mouseX >= offsetX + dim || mouseY < offsetY || mouseY >= offsetY + dim)) {
      float mx = mouseX - offsetX;
      float my = mouseY - offsetY;
      int x = floor(mx / boxSize);
      int y = floor(my / boxSize);
      if (grid[x][y] != 0 && abs(grid[x][y]) >= abs(dragging)) c = ARROW;
      else c = HAND;
    }
  }

  if (gameOver) c = ARROW;
  cursor(c);


  if (!gameOver && !playerTurn) { // this is in draw for when bot starts game as x

    if (drawBeforeResponding) {
      drawBeforeResponding = false;
      return;
    } else
      drawBeforeResponding = true;

    botResponse();
    checkWinner();
    playerTurn = true;
  }
}



public void mousePressed() {
  if (gameOver || !(mouseY > 2 * barMargin && mouseY < height - barMargin * 2)) return;

  int size;
  if (mouseY < h / 3) size = 1;
  else if (mouseY < 2 * h / 3) size = 2;
  else size = 3;

  if (mouseX > 2 * barMargin && mouseX < w && playerTurn) { // left bar
    if (playerFigures[size - 1] <= 0) {
      cursor(ARROW);
      return;
    }
    dragging = -size;
  } /*else if (mouseX < width - 2 * barMargin && mouseX > width - w && !playerTurn) { //right bar is played by bot, thus disabled for player
   if (botFigures[size - 1] <= 0) {
   cursor(ARROW);
   return;
   }
   dragging = size;
   }*/
}

public void mouseReleased() {
  if (gameOver || dragging == 0 || mouseX < offsetX || mouseX >= offsetX + dim || mouseY < offsetY || mouseY >= offsetY + dim) {
    //if (dragging != 0) println("\nReleased figure in void");
    dragging = 0;
    cursor(ARROW);
    return;
  }

  float mx = mouseX - offsetX;
  float my = mouseY - offsetY;
  int x = floor(mx / boxSize);
  int y = floor(my / boxSize);

  if (grid[x][y] != 0 && abs(grid[x][y]) >= abs(dragging)) { // illicit drag if figure on board is equally sized or bigger
    //println("Cannot set figure because there already is an equally sized or bigger figure at (" + x + "|" + y + ").");
    dragging = 0;
    cursor(ARROW);
    return;
  }

  // decrement amount of available figures of that particular size
  if (dragging < 0) playerFigures[-dragging - 1] = playerFigures[-dragging - 1] - 1;
  else botFigures[dragging - 1] = botFigures[dragging - 1] - 1;

  grid[x][y] = dragging;
  dragging = 0;
  checkWinner();
  playerTurn = !playerTurn;
  cursor(ARROW);
}


public void keyPressed() {
  if (key == ' ') reset();
}


public boolean equals3 /* and none empty */ (int v1, int v2, int v3) {
  boolean b1 = v1 > 0;
  boolean b2 = v2 > 0;
  boolean b3 = v3 > 0;
  return b1 == b2 && b1 == b3 && b2 == b3 && v1 != 0 && v2 != 0 && v3 != 0;
}

public int checkWinner(int[][]...alteredGrid) {
  // returns -1 when Player (blue) wins;
  // returns +1 when Computer (red) wins
  // returns 0 when nobody wins (draw or game is not yet finished, ==> check with boolan gameOver)

  int[][] _grid = alteredGrid.length > 0 ? alteredGrid[0] : grid;

  // Check vertically
  for (int i = 0; i < gridSize; i++) {
    if (equals3(_grid[i][0], _grid[i][1], _grid[i][2])) {
      if (alteredGrid.length == 0) gameOver = true;
      return _grid[i][0] > 0 ? 1 : -1;
    }
  }


  // Check horizontally
  for (int j = 0; j < gridSize; j++) {
    if (equals3(_grid[0][j], _grid[1][j], _grid[2][j])) {
      if (alteredGrid.length == 0) gameOver = true;
      return _grid[0][j] > 0 ? 1 : -1;
    }
  }


  // Check diagonally (top left to bottom right)
  if (equals3(_grid[0][0], _grid[1][1], _grid[2][2])) {
    if (alteredGrid.length == 0) gameOver = true;
    return _grid[0][0] > 0 ? 1 : -1;
  }

  // Check diagonally (top right to bottom left)
  if (equals3(_grid[2][0], _grid[1][1], _grid[0][2])) {
    if (alteredGrid.length == 0) gameOver = true;
    return _grid[0][2] > 0 ? 1 : -1;
  }


  if (alteredGrid.length == 0)
    if (noMoreMoves(grid, playerTurn, playerFigures, botFigures)) gameOver = true;



  return 0;
}



public boolean noMoreMoves(int[][] _grid, boolean _playerTurn, int[] _playerFigures, int[] _botFigures) {
  boolean end = true;


  // Check whether grid is full
  for (int i = 0; i < gridSize; i++) {
    for (int j = 0; j < gridSize; j++) {
      if (_grid[i][j] == 0) end = false;
    }
  }
  if (end) return true;



  // Check whether NEXT player has any moves left; ==> if not, game ends in a draw as in a stalemate
  // these calculations are done for the NEXT player, respectively, since stalemate is reached when the current player limits every possible following move for the NEXT player

  for (int i = 0; i < 3; i++) { //first check whether player has any figures to play
    if ((!_playerTurn && _playerFigures[i] > 0) || (_playerTurn && _botFigures[i] > 0)) end = false;
  }
  if (end) return true;


  for (int i = 0; i < 3; i++) {
    if ((!_playerTurn && _playerFigures[i] > 0) || (_playerTurn && _botFigures[i] > 0)) { // if current player has a figure of that size
      int fig = !_playerTurn ? _playerFigures[i] : _botFigures[i];

      for (int x = 0; x < gridSize; x++) {
        for (int y = 0; y < gridSize; y++) {
          if (abs(_grid[x][y]) < abs(fig)) // if player can play that figure on any field, game is not over
            return false;
        }
      }
      //
    }
  }


  return true;
}

public void botResponse() {
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
  if (t >= timeout * 1000) print(" The Computer reached his maximum computing time. He is now forced to play:");

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

public double minimax(int depth, boolean isMaximizing, int[][] _grid, int[] _playerFigures, int[] _botFigures) {
  int w = checkWinner(_grid);

  //confer documentation on GitHub, if you want to comment the follwing if-statement out: https://github.com/dango301/Tic-Tac-Toe/blob/main/README.md
  if (playerFigures[0] + playerFigures[1] + playerFigures[2] + botFigures[0] + botFigures[1] + botFigures[2] >= 2 * 3 * figsPerSize - 3) {
    if (depth >= maxDepth) {
      //println("Abort at depth", depth);
      return w;
    }
  }

  if (millis() - t0 >= timeout * 1000 || w != 0 || noMoreMoves(_grid, !isMaximizing, _playerFigures, _botFigures)) { // terminal condition: if we have a clear winner or the board is full (no more moves to play)
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





public int[] clone(int[] arr) {
  int[] res = new int[3];

  for (int i = 0; i < 3; i++)
    res[i] = arr[i];

  return res;
}

public int[][] clone2D(int[][] arr) {
  int[][] res = new int[gridSize][gridSize];

  for ( int i = 0; i < gridSize; i++) {
    for ( int j = 0; j < gridSize; j++) {
      res[i][j] = arr[i][j];
    }
  }

  return res;
}
  public void settings() {  size(800, 600); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "Tic_Tac_Toe_Matryoshka" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
