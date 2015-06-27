 /*This Arduino sketch will read teh values of two potentiometers and a 
   toggle switch, which will be used to control the parameters of an oscillator 
   made with Audio Kit */
   
   //http://www.nickarner.com
   //http://www.audiokitio
 

const int  buttonPin = 2;    // the pin that the pushbutton is attached to

int buttonState = 0;         // current state of the button
int lastButtonState = 0;     // previous state of the button


void setup() {
  // initialize serial communication at 9600 bits per second:
  Serial.begin(9600);
    
  // initialize the button pin as a input:
  pinMode(buttonPin, INPUT);
}
  
  
void loop() {
    
  // read the pushbutton input pin:
  buttonState = digitalRead(buttonPin);

  // read the input for the first potentiometer
  int potentiometerOneValue = analogRead(A0);
  // Convert the analog reading (which goes from 0 - 1023) to a range between 0 and 1
  float voltageOne = potentiometerOneValue * (1.0 / 1023.0);
//  Serial.println(voltageOne);
    
  // read the input for the second potentiometer
  int potentiometerTwoValue = analogRead(A1);
  // Convert the analog reading (which goes from 0 - 1023) to a range between 0 and 1
  float voltageTwo = potentiometerTwoValue * (1.0 / 1023.0);
//  Serial.println(voltageTwo);
    
  // compare the buttonState to its previous state
  if (buttonState != lastButtonState) {
  // if the state has changed, increment the counter
    if (buttonState == HIGH) {
    // if the current state is HIGH then the button
    // wend from off to on:
    Serial.println("on");
  }
  else {
    // if the current state is LOW then the button
    // wend from on to off:
    Serial.println("off");
  }
  // Delay a little bit to avoid bouncing
  delay(50);  
}
// save the current state as the last state,
  //for next time through the loop
lastButtonState = buttonState;

}
