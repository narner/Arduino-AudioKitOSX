//
//  SerialCommunicator.swift
//  FMOscillator
//
//  Created by Nicholas Arner on 8/11/15.

//  Based off of the `Request Response Demo` example in
//  the ORSSerialPort library from Andrew Madsen
//  (https://github.com/armadsen/ORSSerialPort/tree/master/Examples/RequestResponseDemo)

import Foundation

import ORSSerial

class SerialCommunicator: NSObject, ORSSerialPortDelegate {
	
	deinit {
		self.serialPort = nil
	}
	
	enum SerialPortPacketType: Int {
		
		case potentiometerOne = 1;
		case potentiometerTwo = 2;
		case state = 3;
	}
	
    // MARK: - Properties
    
    dynamic fileprivate(set) var potentiometerOneValue: Int = 0
    dynamic fileprivate(set) var potentiometerTwoValue: Int = 0
    dynamic fileprivate(set) var switchState: Bool = false

	// MARK - ORSSerialPortDelegate
	
	func serialPortWasRemoved(fromSystem serialPort: ORSSerialPort) {
		self.serialPort = nil
	}
	
	func serialPort(_ serialPort: ORSSerialPort, didEncounterError error: Error) {
		print("Serial port \(serialPort) encountered an error: \(error)")
	}
	
    //When the serial port is opened, listen for the correct descriptors 
	func serialPortWasOpened(_ serialPort: ORSSerialPort) {
		let descriptorPotOne = ORSSerialPacketDescriptor(prefixString: "!pos1",
			suffixString: ";",
			maximumPacketLength:9,
			userInfo: SerialPortPacketType.potentiometerOne.rawValue)
		let descriptorPotTwo = ORSSerialPacketDescriptor(prefixString: "!pos2",
			suffixString: ";",
			maximumPacketLength:9,
			userInfo: SerialPortPacketType.potentiometerTwo.rawValue)
		let descriptorState = ORSSerialPacketDescriptor(prefixString: "!state",
			suffixString: ";",
			maximumPacketLength:9,
			userInfo: SerialPortPacketType.state.rawValue)
		
		serialPort.startListeningForPackets(matching: descriptorPotOne)
		serialPort.startListeningForPackets(matching: descriptorPotTwo)
		serialPort.startListeningForPackets(matching: descriptorState)
	}
	
	fileprivate func potentiometerFromResponsePacket(_ data: Data) -> Int {
		let dataAsString = NSString(data: data, encoding: String.Encoding.ascii.rawValue)!
		let potentiometerString = dataAsString.substring(with: NSRange(location: 5, length: dataAsString.length-6))
		return Int(potentiometerString)!
	}
	
	fileprivate func switchStateFromResponsePacket(_ data: Data) -> Bool {
		let dataAsString = NSString(data: data, encoding: String.Encoding.ascii.rawValue)!
		let switchState = dataAsString.substring(with: NSRange(location: 6, length: dataAsString.length-7))
		return Int(switchState)! != 0
	}
	
    //Post a notification whenever the potentiometer values or switch state changes
	func serialPort(_ serialPort: ORSSerialPort, didReceivePacket packetData: Data, matching descriptor: ORSSerialPacketDescriptor) {
		let packetType = SerialPortPacketType(rawValue: descriptor.userInfo as! Int)!
		switch packetType {
		case .potentiometerOne:
			self.potentiometerOneValue = self.potentiometerFromResponsePacket(packetData)
            NotificationCenter.default.post(name: Notification.Name(rawValue: "PotentiometerOneChanged"), object: self.potentiometerOneValue)
		case .potentiometerTwo:
			self.potentiometerTwoValue = self.potentiometerFromResponsePacket(packetData)
            NotificationCenter.default.post(name: Notification.Name(rawValue: "PotentiometerTwoChanged"), object: self.potentiometerTwoValue)
		case .state:
			self.switchState = self.switchStateFromResponsePacket(packetData)
            NotificationCenter.default.post(name: Notification.Name(rawValue: "SwitchStateChanged"), object: self.switchState)
		}
	}
	
    
	dynamic var serialPort: ORSSerialPort? {
		willSet {
			if let port = serialPort {
				port.close()
				port.delegate = nil
			}
		}
		didSet {
			if let port = serialPort {
				port.baudRate = 57600
				port.delegate = self
				port.open()
			}
		}
	}
}
