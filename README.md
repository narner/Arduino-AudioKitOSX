============================

**Overview**
This project demonstrates how an OSX oscillator app created with <a href="https://github.com/audiokit/AudioKit">AudioKit</a> can be controlled by an Arduino via serial communication. 

**Arduino Sketch**
The schematic below shows the two potentiometers and SPDT switch used to control the OSX app:

![Alt Text](https://github.com/narner/Arduino-AudioKitOSX/raw/master/Schematic Files/InputCircuit.png)

The assembled circuit:

![Alt Text](https://github.com/narner/Arduino-AudioKitOSX/raw/master/Schematic Files/AssembledCircuit.png)

The Arduino sketch is found in the `SerialInputReading` folder. The data from the potentiometers and the SPDT switch is read by the `readAndSendPotentiometerDataIfChanged` method. This method is called in the `void loop()`, so that the method is exectued as long as the Arduino sketch is running. 

First, a variable is created that reads the the input value for the analog pin that the potentiometer is connected to. The first potentiometer's data is read on Analog Input 0 (A0), and the second potentiometer's data is read on Analog Input 1 (A1). 

```
///Potentiometer One
// Read the input on analog pin 0:
int potentiometerOneValue = analogRead(A0);
```

Then, the raw value from the potentiometer (the Arduino reads analog input as values to between 0 and 1023) to be a voltage value between 0 and 1:

`int potOneVoltageValue = potentiometerOneValue * (1.0 / 1023.0);`

Next, the value of the potentiometer is printed through the serial output. The format below is used so that the `SerialCommunicator` can correctly parse the values from the serial bus. 

```
Serial.print("!pot1");
Serial.print(potOneVoltageValue);
Serial.print(";");
```

The `readAndSendSwitchDataIfChanged` method reads the state of the SPDT switch, which will be used to switch the instrument on and off, and is also called in the `void loop()`.  

The pin the switch is attached is digital pin 2: `const int switchPin = 2;` 

The switch's state (whether it's `HIGH` or `LOW`) is determined by using the `digitalRead` function, which, according to the
<a href="https://www.arduino.cc/en/Reference/DigitalRead">Arduino documentation</a>, "Reads the value from a specified pin, either `HIGH` or `LOW`". 

A series of checks are then performed. If the state of `switchState` is different from the value of `lastSwitchState`, then we'll check the current state of `switchState`. If the current state is `HIGH`, then the switch went from "Off" to "On". The following output would then be written to the serial log:

```
Serial.print("!state");
Serial.print("1");
Serial.print(";");
```

Otherwise, the switch state is `LOW`, and the switch went from "On" to "Off". The following output would then be written to the serial log:

```
Serial.print("!state");
Serial.print("0");
Serial.print(";");
```

A delay of 50 milliseconds is added to prevent bouncing. Effectively we're checking the state of the input twice in a short time to make sure the button is "definitely pressed" (<a href="https://www.arduino.cc/en/Tutorial/Debounce">Arduino documentation</a>).

Finally, at the end of the method, we save the `lastSwitchState` value as that of the current `switchState`. 

**Xcode Project**

There are two classes in the Xcode project, the `Serial Communicator`, and the `View Controller`. The `View Controller` is responsible both for opening the serial port so communication can occur: 

```
let serialPort = ORSSerialPort(path: "/dev/tty.usbmodem1411")
serialCommunicator.serialPort = serialPort
```

and, for creating the oscillator. An instrument and note are created as global variables:

```
let instrument = AKFMOscillatorInstrument()
let note = AKFMOscillatorNote()
```

The `instrument` is an instance of `AKFMOscillatorInstrument`. This instrument has five properties that can be modified:

* frequency
* carrierMultiplier
* modulationMultiplier
* modulationIndex
* amplitude

For this project though, we're just going to control the `frequency` and `modulation index` properties. Inside our `viewDidLoad` method, we add the instrument to the orchestra and then start it:

```
AKOrchestra.addInstrument(instrument)
AKOrchestra.start()
```

That's all that's needed to set up a simple oscillator in AudioKit!

The `Serial Communicator` calss conforms to the `ORSSerialPortDelegate`. When `serialPortWasOpened` is called, three instances of`ORSSerialPacketDescriptor` are created: one descriptor for each potentiometer, and one descriptor for the switch state. These descriptors specify that we should be listening for a packet that starts with the string values we logged in our Arduino sketch:

```
let descriptorPotOne = ORSSerialPacketDescriptor(prefixString: "!pos1",
	suffixString: ";",
maximumPacketLength:9,
	userInfo: SerialPortPacketType.PotentiometerOne.rawValue)
let descriptorPotTwo = ORSSerialPacketDescriptor(prefixString: "!pos2",
	suffixString: ";",
	maximumPacketLength:9,
	userInfo: SerialPortPacketType.PotentiometerTwo.rawValue)
let descriptorState = ORSSerialPacketDescriptor(prefixString: "!state",
	suffixString: ";",
	maximumPacketLength:9,
  userInfo: SerialPortPacketType.State.rawValue)
```
The app then begins "listening" for each packets that match the correct description:
```
serialPort.startListeningForPacketsMatchingDescriptor(descriptorPotOne)
serialPort.startListeningForPacketsMatchingDescriptor(descriptorPotTwo)
serialPort.startListeningForPacketsMatchingDescriptor(descriptorState)
```

The `didReceivePacket` delegate method posts a notification whenever a new potentiometer value or switch-state is detected: 

```
	func serialPort(serialPort: ORSSerialPort, didReceivePacket packetData: NSData, matchingDescriptor descriptor: ORSSerialPacketDescriptor) {
		let packetType = SerialPortPacketType(rawValue: descriptor.userInfo as! Int)!
		switch packetType {
		case .PotentiometerOne:
			self.potentiometerOneValue = self.potentiometerFromResponsePacket(packetData)
            NSNotificationCenter.defaultCenter().postNotificationName("PotentiometerOneChanged", object: self.potentiometerOneValue)
		case .PotentiometerTwo:
			self.potentiometerTwoValue = self.potentiometerFromResponsePacket(packetData)
            NSNotificationCenter.defaultCenter().postNotificationName("PotentiometerTwoChanged", object: self.potentiometerTwoValue)
		case .State:
			self.switchState = self.switchStateFromResponsePacket(packetData)
            NSNotificationCenter.defaultCenter().postNotificationName("SwitchStateChanged", object: self.switchState)
		}
	}
```

Inside of our `ViewController`'s `viewDidLoad` method, observers for these notifications are added. Whenever a notification is received, it means that our app has received either a new potentiometer value or swtich state from our Arduino sketch:

```
NSNotificationCenter.defaultCenter().addObserver(self, selector: "potOneValueChanged:", name:"PotentiometerOneChanged", object: nil)
NSNotificationCenter.defaultCenter().addObserver(self, selector: "potTwoValueChanged:", name:"PotentiometerTwoChanged", object: nil)
NSNotificationCenter.defaultCenter().addObserver(self, selector: "switchStateChanged:", name:"SwitchStateChanged", object: nil)
```

Whenever a notification is received for a potentiometer value change, one of the two methods below are called: 

```
func potOneValueChanged(notification: NSNotification){
  self.frequencyLabel.property = note.frequency
  note.frequency.setValue(Float(serialCommunicator.potentiometerOneValue * 4), afterDelay: Float(0))
}
 
func potTwoValueChanged(notification: NSNotification){
  self.modulationIndexLabel.property = note.modulationIndex
  note.modulationIndex.setValue(Float(serialCommunicator.potentiometerTwoValue / 4), afterDelay: Float(0))
}
```

Those methods set the value of the oscillator's frequency and modulation parameters, as well as display the values in two labels in the user-interface. 

If a notification is received that the switch-state has changed, the method below is called:

```
func switchStateChanged(notification: NSNotification){
  if serialCommunicator.switchState == true {
  instrument.playNote(note)
  self.statusLabel.stringValue = "Stop"
} else {
  instrument.stop()
  self.statusLabel.stringValue = "Play Sound"
  }
}
```

If the switch is in an "On" state, then the oscillator's note is played, and text is updated in another label. If the switch is in an "Off" state, then the note is stopped, and the label is updated appropriately. 

**Attribution**
The sound synthesis is implemented through <a href="http://audiokit.io">AudioKit</a>, an open-source audio analysis, synthesis, and processing library for iOS and OS X. This project uses AudioKit's <a href="https://github.com/audiokit/AudioKit/tree/develop">develop branch</a>. 

The OS X app makes use of the <a href="https://github.com/armadsen/ORSSerialPort">ORSSerialPort library</a>.

Thanks to <a href="http://blog.andrewmadsen.com/">Andrew Madsen</a> for answering questions regarding the library. 


**Contact**

Email: nicholasarner (at) gmail.com

Website: www.nickarner.com

Twitter: @nickarner
