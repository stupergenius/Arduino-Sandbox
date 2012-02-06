#include <avr/pgmspace.h>
#include "DigitsOfPi.h"

// encode the on/off state of the LED segments for the characters 
// '0' to '9' into the bits of the bytes
const byte numDef[10] = {126, 48, 109, 121, 51, 91, 95, 112, 127, 115};

// store a table of pin numbers
int numSegs = 7;
const int segPins[7] = {
  8, // -> Anode A, bit 0 in the definitions
  7, // -> Anode B, bit 1
  6, // -> Anode C, bit 2
  5, // -> Anode D, bit 3
  4, // -> Anode E, bit 4
  2, // -> Anode F, bit 5
  3  // -> Anode G, bit 6
};
const int decimalPin = 9;

void setup() {
//  Serial.begin(9600);
  
  for (int i=0; i<numSegs; i++) {
    pinMode(segPins[i], OUTPUT);
  }
  pinMode(decimalPin, OUTPUT);
}

int tickValue = 0;
boolean threeDone = false;
boolean dotDone = false;

void loop() {
  if (threeDone && dotDone) {
    char displayValue = pgm_read_word_near(DigitsOfPi + tickValue);
    int digitBits = numDef[displayValue];
    setSegments(digitBits);
    
    tickValue++; tickValue = tickValue % numDigitsOfPi;
    delay(500);
  } else {
    if (!threeDone) {
      threeDone = true;
      setSegments(numDef[3]);
      delay(500);
      setSegments(0); // turn all off
    } else {
      dotDone = true;
      digitalWrite(decimalPin, HIGH);
      delay(500);
      digitalWrite(decimalPin, LOW);
    }
  }
}

void setSegments(byte segments) {
  // for each of the segments of the LED
  for (int s = 0; s < numSegs; s++) {
    int bitVal = bitRead(segments, s); // grab the bit 
    digitalWrite(segPins[numSegs - 1 - s], bitVal); // set the segment
  }
}
