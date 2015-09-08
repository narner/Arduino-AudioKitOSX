 /*This Arduino sketch will read teh values of two potentiometers and a 
   toggle switch, which will be used to control the parameters of an oscillator 
   made with Audio Kit */
   
   //http://www.nickarner.com
   //http://www.audiokitio
 

const int  switchPin = 2;    // the pin that the push-button is attached to

int switchState = 0;         // current state of the push-button
int lastSwitchState = 0;     // previous state of the push-button

int lastPotentiometerOneValue = 0;
int lastPotentiometerTwoValue = 0;

void setup() {
  // initialize serial communication at 57600 bits per second:
  Serial.begin(57600);
    
  // initialize the switch pin as a input:
  pinMode(switchPin, INPUT);
 }
 
void loop() {
  delay(10);
  readAndSendPotentiometerDataIfChanged();
  readAndSendSwitchDataIfChanged();
}
  
void readAndSendPotentiometerDataIfChanged(void) {

  //Potentiometer One
  int newPotentiometerOneValue = analogRead(A0) / 10.2;   
  if (newPotentiometerOneValue != lastPotentiometerOneValue) {
      Serial.print("!pos1");
      Serial.print(newPotentiometerOneValue);
      Serial.print(";");
      lastPotentiometerOneValue = newPotentiometerOneValue;
  }

  //Potentiometer Two
  int newPotentiometerTwoValue = analogRead(A1) / 10.2; 
  if (newPotentiometerTwoValue != lastPotentiometerTwoValue) {
      Serial.print("!pos2");
      Serial.print(newPotentiometerTwoValue);
      Serial.print(";");
      lastPotentiometerTwoValue = newPotentiometerTwoValue;
  }
}

void readAndSendSwitchDataIfChanged(void) {
  // read the switch input pin:
  switchState = digitalRead(switchPin);

  // Read the switch input pin:
  if (switchState != lastSwitchState) {
  // If the state has changed, increment the counter
    if (switchState == HIGH) {
    // If the current state is HIGH then the switch went from off to on:
        Serial.print("!state");
        Serial.print("1");
        Serial.print(";");
  } else {
  // If the current state is LOW, then the switch went from on to off 
    Serial.print("!state");
    Serial.print("0");
    Serial.print(";");
  }
  // Delay a little bit to avoid bouncing
  delay(50);  
  }
  //Save the current state as the last state, for next time through the loop 
  lastSwitchState = switchState;
}

