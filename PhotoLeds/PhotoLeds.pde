// the cell and 10K pulldown are connected to a0
int photocellPin = 0;
// the analog reading from the analog resistor divider
int photocellReading;
// Tweak these two values for your lighting. The AnalogReadSerial example sketch is good for reading CDS values.
int photoLow = 40;
int photoHigh = 180;
int ledPins[] = {3,5,6};
int numLeds = 3;
int maxIntensity = 0;

void setup(void) {
  //Serial.begin(9600);
  
  // setup each of our leds at output and keep maxIntensity accurate
  for (int i=0; i<numLeds; i++) {
    pinMode(ledPins[i], OUTPUT);
    maxIntensity += 255;
  }
}

void loop(void) {
  photocellReading = analogRead(photocellPin);
  int ledIntensity = map(photocellReading, photoLow, photoHigh, maxIntensity, 0);
  ledIntensity = min(maxIntensity, max(0, ledIntensity)); // clamp the intensity to supported values
  Serial.println(ledIntensity);
  
  // There must be [0, numLeds-1] on (HIGH) and at most 1 partially on. The rest are off.
  int numOn = floor(ledIntensity / 255);
  int ledIndex;
  for (ledIndex=0; ledIndex<numOn; ledIndex++) {
    analogWrite(ledPins[ledIndex], 255);
  }
  if (ledIndex < numLeds - 1) {
    int remainingIntensity = ledIntensity % 255;
    analogWrite(ledPins[ledIndex], remainingIntensity);
    ledIndex++;
    // turn off the leds that shouldnt be on at all
    for (ledIndex; ledIndex<numLeds; ledIndex++) {
      analogWrite(ledPins[ledIndex], 0);
    }
  }
  
  delay(100);
}
