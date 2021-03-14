import processing.awt.PSurfaceAWT.SmoothCanvas;
import javax.swing.JFrame;
import java.awt.Dimension;

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
color bg = color(32, 32, 32);
color crimson = color(220, 20, 60);
color skyblue = color(51, 153, 255);
PShape blueFigure; // Icons by https://www.flaticon.com/de/autoren/nikita-golubev from flaticon.com
PShape redFigure; // Icons by https://www.flaticon.com/de/autoren/those-icons from flaticon.com
PFont font;
int dragging = 0;


void setup() {
  size(800, 600);
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



void reset() {
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

void draw() {

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
  offsetX = w + 2 * barMargin + 0.5 * dimX - 0.5 * dim;
  offsetY = barMargin + 0.5 * dimY - 0.5 * dim;
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
        shape(val < 0 ? blueFigure : redFigure, offsetX + x * boxSize + .5 * boxSize, offsetY + y * boxSize + .5 * boxSize, d, d);
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
    String text1 = "Blue Player\n" + (checkWinner() == -1 ? "wins" : "loses");
    String text2 = "Red Player\n" + (checkWinner() == 1 ? "wins" : "loses");
    textSize(20);
    text(checkWinner() == 0 ? text0 : text1, barMargin, barMargin + h * 3 / 4, w, (h - 2 * barMargin) / 2);
    text(checkWinner() == 0 ? text0 : text2, width - w - barMargin, barMargin + h * 3 / 4, w, (h - 2 * barMargin) / 2);

    noStroke();
    fill(0, 0, 0, 200);
    rect(offsetX, offsetY + 1.375 * boxSize, dim, boxSize / 4);
    fill(255);
    textAlign(CENTER, CENTER);
    text("Press SPACE to restart.", offsetX, offsetY + 1.375 * boxSize, dim, boxSize / 4);
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
}



void mousePressed() {
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
  } else if (mouseX < width - 2 * barMargin && mouseX > width - w && !playerTurn) { //right bar
    if (botFigures[size - 1] <= 0) {
      cursor(ARROW);
      return;
    }
    dragging = size;
  }
}

void mouseReleased() {
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

  if (grid[x][y] != 0 && abs(grid[x][y]) >= abs(dragging)) {
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


void keyPressed() {
  if (key == ' ') reset();
}




boolean equals3 /* and none empty */ (int v1, int v2, int v3) {
  boolean b1 = v1 > 0;
  boolean b2 = v2 > 0;
  boolean b3 = v3 > 0;
  return b1 == b2 && b1 == b3 && b2 == b3 && v1 != 0 && v2 != 0 && v3 != 0;
}

int checkWinner() {
  // returns -1 when Player (blue) wins;
  // returns +1 when Computer (red) wins
  // returns 0 when nobody wins (draw or game is not yet finished, ==> check with boolan gameOver)

  // Check vertically
  for (int i = 0; i < gridSize; i++) {
    if (equals3(grid[i][0], grid[i][1], grid[i][2])) {
      gameOver = true;
      return grid[i][0] > 0 ? 1 : -1;
    }
  }


  // Check horizontally
  for (int j = 0; j < gridSize; j++) {
    if (equals3(grid[0][j], grid[1][j], grid[2][j])) {
      gameOver = true;
      return grid[0][j] > 0 ? 1 : -1;
    }
  }


  // Check diagonally (top left to bottom right)
  if (equals3(grid[0][0], grid[1][1], grid[2][2])) {
    gameOver = true;
    return grid[0][0] > 0 ? 1 : -1;
  }

  // Check diagonally (top right to bottom left)
  if (equals3(grid[2][0], grid[1][1], grid[0][2])) {
    gameOver = true;
    return grid[0][2] > 0 ? 1 : -1;
  }


  if (noMoreMoves()) gameOver = true;



  return 0;
}



boolean noMoreMoves() {
  boolean end = true;


  // Check whether grid is full
  for (int i = 0; i < gridSize; i++) {
    for (int j = 0; j < gridSize; j++) {
      if (grid[i][j] == 0) end = false;
    }
  }
  if (end) return true;



  // Check whether NEXT player has any moves left; ==> if not, game ends in a draw as in a stalemate
  // these calculations are done for the NEXT player, respectively, since stalemate is reached when the current player limits every possible following move for the NEXT player

  for (int i = 0; i < 3; i++) { //first check whether player has any figures to play
    if ((!playerTurn && playerFigures[i] > 0) || (playerTurn && botFigures[i] > 0)) end = false;
  }
  if (end) return true;


  for (int i = 0; i < 3; i++) {
    if ((!playerTurn && playerFigures[i] > 0) || (playerTurn && botFigures[i] > 0)) { // if current player has a figure of that size
      int fig = !playerTurn ? playerFigures[i] : botFigures[i];

      for (int x = 0; x < gridSize; x++) {
        for (int y = 0; y < gridSize; y++) {
          if (abs(grid[x][y]) < abs(fig)) // if player can play that figure on any field, game is not over
            return false;
        }
      }
      //
    }
  }


  return true;
}
