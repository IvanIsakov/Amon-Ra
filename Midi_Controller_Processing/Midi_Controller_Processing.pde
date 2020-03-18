  
/* Amon-Ra. 

 A visual controller software working together with Amon-Ra Arduino-based visual controller.
 
 Receives four values from the Arduino ADCs via Serial and controls visuals depending on those parameters
 
 Has 9 modes, possibility to record video loops, possibility to overlay them
 
 Enjoy!
 
 17/03/2020 
 by Ivan Isakov.
*/

boolean rightEyeOpen = false;
boolean leftEyeOpen = false;
int leftEyeX, leftEyeY, rightEyeX, rightEyeY, mouthX, mouthY;
int eyeSize;
boolean mouthOpen = false;

import processing.video.*;
Capture video;
int numPixels;
color[] colors;
float[] inputData = new float[9]; // inByte[0-4]; keyBoard; mouseX, mouseY

float[] inByte = new float[4];
float[][] recordedData;

long timeCounter = 0;

import processing.serial.*;
Serial myPort;        // The serial port
boolean keyOrSerial = false;
color figureColor;

int recordingState = 0;
int recordingIndex = 0;
int replayIndex = 0;
long recordingTimer = 0;

boolean pauseComputation = false;
  

void setup() {
  fullScreen(P3D);
  background(0);
  //size(1280,720,P3D);
  //size(640, 480,P3D);
  colorMode(HSB);
  
  // Setup positions and sizes:
  figureColor = color(255,0,255);
  rectMode(CENTER);
  CreateCircleOfCircles();
  CreateSquares();
  InitialiseSound();
  InitSkin();
  // Initialise Serial
  myPort = new Serial(this, "COM8", 115200); // Choose port where you connect Amon-Ra
  myPort.bufferUntil('\n');
  
  //video = new Capture(this, 640, 480);
  video = new Capture(this, 320, 240);
  // Start capturing the images from the camera
  video.start(); 
  numPixels = video.width * video.height;
  colors = new color[numPixels];
  
  noCursor();
  // Start first mode as true:
  modeState[0] = true;
  for (int i = 1; i < modeState.length; i++) {
    modeState[i] = false;
  }
  textSize(100);
}

// Main body of the program
void draw() {
  RequestForDataFromArduino();
  CheckKeyboardPress();
  ChooseBackground(true);
  if (pauseComputation) return; // If I want some pause for CPU / GPU
  ProcessInputData(); // Record incoming Arduino data + keyboard + mouse
  DrawIndicators(); // Indicators for keeping track of knobs' positions
  DrawLiveVisuals();
}

void RequestForDataFromArduino() {
  if (millis() - timeCounter > 1000) {
    timeCounter = millis();
    myPort.write('<');
  }
}

void ProcessInputData() {
  inputData[0] = inByte[0];
  inputData[1] = inByte[1];
  inputData[2] = inByte[2];
  inputData[3] = inByte[3];
  inputData[4] = keyBoardHigh;
  inputData[5] = keyBoardMedium;
  inputData[6] = keyBoardLow;
  inputData[7] = mouseX;
  inputData[8] = mouseY;
}

void DrawLiveVisuals() {

  switch (recordingState) {
    case 0:
      OverLayModes(inputData, recordedInputStatic);
      break;
    case 1:
      RecordInputs();
      OverLayModes(inputData, recordedInputStatic);
      break;
    case 2:
      OverLayModes(recordedData[replayIndex], recordedInputStatic);
      replayIndex++;
      if (replayIndex > recordingIndex)
        replayIndex = 0;
      break;
    case 3:
      OverLayModes(inputData, recordedData[replayIndex]);
      replayIndex++;
      if (replayIndex > recordingIndex)
        replayIndex = 0;
      break;
  }
}

