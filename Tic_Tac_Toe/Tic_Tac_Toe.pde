
import processing.awt.PSurfaceAWT.SmoothCanvas;
import javax.swing.JFrame;
import java.awt.Dimension;

// Private Variables
int gridSize = 3; // number of columns and rows
float w;
float h;
float dim;
float boxSize;
char[][] grid = new char[3][3];
boolean playerTurn;
char playerSymbol = 'o'; // if 'o', player starts; if 'x', computer starts
char botSymbol;
boolean gameOver = false;


float offsetX;
float offsetY;
float minBarWidth = 150; // in px without barMargin
float barMargin = 16; // margins on each side of the two side bars in px
color bg = color(32, 32, 32);
color crimson = color(220, 20, 60);
color skyblue = color(51, 153, 255);
PFont font;
PFont font2;


void setup() {
  size(800, 600);
  // fullScreen();

  surface.setTitle("\"Tic tac Toe\" by Dennis Paust  © 2021");
  surface.setLocation(0, 0);
  getSurface().setResizable(true);
  // following code block from https://forum.processing.org/two/discussion/15398/limiting-window-resize-to-a-certain-minimum
  SmoothCanvas sc = (SmoothCanvas) getSurface().getNative();
  JFrame jf = (JFrame) sc.getFrame();
  Dimension d = new Dimension(650, 500);
  jf.setMinimumSize(d);


  background(bg);
  shapeMode(CENTER);
  font = createFont("Consolas Bold Italic", 12);
  font2 = createFont("Consolas Bold", 12);
  textFont(font);

  reset();
}



void reset() {

  for (int i = 0; i < gridSize; i++) {
    for (int j = 0; j < gridSize; j++) {
      grid[i][j] = ' ';
    }
  }

  playerTurn = playerSymbol != 'x';
  playerSymbol = playerTurn ? 'x' : 'o';
  botSymbol = playerTurn ? 'o' : 'x';

  println();
  println();
  gameOver = false;
}



void display(char[][] _grid) {



  for (int x = 0; x < gridSize; x++) {
    for (int y = 0; y < gridSize; y++) {

      strokeWeight(1);
      stroke(0);
      noFill();
      rect(offsetX + x * boxSize, offsetY + y * boxSize, boxSize, boxSize, 2);

      if (_grid[x][y] != ' ') {
        textFont(font2);
        textSize(boxSize);
        textAlign(CENTER, CENTER);
        fill(0);
        text(str(_grid[x][y]).toUpperCase(), offsetX + x * boxSize + boxSize / 2, offsetY + y * boxSize + boxSize / 2);
        textFont(font);
      }
    }
  }
}


void draw() {

  background(bg);
  noStroke();

  w = minBarWidth;
  h = height - 2 * barMargin;

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


  display(grid);



  if (gameOver) {

    fill(255);
    textAlign(CENTER);
    textSize(34);
    text("Game\nOver", barMargin, barMargin + h / 4, w, (h - 2 * barMargin) / 2);
    text("Game\nOver", width - w - barMargin, barMargin + h / 4, w, (h - 2 * barMargin) / 2);

    String text0 = "Game ends\nin a draw";
    String text1 = "Player\n(" + playerSymbol + ") " + (checkWinner() == -1 ? "wins" : "loses");
    String text2 = "Computer\n(" + botSymbol + ") " + (checkWinner() == +1 ? "wins" : "loses");
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


    fill(255);
    textAlign(CENTER);
    textSize(34);
    text(str(playerSymbol), barMargin, barMargin + h / 4, w, (h - 2 * barMargin) / 2);
    text(str(botSymbol), width - w - barMargin, barMargin + h / 4, w, (h - 2 * barMargin) / 2);

    textSize(20);
    text("Player's\nTurn", barMargin, barMargin + h * 3 / 4, w, (h - 2 * barMargin) / 2);
    text("Computer's\nTurn", width - w - barMargin, barMargin + h * 3 / 4, w, (h - 2 * barMargin) / 2);

    fill(0, 0, 0, 100);
    if (!playerTurn) rect(barMargin, barMargin, w, h, 5);
    else rect(width - w - barMargin, barMargin, w, h, 5);
  }


  int c = ARROW;

  if (mouseX >= offsetX && mouseX < offsetX + dim && mouseY >= offsetY && mouseY < offsetY + dim) {
    float mx = mouseX - offsetX;
    float my = mouseY - offsetY;
    int x = floor(mx / boxSize);
    int y = floor(my / boxSize);
    if (grid[x][y] == ' ') c = HAND;
  }

  if (gameOver) c = ARROW;
  cursor(c);


  if (!gameOver && !playerTurn) { // this is in draw for when bot starts game as x
    botResponse();
    checkWinner();
    playerTurn = true;
  }
}



