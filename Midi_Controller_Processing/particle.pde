float aX = 0;
float aY = 0;
float damping = 0.02, 
      gravityForce = 10, 
      repulsionVar = 5, 
      energyLossOnImpact = 0.99;
boolean connectedLinesOnly = true;
color particleColor = #ffffff;
int smallParticleSize = 16;
int largeCircleSize = 150;
int strokeThickness = 1;
int lineDistance = 300;
int attractionVar = 15;
int numberOfGravityWells = 1;

ArrayList<particle> cloud = new ArrayList<particle>();

void CreateCircleOfCircles() {
  for (int i = 0; i < 5000; i++) {
    int x = (int)random(width);
    int y = (int)random(3 * height / 4);
    float radius = sqrt(sq(x-width/2) + sq(y-height/4));
    if (radius < 225) {
      particle p = new particle(x, y, smallParticleSize);
      cloud.add(p);
    }
  }  
  println(cloud.size());
}

void DrawParticles(int thickness, int colorChange, int _lineDistance, 
                  int _attraction, int colorSaturation, int mousePosX, int mousePosY) {
  particleColor = color(colorChange * 25, colorSaturation, 255);
  strokeThickness = thickness;
  lineDistance = _lineDistance;
  attractionVar = _attraction;
  
  for (particle p : cloud) {
      p.centralAttraction(mousePosX, mousePosY);
      p.display();
  }
}

void DrawFallingParticles() {
  for (particle p : cloud) {
    p.naturalMovement();
    p.display();
  }
}

class particle {
  float x, y;
  float vx, vy, v;
  float a,b,c, angle; // Angles
  int ptSize;

  boolean noAttraction = false;

  boolean main;

  particle(float x1, float y1, int pSize) {
    this.x = x1;
    this.y = y1;
    this.ptSize = pSize;
    a = random(1);
    b = random(1);
    c = random(1);
    //angle = random(PI);
    angle = 0;
  }

  void attractToMouse(float attraction, int _aX, int _aY) { // float attraction = 15;
    aX = _aX;
    aY = _aY;
    float attractV = (sqrt((aX - x)*(aX - x) + (aY - y)*(aY - y)) + 1);
    vx += -damping*vx + attraction*(aX - x)/attractV;
    vy += -damping*vy + attraction*(aY - y)/attractV;
    v = sqrt(vx*vx + vy*vy);
  }
  
  void applyGravity() {
    float[] f = new float[2];
    //f = force(x,y);
    f[1] = -gravityForce;
    vx += -damping*vx - f[0];
    vy += -damping*vy - f[1];
  }
  
  void centralAttraction(int _aX, int _aY) {
    repulse(repulsionVar, 100);
    attractToMouse(attractionVar, _aX, _aY);
    move();
    bounceOfTheWalls();
  }
  
  void naturalMovement() {
    repulse(repulsionVar, 100);
    if (!noAttraction) {
      applyGravity();
    }
    move();
    bounceOfTheWalls();
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
    // Bottom barrier:
    int bottomBarrier = height;//3*height/4;
    if (y > bottomBarrier) {
      y = bottomBarrier;
      vy = -vy * energyLossOnImpact;
    }
  }
  
  void repulse(float repulsion, int cutoffDistance) {
    strokeWeight(strokeThickness);
    stroke(particleColor);      
    for (particle p : cloud) {
      if (p != this && !main) {
        float dist = ( (x-p.x)*(x-p.x) + (y-p.y)*(y-p.y));
        if (dist < cutoffDistance) {
          vx += repulsion*(x - p.x)/(dist+1);
          vy += repulsion*(y - p.y)/(dist+1);
        }
        if (connectedLinesOnly) {
          if (dist < lineDistance) {
            line(p.x,p.y,x,y);
          }
        }
      }
    }
  }
  
  void move() {
    x += vx;
    y += vy; 
  }
  
  void display() {
    //ellipse(x, y, ptSize, ptSize);
    //drawTriangle(x, y, ptSize);
    noStroke();
    fill(particleColor);
    if (!connectedLinesOnly) {
      ellipse(x,y,ptSize,ptSize);
    }
  }
  
  void drawTriangle(float x, float y, int sizeImg) {
  //  color pix = img.get(x, y);
  //  fill(pix, 188);  
    pushMatrix();
    translate(x,y);
    rotate(angle);
    beginShape();
    vertex(-sizeImg*a,0);
    vertex(sizeImg*b,0);
    vertex(0,sizeImg*c);
    endShape(CLOSE);
    popMatrix();
  }
}
