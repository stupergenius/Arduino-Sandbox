#include <LiquidCrystal.h>
#include <avr/pgmspace.h>
#include "DigitsOfPi.h"

LiquidCrystal lcd(12, 11, 5, 4, 3, 2);

byte pi[8] = {
  B00000,
  B00000,
  B11111,
  B01010,
  B01010,
  B01010,
  B10011,
  B00000,
};

const int numRows = 2;
const int numCols = 16;

char piString[numCols] = {};
int piDigitOffset = 0;
bool bootPauseDone = false;

void setup() {
  setupLCD();
  printHeader();
  initPiString();
  printPiString();
}

void loop() {
  if (!bootPauseDone) {
    bootPauseDone = true;
    delay(2000);
  } else {
    delay(500);
  }

  printHeader();
  updatePiString();
  printPiString();
}

void setupLCD() {
  lcd.begin(numCols, numRows);
  lcd.createChar(0, pi);
  delay(100);
}

void printHeader() {
  lcd.setCursor(0, 0);
  lcd.print("Happy ");
  lcd.write(byte(0));
  lcd.print(" Day!");
}

void initPiString() {
  piString[0] = '3';
  piString[1] = '.';
  for (int i = 2; i < numCols; i++) {
    int displayValue = pgm_read_word_near(DigitsOfPi + piDigitOffset);
    piString[i] = displayValue + '0';
    piDigitOffset++;
  }
}

void updatePiString() {
  for (int i = 0; i < numCols; i++) {
    if (i == (numCols - 1)) {
      // update the last element with a new digit of pi
      int displayValue = pgm_read_word_near(DigitsOfPi + piDigitOffset);
      piString[i] = displayValue + '0';
    } else {
      // otherwise we're left shifting the other characters in the array
      piString[i] = piString[i+1];
    }
  }
  
  piDigitOffset++; piDigitOffset = piDigitOffset % numDigitsOfPi;
}

void printPiString() {
  lcd.setCursor(0, numRows - 1);
  lcd.print(piString);
}

