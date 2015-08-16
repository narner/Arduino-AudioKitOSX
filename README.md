============================

**Overview**
This project demonstrates the control of an oscillator made with AudioKit (audiokit.io) by physical controls connected with an Arduino. 

The schematic below shows the two potentiometers and SPDT switch used to control the OSX app:

![Alt Text](https://github.com/narner/Arduino-AudioKitOSX/raw/master/InputCircuit.png)

The Arduino sketch is found in the `SerialInputReading` folder. The data from the potentiometers and the SPDT switch is read by the `readAndSendPotentiometerDataIfChanged` method. This method is called in the `void loop()`, so that the method is exectued as long as the Arduino sketch is running. 

First, a variable is created that reads the the input value for the analog pin that the potentiometer is connected to. The first potentiometer's data is read on Analog Input 0 (A0), and the second potentiometer's data is read on Analog Input 1 (A1). 

```
///Potentiometer One
// Read the input on analog pin 0:
int potentiometerOneValue = analogRead(A0);
```

Then, the raw value from the potentiometer (the Arduino reads analog input as values to between 0 and 1023) to be a voltage value between 0 and 1:

`float potOneVoltageValue = potentiometerOneValue * (1.0 / 1023.0);`

Next, the value of the potentiometer is printed through the serial output. The format below is used so that the `SerialCommunicator` can correctly parse the values from the serial bus. 

```
Serial.print("!pot1");
Serial.print(potOneVoltageValue);
Serial.print(";");
```

The `readAndSendButtonDataIfChanged` method reads the state of the SPDT switch, which will be used to switch the instrument on and off, and is also called in the `void loop()`.  

The pin the button is attached is digital pin 2:

`const int  buttonPin = 2;` 




**Attribution**
The sound synthesis is implemented through <a href="https://github.com/audiokit/AudioKit">AudioKit</a>, an open-source audio analysis, synthesis, and processing library for iOS and OS X. This project uses AudioKit version X.X.

The OS X app makes use of the <a href="https://github.com/armadsen/ORSSerialPort">ORSSerialPort library</a>.

Thanks to <a href="http://blog.andrewmadsen.com/">Andrew Madsen</a> for answering questions regarding the library. 


**Contact**

Email: nicholasarner (at) gmail.com

Website: www.nickarner.com

Twitter: @nickarner