void RecordInputs() {
  float[] newLine = {inByte[0], inByte[1], inByte[2], inByte[3], keyBoardHigh, keyBoardMedium, keyBoardLow, mouseX, mouseY};
  recordedData[recordingIndex] = newLine;
  recordingIndex ++;
  if (recordingIndex > 999)
      recordingIndex = 0;
}
  

void Modes(int modeNumber, float[] input) {

  switch (modeNumber)
  {
    case 1:
      DrawGeometricFigures(input[1], (int)map(input[2],0,1024,2,8), (int)input[5], (int)input[0]/4, (int)(input[3] / 4));
      break;
    case 2:
      DrawSun((int)(input[5] - 1), (int)input[2] / 10, (int)input[3], (int)input[0]/4, (int)input[1] / 2, (int)(input[4] - 1) * 25);
      break;
    case 3:
      //DrawCircles((int)map(input[2],0,1024,1,30), (int)(input[1] * 1.5), (int) input[5], (int)input[3] /  100, (int)input[0] / 4, (int)input[4] * 25);
      DrawVulva((int)input[1], input[5], input[3] * 0.0002, ((int)input[4] - 1) * 20, input[2] / 200);
      break;
    case 4:
      ThreeDMatrix((int)input[1] / 5, 1 + (int)input[2] /  100, keyBoardLow, (int)input[3] /  10, (int)input[0] /  4, ((int)input[4] - 1) * 25, (int)input[5] );
      break;
    case 5:
      Spiral((int)input[3] / 50, (int)input[1] / 4, input[2], (int)input[0] / 4, (int)input[5], ((int)input[4] - 1) * 10, 0.5, ((int)input[6] - 1) * 10);
      break;
    case 6:
      DrawSquares((int)input[1], (int)input[0], (int)input[2] / 30, input[3] * 0.1, (int)input[4], (int) input[5] * 100);
      break;
    case 7:
      DrawParticles(1 + (int)input[3]/30, (int)input[0] / 100, (int)input[2] + 150, (int)input[1] / 10, (int)(255 - input[4] * 25), (int)input[7], (int)input[8]);
      break;
    case 8:
      //DrawAudioClouds(input[0], input[1], input[2], input[3], (int)input[4], (int)input[5], (int)input[8], (int)input[6] * 25);
      CameraGame((int)input[2] / 4, (int)input[0] / 4, input[1] * 0.002, (int)input[5] - 1, (int)input[3] / 4, (int)input[4]); 
      break;
    case 9:
      DrawPyramid((int)input[1], (int)input[0] / 4, (int)(input[5] - 1), input[3] * 0.01, (int)map(input[2],0,1024,1,8), (int)(20 - 2*input[4]));
      break;
    default:
      break;
  }
}


void OverLayModes(float[] input, float[] inputPrevious) {
  pushMatrix();
  Modes(activeModes[2], recordedInputTwo);
  popMatrix();
  pushMatrix();
  Modes(activeModes[1], inputPrevious);
  popMatrix();
  pushMatrix();
  Modes(activeModes[0], input);
  popMatrix();     
}

void DrawIndicators() {
  strokeWeight(1);
  pushMatrix();
  stroke(0,0,125,125);
  noFill();
  for (int i = 0; i < 4; i++) {
    rect(20 + (int)inByte[i] / 20, 50 + i * 50, (int)inByte[i] / 10, 30);
  }
  fill(125);
  textSize(20);
  text(recordingState,20,250);
  popMatrix();
}

void DrawPyramid(int size, int _color, int _speed, float _rotate, int pyramidNumber, int _transparency) {
  strokeWeight(2);
  translate(width/2, height/2, height/2);
  rotateX(_rotate);
  rotateY(0.001 * millis() * _speed);
  rotateX(PI/2);
  rotateZ(-PI/6);
  for (int i = 0; i < pyramidNumber; i++) {
    pushMatrix();
    rotateX(TWO_PI / pyramidNumber * i);
    AmonRa(_color, size, _transparency);
    popMatrix();
  }
}

