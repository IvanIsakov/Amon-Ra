int indexUP = 100;
int r = 700;
float shapie = 0.01;
float speed = 0.02;
float[] bubble = new float[indexUP + 1];
ArrayList<skin> Skins = new ArrayList<skin>();
float count = 0;
float fluctuationAmp = 1;

void InitSkin() {
  for (int i = 0; i < indexUP/2; i++) {
    skin s = new skin(i, noise(i*shapie));
    Skins.add(s);
  }
  // Other half:
  for (int i = indexUP/2; i < indexUP + 1; i++) {
    skin s = new skin(i, noise((indexUP - i)*shapie));
    Skins.add(s);
  }
}

void DrawVulva(int _size, float _speed, float density, int transparency, float _fluctuationAmp) {
  translate(width/2,height/2);
  rotate(PI/2);
  shapie = density;
  speed = (_speed - 1) * 0.01;
  r = _size;
  anotherFunc();
  fluctuationAmp = _fluctuationAmp;

  Fract(1, transparency);
  Fract(1.2, transparency);
  Fract(1.5, transparency);
  Fract(2, transparency);
  Fract(3, transparency);
  Fract(5, transparency);

  count ++;
}

void Fract(float del, int _transparency) {
  if (_transparency == 0) {
    stroke((del*count)%255,255,255,125);
    noFill();
  } else if (_transparency < 100) {
    fill((del*count)%255,255,255,_transparency);
    noStroke();
  } else {
    fill((del*count)%255,0,(del*count)%255,_transparency);
    noStroke();
  }
  beginShape();
  for (int i = 0; i < indexUP + 1; i++) {
    Skins.get(i).update();
    Skins.get(i).display(del);
  }
  endShape(CLOSE);
}

void anotherFunc() {
  for (int i = 0; i < indexUP/2; i++) {
    Skins.get(i).bubble = noise(i*shapie + count*speed);
  }
  for (int i = indexUP/2; i < indexUP + 1; i++) {
    Skins.get(i).bubble = noise((indexUP - i)*shapie + count*speed);
  }

}

class skin {
  float bubble,x,y;
  float angle;
  float num;
  
  skin(int i, float bubble1) {
    angle = i * TWO_PI / indexUP;
    bubble = bubble1;
    num = i;
  }
  
  void update() {
    x = (fluctuationAmp * (bubble - 0.5) + 0.5) * r*cos(angle);
    y = (fluctuationAmp * (bubble - 0.5) + 0.5) * r*sin(angle);
  }
  
  void display(float del) {
    vertex(x/del,y/del);
  }
  
}
