 /*This Arduino sketch will read teh values of two potentiometers and a 
   toggle switch, which will be used to control the parameters of an oscillator 
   made with Audio Kit */
   
   //http://www.nickarner.com
   //http://www.audiokitio
 

const int  buttonPin = 2;    // the pin that the push-button is attached to

int buttonState = 0;         // current state of the push-button
int lastButtonState = 0;     // previous state of the push-button

float lastPotentiometerOneValue = 0;
float lastPotentiometerTwoValue = 0;

void setup() {
  // initialize serial communication at 57600 bits per second:
  Serial.begin(57600);
    
  // initialize the button pin as a input:
  pinMode(buttonPin, INPUT);
 }
 
void loop() {
    
  readAndSendPotentiometerDataIfChanged();
  readAndSendButtonDataIfChanged();
}

void readAndSendPotentiometerDataIfChanged(void) {

  //Potentiometer One
  float newPotentiometerOneValue = analogRead(A0) 
  float newPotentiometerOneValue = newPotentiometerOneValue * (1.0 / 1023.0);
  if (newPotentiometerOneValue == lastPotentiometerOneValue) return;

  Serial.print("!pos");
  Serial.print(newPotentiometerOneValue);
  Serial.print(";");
  lastPotentiometerOneValue = newPotentiometerOneValue;

  //Potentiometer Two
  float newPotentiometerTwoValue = analogRead(A1) 
  float newPotentiometerTwoValue = newPotentiometerOneValue * (1.0 / 1023.0);
  if (newPotentiometerTwoValue == lastPotentiometerTwoValue) return;

  Serial.print("!pos");
  Serial.print(newPotentiometerTwoValue);
  Serial.print(";");
  lastPotentiometerTwoValue = newPotentiometerTwoValue;
}


void readAndSendButtonDataIfChanged(void) {
  // read the pushbutton input pin:
  buttonState = digitalRead(buttonPin);

  // compare the buttonState to its previous state
  if (buttonState != lastButtonState) {
  // if the state has changed, increment the counter
    if (buttonState == HIGH) {
    // if the current state is HIGH then the button
    // went from off to on:
  Serial.print("!pos");
  Serial.print("on");
  Serial.print(";");
  } else {
  // if the current state is LOW then the button
  // went from on to off:
  Serial.print("!pos");
  Serial.print("off");
  Serial.print(";");
  }
  // Delay a little bit to avoid bouncing
  delay(50);  
  }
  // save the current state as the last state,
  //for next time through the loop
  lastButtonState = buttonState;
}