void AmonRa(int _color, int size, int _transparency) {
  stroke(_color, 255,255);
  noFill();
  PyramidSize(size);
  translate(0,0,size/2);
  fill(_color, 255,255, _transparency);
  PyramidSize(size/2);
}

void PyramidSize(int size) {
  beginShape(TRIANGLES);
  vertex(-size, -size, -size);
  vertex( size, -size, -size);
  vertex(   0,    0,  size);
  
  vertex( size, -size, -size);
  vertex( size,  size, -size);
  vertex(   0,    0,  size);
  
  vertex( size, size, -size);
  vertex(-size, size, -size);
  vertex(   0,   0,  size);
  
  vertex(-size,  size, -size);
  vertex(-size, -size, -size);
  vertex(   0,    0,  size);
  endShape();
}

void DrawSun(float rotationSpeed, int numberOfLines, int colorIncrement,
            int _color, int _width, int _transparency) {
  // rotationSpeed from 0 to 1;
  // numberOfLines from 50 to 500;
  //stepOfLines = 0.1;
  translate(width/2, height/2);
  rotate(rotationSpeed * millis() * 0.001);
  for (int i = 0; i < numberOfLines; i ++) {
    //pushMatrix();
    rotate(TWO_PI / numberOfLines);
    int newColor = _color + i * colorIncrement / numberOfLines;
    newColor = newColor % 255;
    stroke(newColor,255,255);
    fill(newColor,255,255,_transparency);
    strokeWeight(1);
    //line(0, 0, 0, height);
    //rect(_width/2,_width/2,_width,width);
    rect(0,0,_width,width);
    //popMatrix();
  }
}


void Spiral(int _number, int _size, float _angle, int _color, int _speed, int _transparency, float _proportion, int _colorIncrement) {
  translate(width/2, height/2, height/2);
  rotateZ(_speed * millis() * 0.0002);
  strokeWeight(1);
  float angle = map(_angle, 0, 1024, -1.0, 1.0);
  for (int i = 0; i < _number; i++) {
    pushMatrix();
    fill((_color + _colorIncrement * i)%255,125,255,_transparency);
    stroke((_color + _colorIncrement * i)%255,125,255,_transparency + 120);
    rotateZ(2 * PI / _number * i);
    for (int j = 0; j < 10; j++) {
      rotateZ(angle);
      translate(_size/2*cos(angle/2),_size/2*sin(angle/2),0);
      pushMatrix();
      rotateX(millis()*0.001*(1+noise(i)));
      float prop = (10.0 - j) * 0.1;
      box(prop * _size,
          prop * _size * _proportion,
          prop * _size * _proportion);
      popMatrix();
    }
    popMatrix();
  }
}


void CameraGame(int hueThreshold, int _hueOffset, float _skewX, int _rotate, int brightnessThreshold, int pixelSize) {
  float _skewY = _skewX;
  if (video.available()) {
    video.read();
    video.loadPixels();
    for (int i = 0; i < numPixels; i++) {
      if (hue(video.pixels[i]) > hueThreshold){
        colors[i] = color(255,0,0);
      } else {
        colors[i] = color((brightness(video.pixels[i]) + _hueOffset)%255,saturation(video.pixels[i]), hue(video.pixels[i]));
      }
      if (brightness(video.pixels[i]) > brightnessThreshold) {
        colors[i] = color((saturation(video.pixels[i]) + _hueOffset)%255, hue(video.pixels[i]), brightness(video.pixels[i]));
      }
    }
  }
  noStroke();
  translate(width/2, height/2);
  rotate(millis() * 0.001 * _rotate);
  for (int i = 0; i < numPixels; i++) {
    fill(colors[i]);
    int j = i % 320;//640; /960
    rect((j - video.width/2) * 4 * _skewX, ((i / 480) - video.height / 3)* 6 *  _skewY, pixelSize * 2,pixelSize * 4 / 3);// * _skewX, 3 *  _skewY);
  }
  
}

