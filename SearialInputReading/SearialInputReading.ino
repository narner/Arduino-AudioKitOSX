 /*This Arduino sketch will read the values of two potentiometers and a 
   toggle switch, which will be used to control the parameters of an oscillator 
   made with Audio Kit */
   
   //http://www.nickarner.com
   //http://www.audiokitio
 
const int  buttonPin = 2;    // the pin that the push-button is attached to

int buttonState = 0;         // current state of the push-button
int lastButtonState = 0;     // previous state of the push-button

int lastPotentiometerOneValue = 0;
int lastPotentiometerTwoValue = 0;

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

  ///Potentiometer One
  // Read the input on analog pin 0:
  int potentiometerOneValue = analogRead(A0);
  // Convert the analog reading (which goes from 0 - 1023) to a voltage value between (0 - 1V):
  int potOneVoltageValue = potentiometerOneValue * (1.0 / 1023.0);

  Serial.print("!pot1");
  Serial.print(potOneVoltageValue);
  Serial.print(";");


  ///Potentiometer Two
  int potentiometerTwoValue = analogRead(A1);
  int potTwoVoltageValue = potentiometerTwoValue * (1.0 / 1023.0);

  Serial.print("!pot2");
  Serial.print(potTwoVoltageValue);
  Serial.print(";");
}


void readAndSendButtonDataIfChanged(void) {
  // Read the pushbutton input pin:
  buttonState = digitalRead(buttonPin);

  // Compare the buttonState to its previous state
  if (buttonState != lastButtonState) {
  // If the state has changed, increment the counter
    if (buttonState == HIGH) {
    // If the current state is HIGH then the button went from off to on:
    Serial.print("state");
    Serial.print("1");
    Serial.print(";");
  } else {
  // If the current state is LOW, then the button went from on to off 
  Serial.print("state");
  Serial.print("0");
  Serial.print(";");
  }
  // Delay a little bit to avoid bouncing
  delay(50);  
  }
  //Save the current state as the last state, for next time through the loop 
  lastButtonState = buttonState;
}

