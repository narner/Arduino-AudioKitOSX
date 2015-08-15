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

  //Potentiometer One
  // read the input on analog pin 0:
  int potentiometerOneValue = analogRead(A0);
  // Convert the analog reading (which goes from 0 - 1023) to a voltage (0 - 5V):
  float potOneVoltageValue = potentiometerOneValue * (1.0 / 1023.0);

  Serial.print("!pot1");
  Serial.print(potOneVoltageValue);
  Serial.print(";");


  //Potentiometer Two
  // read the input on analog pin 1:
  int potentiometerTwoValue = analogRead(A1);
  // Convert the analog reading (which goes from 0 - 1023) to a voltage (0 - 5V):
  float potTwoVoltageValue = potentiometerTwoValue * (1.0 / 1023.0);

  Serial.print("!pot2");
  Serial.print(potTwoVoltageValue);
  Serial.print(";");
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
    Serial.print("state");
    Serial.print("1");
    Serial.print(";");
  } else {
  // if the current state is LOW then the button
  // went from on to off:
  Serial.print("state");
  Serial.print("0");
  Serial.print(";");
  }
  // Delay a little bit to avoid bouncing
  delay(50);  
  }
  // save the current state as the last state,
  //for next time through the loop
  lastButtonState = buttonState;
}