void ChooseBackground(boolean fuzzy) {
  if (!fuzzy) {
    background(0);
  } else {
    fill(0,10);
    noStroke();
    rect(width/2,height/2,width,height);
  }
}

void ThreeDMatrix(float _size, float _numberOfUnits, int _dimensionality, int _distance, int _color, int _transparency, float _speed) {
  strokeWeight(1);
  translate(width/2, height/2, height/2);
  rotateX(millis() * 0.0002 * _speed);
  rotateY(millis() * 0.0002 * _speed);
  rotateZ(millis() * 0.0002 * _speed);
  int dimensions = 1;
  if (_dimensionality < 4) {
    dimensions = 1;
  } else if (_dimensionality < 7) {
    dimensions = 2;
  } else {
    dimensions = 3;
  }
  fill(_color, 255,255, _transparency);
  stroke(_color, 255,255);
  for (int i = 0; i < _numberOfUnits; i++) {
    switch (dimensions) {
      case 1:
        pushMatrix();
        translate(i * _distance - _distance * _numberOfUnits / 2, 0, 0);
        box(_size);
        popMatrix();
        break;
      case 2:
        for (int j = 0; j < _numberOfUnits; j++) {
          pushMatrix();
          translate(i * _distance - _distance * _numberOfUnits / 2, j * _distance - _distance * _numberOfUnits / 2, 0);
          box(_size);
          popMatrix();
        }
        break;
      case 3:
        for (int j = 0; j < _numberOfUnits; j++) {
          for (int k = 0; k < _numberOfUnits; k++) {
            pushMatrix();
            translate(i * _distance - _distance * _numberOfUnits / 2, j * _distance - _distance * _numberOfUnits / 2, k * _distance - _distance * _numberOfUnits / 2);
            box(_size);
            popMatrix();
          }
        }
        break;
    }
  }
}

void DrawCircles(int numberOfCircles, int initialCircleSize, float period, int colorIncrement, int initialColor, int transparency) {
  initialCircleSize *= (1 + 0.5 * sin(period * millis() * 0.001));
  for (int i = numberOfCircles; i > 0; i--) {
    fill((5 * i * colorIncrement + initialColor)%255,125,transparency);
    stroke((5 * i * colorIncrement + initialColor)%255,125,255 - transparency);
    ellipse(width/2, height/2, initialCircleSize * i / numberOfCircles, initialCircleSize * i / numberOfCircles);
  }
}


// Draw Geometric Figures
void DrawGeometricFigures(float size, int numberOfCorners, int speed, int colorInput, int fill) {
  // size: from 0 to 1000;
  // numberOfCorners from 2 to 10
  // speed 
  figureColor = color(colorInput, 255, 255);
  translate(width/2, height/2);
  rotate(millis() * 0.002 * (speed - 1));
  int middleX = 0;
  int middleY = 0;
  stroke(figureColor);
  if (fill > 125) {
    figureColor = color(colorInput, 255 - (fill - 125)*2, 255);
  } 
  fill(figureColor, fill);
  strokeWeight(15);
  beginShape();

  for (int i = 0; i < numberOfCorners; i ++ ) {
    vertex(middleX + size * sin(TWO_PI * i / numberOfCorners), middleY +  + size * cos(TWO_PI * i / numberOfCorners));
    vertex(middleX + size * sin(TWO_PI * (i+1) / numberOfCorners), middleY +  + size * cos(TWO_PI * (i+1) / numberOfCorners));
  }
  endShape();
}

void serialEvent (Serial myPort) {
  // get the ASCII string:
  String inString = myPort.readStringUntil('\n');
  myPort.clear();
  if (inString != null) {
    inString = trim(inString); // trim off any whitespace:
    float[] inByteTest = float(split(inString, "\t"));
    if (inByteTest.length == 4) {
      inByte = inByteTest;
    }
    while (myPort.available() > 0) {
      int flashing = myPort.read();
    }
    myPort.write('<');
    //println(inByte);
  }
}
