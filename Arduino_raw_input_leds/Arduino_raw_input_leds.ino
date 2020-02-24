#include <Wire.h>

const int SIGNAL = A2;
const int SIGNAL1 = A3;
const int SIGNAL2 = A4;
const int SIGNAL3 = A5;
int sensorValue, sensorValue1, sensorValue2, sensorValue3;
char startMarker = '<';
boolean received;

#include <FastLED.h>
#define LED_COUNT   10
#define LED_PIN     8
#define NUM_LEDS    10
#define BRIGHTNESS  64
#define LED_TYPE    WS2812B
#define COLOR_ORDER GRB
CRGB leds[NUM_LEDS];
#define UPDATES_PER_SECOND 100
CRGBPalette16 currentPalette;
TBlendType    currentBlending;
extern CRGBPalette16 myRedWhiteBluePalette;
extern const TProgmemPalette16 myRedWhiteBluePalette_p PROGMEM;
int Signal = 0;
long changeTime = 0; 
boolean up = true;

void setup(){
  delay( 1000 ); // power-up safety delay
  FastLED.addLeds<LED_TYPE, LED_PIN, COLOR_ORDER>(leds, NUM_LEDS).setCorrection( TypicalLEDStrip );
  FastLED.setBrightness(  BRIGHTNESS );

  currentPalette = RainbowColors_p;
  currentBlending = LINEARBLEND;

  FastLED.clear();
  Serial.begin(115200); 
}

void loop(){
  int temp;
  sensorValue = analogRead(SIGNAL);
  sensorValue1 = analogRead(SIGNAL1);
  sensorValue2 = analogRead(SIGNAL2);
  sensorValue3 = analogRead(SIGNAL3);
  writeToLeds();
  if (received) {
    Serial.print(sensorValue);
    Serial.print("\t");
    Serial.print(sensorValue1);
    Serial.print("\t");
    Serial.print(sensorValue2);
    Serial.print("\t");
    Serial.print(sensorValue3);
    Serial.println("");
    
    received = false;  
  }
  receiveByte();
}

void receiveByte() {
  while (Serial.available() > 0) {
    byte rc;
    rc = Serial.read();
    if (rc == startMarker) {
      received = true;
    }
  }
}


void writeToLeds() {
  if(millis() - changeTime > 50) {
    changeTime = millis();
    if (up) {
      Signal += 1;    
    } else {
      Signal -= 1;
    }
  }
  if (Signal > 255){ 
    Signal = 255;
    up = false;
  }
  if (Signal < 0) {
    Signal = 0;
    up = true;
  }
  for (int i = 0; i < LED_COUNT; i++) {
    leds[i] = CRGB(Signal, 0, 255 - Signal);
  }
  FastLED.show();
}
