#define WAITING    0
#define RECORDING  1
#define REPLAYING  2
#define HOLDING    HIGH
#define RELEASED   LOW

// constants won't change. They're used here to 
// set pin numbers:
const int buttonPin = 8;     // the number of the pushbutton pin
const int ledPin =  13;      // the number of the LED pin
const int debounceDelay = 50;    // the debounce time; increase if the output flickers
const int stopRecordingDelay = 3000;

// Variables will change:
int ledState = HIGH;         // the current state of the output pin
int buttonState;             // the current reading from the input pin
int lastButtonState = RELEASED;   // the previous reading from the input pin
long lastDebounceTime = 0;  // the last time the output pin was toggled

// variables for recording inputs
int currentState = WAITING;
long startedTime = 0;
long currentWaitDelta = 0;
int currentInterval = 0;
long timingData[] = {0,0,0,0,0};
int numTimingPoints = 5;

//----------------------------------------------
// Setup
//----------------------------------------------

void setup() {
  Serial.begin(9600);
  pinMode(buttonPin, INPUT);
  pinMode(ledPin, OUTPUT);
}

//----------------------------------------------
// Run Loop
//----------------------------------------------

void loop() {
  // read the state of the switch into a local variable:
  int reading = digitalRead(buttonPin);
  
  // If the switch changed, due to noise or pressing, we reset the timestamp
  if (reading != lastButtonState) {
    lastDebounceTime = millis();
  }
  
  // button has cleared bounce threshold, update the reading state
  if (buttonState != reading && (millis() - lastDebounceTime) > debounceDelay) {
    buttonState = reading;
    // update the led
    digitalWrite(ledPin, buttonState);
    
    if (currentState == WAITING) {
      // move directly from waiting into recording mode
      startRecording();
    } else if (currentState == RECORDING) {
      Serial.println("recording state moving to a new interval");
      timingData[currentInterval] = millis() - startedTime;
      startedTime = millis();
      
      // we've exhausted our timing storage, move into replaying mode and wait for another press
      currentInterval++;
      if (currentInterval == numTimingPoints) {
        startReplaying();
        exitRecording();
      }
    } else if (currentState == REPLAYING) {
      // a single button press brings us out of replay mode
      startRecording();
      exitReplaying();
    }
  }
  
  // save the reading. next time through the loop it'll be the lastButtonState
  lastButtonState = reading;
  
  // state code
  if (currentState == RECORDING) {
    updateRecording();
  } else if (currentState == REPLAYING) {
    updateReplaying();
  }
}

//----------------------------------------------
// Recording State
//----------------------------------------------

void startRecording() {
  Serial.println("starting recording");
  currentState = RECORDING;
  currentInterval = 0;
  for (int i=0; i<numTimingPoints; i++) {
    timingData[i] = 0;
  }
  digitalWrite(ledPin, HIGH);
  startedTime = millis();
}

void updateRecording() {
  // recording is event based, we dont need to do anything here
}

void exitRecording() {
  Serial.println("exiting recording");
}

//----------------------------------------------
// Replaying State
//----------------------------------------------

void startReplaying() {
  Serial.println("starting replaying with time deltas:");
  for (int i=0; i<numTimingPoints; i++) {
    if (i > 0) Serial.print(", ");
    Serial.print(timingData[i]);
  }
  Serial.println("");
  
  currentState = REPLAYING;
  currentInterval = 0;
  startedTime = millis();
  currentWaitDelta = 250; // wait some before starting the timingData replay
  digitalWrite(ledPin, LOW);
}

void updateReplaying() {
  long delta = millis() - startedTime;
  if (delta >= currentWaitDelta) {
    startedTime = millis();
    currentInterval = (currentInterval + 1) % (numTimingPoints + 1);
    
    if (currentInterval == 0) {
      currentWaitDelta = 250; // wait some after finishing the timingData replay
    } else {
      currentWaitDelta = timingData[currentInterval - 1];
    }
    
    // update the state of the led pin
    digitalWrite(ledPin, (currentInterval % 2 == 0) ? LOW : HIGH);
  }
}

void exitReplaying() {
  Serial.println("exiting replaying");
}

