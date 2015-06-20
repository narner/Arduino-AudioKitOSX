   /*This Arduino sketch will read teh values of two potentiometers and a 
     toggle switch, which will be used to control the parameters of an oscillator 
     made with Audio Kit */
     
     //http://www.nickarner.com
     //http://www.audiokitio
   
  
    void setup() {
      // initialize serial communication at 9600 bits per second:
      Serial.begin(9600);
    }
    
    
    void loop() {
      // read the input for the first potentiometer
      int potentiometerOneValue = analogRead(A0);
      // Convert the analog reading (which goes from 0 - 1023) to a range between 0 and 1
      float voltageOne = potentiometerOneValue * (1.0 / 1023.0);
      Serial.println(voltageOne);
      
      // read the input for the second potentiometer
      int potentiometerTwoValue = analogRead(A1);
      // Convert the analog reading (which goes from 0 - 1023) to a range between 0 and 1
      float voltageTwo = potentiometerTwoValue * (1.0 / 1023.0);
      Serial.println(voltageTwo);
      
    }