void mousePressed() {
  if (gameOver || !playerTurn || !(mouseY > 2 * barMargin && mouseY < height - barMargin * 2)) return;


  float mx = mouseX - offsetX;
  float my = mouseY - offsetY;
  int x = floor(mx / boxSize);
  int y = floor(my / boxSize);

  if (x > 2 || y > 2 || x < 0 || y < 0) return;

  if (grid[x][y] == ' ') {
    grid[x][y] = playerSymbol;
    checkWinner();
    playerTurn = false;
  } /*else
   println("Invalid move; field at", x, y, "is already filled");*/
}



void keyPressed() {
  if (key == ' ') reset();
}

boolean equals3 /* and not empty */ (char v1, char v2, char v3) {
  return v1 == v2 && v1 == v3 && v2 == v3 && v1 != ' ';
}

int checkWinner(char[][]...alteredGrid) {
  // returns -1 when Player (blue) wins;
  // returns +1 when Computer (red) wins
  // returns 0 when nobody wins (draw or game not finished) ==> use boolean gameOver or noMoreMoves-function to check which is the case 

  char[][] _grid = alteredGrid.length > 0 ? alteredGrid[0] : grid;

  // Check vertically
  for (int i = 0; i < gridSize; i++) {
    if (equals3(_grid[i][0], _grid[i][1], _grid[i][2])) {
      if (alteredGrid.length == 0) gameOver = true;
      return _grid[i][0] == botSymbol ? 1 : -1;
    }
  }


  // Check horizontally
  for (int j = 0; j < gridSize; j++) {
    if (equals3(_grid[0][j], _grid[1][j], _grid[2][j])) {
      if (alteredGrid.length == 0) gameOver = true;
      return _grid[0][j] == botSymbol ? 1 : -1;
    }
  }


  // Check diagonally (top left to bottom right)
  if (equals3(_grid[0][0], _grid[1][1], _grid[2][2])) {
    if (alteredGrid.length == 0) gameOver = true;
    return _grid[0][0] == botSymbol ? 1 : -1;
  }

  // Check diagonally (top right to bottom left)
  if (equals3(_grid[2][0], _grid[1][1], _grid[0][2])) {
    if (alteredGrid.length == 0) gameOver = true;
    return _grid[0][2] == botSymbol ? 1 : -1;
  }


  if (alteredGrid.length == 0 && noMoreMoves(_grid))
    gameOver = true;

  return 0;
}


boolean noMoreMoves(char[][] _grid) {

  for (int i = 0; i < gridSize; i++) {
    for (int j = 0; j < gridSize; j++) {
      if (_grid[i][j] == ' ') return false;
    }
  }

  return true;
}



char[][] clone(char[][] arr) {
  char[][] res = new char[3][3];
  for (int i = 0; i < gridSize; i++) {
    for (int j = 0; j < gridSize; j++) {
      res[i][j] = arr[i][j];
    }
  }
  return res;
}

void printGrid(char[][] _grid) {
  println();
  for (int i = 0; i < gridSize; i++) {
    for (int j = 0; j < gridSize; j++) {
      print(_grid[j][i]); 
      if (j != 2) print("|");
    }
    println();
  }
}
