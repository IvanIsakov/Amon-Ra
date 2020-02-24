
ArrayList<squareObject> squares = new ArrayList<squareObject>();
int squareSizeX = 16;
int squareSizeY = 16;
float sqVelocity = 1, sqSaturation = 255;
float sizeFluctuation = 0;
int numberOfSquares = 100;
int timeDelay = 1;
int darknessTime = 0;

void CreateSquares() {
  for (int i = 0; i < numberOfSquares; i++) {
    int x = (int)random(width);
    int y = (int)random(height);
    squareObject sq = new squareObject(x, y, squareSizeX, i);
    squares.add(sq);
  }  
}

// FIX?
void DrawSquares(int sizeX, int sizeY, float speed, float fluctuation, int _timeDelay, int _darknessTime) {
  strokeWeight(1);
  sizeFluctuation = fluctuation - 50;
  squareSizeX = sizeX;
  squareSizeY = sizeY;
  sqVelocity = speed;
  timeDelay = _timeDelay;
  darknessTime = _darknessTime;
  for (squareObject sq : squares) {
    sq.display();
  }
}

class squareObject {
  float x, y;
  float vx, vy, v;
  float a,b,c, angle; // Angles
  int sqSizeX, sqSizeY;
  color sqColour;
  float fraction;
  int number;

  boolean noAttraction = false;

  boolean main;

  squareObject(float x1, float y1, int sSize, int _number) {
    this.x = x1;
    this.y = y1;
    this.sqSizeY = sSize;
    this.sqSizeX = sSize / 2;
    vx = random(-1,1);
    vy = random(-1,1);
    a = random(1);
    b = random(1);
    c = random(1);
    fraction = random(1);
    //angle = random(PI);
    angle = 0;
    sqColour = color(random(255),sqSaturation, 255);
    number = _number;
  }

  void display() {
    stroke(hue(this.sqColour), 0, 125, 125);
    if (((frameCount *sqVelocity) % (numberOfSquares + darknessTime)) <= number + timeDelay &&
        (sqVelocity *frameCount) % (numberOfSquares + darknessTime) >= number - timeDelay) {
      sqSaturation = 255;
    } else {
      sqSaturation = 0;
    }
    fill(hue(this.sqColour), 0, sqSaturation, 125);
    sqSizeX = (int)(random(sizeFluctuation) + squareSizeX);
    sqSizeY = (int)(random(sizeFluctuation) + squareSizeY);
    //move();
    bounceOfTheWalls();
    rect(x,y,sqSizeX,sqSizeY);
  }
  
  void move() {
    x += sqVelocity * vx;
    y += sqVelocity * vy; 
  }
  
  void bounceOfTheWalls() {
    if (x < 0) {
      x = 0;
      vx = -vx;
    }
    if (x > width) {
      x = width;
      vx = -vx;
    }
    if (y < 0) {
      y = 0;
      vy = -vy;
    }
    if (y > height) {
      y = height;
      vy = -vy;
    }
  }
}
