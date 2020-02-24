float repulsion = 3;
float attraction = 1;
float audioDamping = 0.3;
float dt = 1;
int radius = 200;
ArrayList<audioParticle> audioCloud = new ArrayList<audioParticle>();
float multiplier[] = new float[60];

import ddf.minim.analysis.*;
import ddf.minim.*;

Minim       minim;
AudioPlayer jingle;
FFT         fft;
FFT         fftLog;
FFT         fftLog2;
AudioInput  in;

float[] logfft; 
int fftLogArraySize = 30;
int fftSplit = 4;
int fftSplit2 = 8;

int loudness = 23;
float bassToSnare = 0.3;

void InitialiseSound() {
  minim = new Minim(this);
  in = minim.getLineIn();
  for (int i = 0; i < multiplier.length; i++) {
    multiplier[i] = 0.1;
  }
  //in.play();
  fft = new FFT( in.bufferSize(), in.sampleRate() );
  fftLog = new FFT( in.bufferSize(), in.sampleRate() );
  fftLog.logAverages(20,6);
  fftLog2 = new FFT( in.bufferSize(), in.sampleRate() );
  fftLog2.logAverages(40,1);
  logfft = new float[513];
  
  for (int i = 0; i < 1024; i ++) {
   // int fftbin = (int)map(i,0,1024,0,256);
    int number = i;
    int fftbin = (int)random(60);
    //int fftbin = i / 18;
    audioParticle p = new audioParticle(random(width), random(height), fftbin, number);
    p.pix = color(fftbin * 4,155,255);
    audioCloud.add(p);
  }
}

void DrawAudioClouds(float low, float medLow, float medHigh, float high, int globalVolume, int rotationSpeed, int zoom, int colorIncrement) {
  strokeWeight(4);
  fftLog.forward( in.mix ); 
  for (int i = 0; i < 15; i++) {
    multiplier[i] = globalVolume * low * 0.001;
  }
  for (int i = 15; i < 30; i++) {
    multiplier[i] = globalVolume * medLow * 0.001;
  }
  for (int i = 30; i < 45; i++) {
    multiplier[i] = globalVolume * medHigh * 0.001;
  }
  for (int i = 45; i < 60; i++) {
    multiplier[i] = globalVolume * high * 0.001;
  }
  for (int i = 0; i < in.bufferSize() - 1; i++) {
    int bin = audioCloud.get(i).fftbin;
    //if (bin)
    float rho = sqrt(bin) * fftLog.getAvg(bin)*(in.left.get(i) * 2 * multiplier[bin]);
    
    audioCloud.get(i).vx += (rho) * cos(TWO_PI * audioCloud.get(i).posi / in.bufferSize());
    audioCloud.get(i).vy += (rho) * sin(TWO_PI * audioCloud.get(i).posi / in.bufferSize());    
  }
  translate(width/2,height/2);
  scale(1.0 + 10.0 * zoom / height);
  rotate(frameCount * rotationSpeed * 0.01);
  for (audioParticle p : audioCloud) {
    p.pix = color((p.fftbin * 4 + colorIncrement)%255,155,50 + fftLog.getAvg(p.fftbin)*100,50 + fftLog.getAvg(p.fftbin)*100);
    p.update();
    p.display();
  }
  
  /*
  for (audioParticle p : audioCloud) {
    p.pix = color(p.fftbin * 4,155,50 + fftLog.getAvg(p.fftbin)*100,50 + fftLog.getAvg(p.fftbin)*100);
    //p.update();
    p.vx = 0;
    p.vy = 50 + fftLog.getAvg(p.fftbin)*400;
    p.x = p.fftbin * 18;
    p.y = height;
    p.display();
  }
  */
}

class audioParticle {
  float x, y;
  float xInit, yInit;
  float vx, vy, v;
  float a,b,c, angle; // Angles
  int ptSize = 6;
  color pix;
  int fftbin;
  int posi;
  
  boolean main;

  audioParticle(float x1, float y1, int fftbin1, int posi1) {
    this.x = x1;
    this.y = y1;
    this.fftbin = fftbin1;
    this.posi = posi1;
    this.xInit = radius * cos(TWO_PI * posi1 / in.bufferSize());
    this.yInit = radius * sin(TWO_PI * posi1 / in.bufferSize());
  }

  void update() {
    // Damping
    vx += -audioDamping*vx*dt; //+ attraction*(aX - x)/attractV;
    vy += -audioDamping*vy*dt; //+ attraction*(aY - y)/attractV;
    attractToCentre();
    repulse();
    
    x += vx*dt;
    y += vy*dt;
    //x = lerp(x,xInit,0.2);
    //y = lerp(y,yInit,0.2);
    
  }
  
  
  void repulse() {
    //strokeWeight(1);
    stroke(pix,125);      
    for (audioParticle p : audioCloud) {
      if (p != this && !main) {
        float dist = sqrt( (x-p.x)*(x-p.x) + (y-p.y)*(y-p.y));
        if (dist < 40) {
          vx += repulsion*(x - p.x)/dist * exp(-sq(dist)/10000)*0.1;
          vy += repulsion*(y - p.y)/dist * exp(-sq(dist)/10000)*0.1;
          //line(this.x,this.y,p.x,p.y);
        }
      }
    }
  }
  
  void attractToCentre() {
    vx -= attraction*(x - xInit) / 100; // * exp(-sq(dist)/10000)*0.1
    vy -= attraction*(y - yInit) / 100;
    
    
  }
  
  void display() {
    stroke(pix);
    line(x,y,x - vx,y-vy);
  }
}
