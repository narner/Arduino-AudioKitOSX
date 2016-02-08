//
//  SerialCommunicator.swift
//  FMOscillator
//
//  Created by Nicholas Arner on 8/11/15.

//  Based off of the `Request Response Demo` example in
//  the ORSSerialPort library from Andrew Madsen
//  https://github.com/armadsen/ORSSerialPort/tree/master/Examples/RequestResponseDemo

import Foundation

import ORSSerial

class SerialCommunicator: NSObject, ORSSerialPortDelegate {
	
	deinit {
		self.serialPort = nil
	}
	
	enum SerialPortPacketType: Int {
		
		case PotentiometerOne = 1;
		case PotentiometerTwo = 2;
		case State = 3;
	}
	
    // MARK: - Properties
    
    dynamic private(set) var potentiometerOneValue: Int = 0
    dynamic private(set) var potentiometerTwoValue: Int = 0
    dynamic private(set) var switchState: Bool = false

	// MARK - ORSSerialPortDelegate
	
	func serialPortWasRemovedFromSystem(serialPort: ORSSerialPort) {
		self.serialPort = nil
	}
	
	func serialPort(serialPort: ORSSerialPort, didEncounterError error: NSError) {
		print("Serial port \(serialPort) encountered an error: \(error)")
	}
	
    //When the serial port is opened, listen for the correct descriptors 
	func serialPortWasOpened(serialPort: ORSSerialPort) {
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
		
		serialPort.startListeningForPacketsMatchingDescriptor(descriptorPotOne)
		serialPort.startListeningForPacketsMatchingDescriptor(descriptorPotTwo)
		serialPort.startListeningForPacketsMatchingDescriptor(descriptorState)
	}
	
	private func potentiometerFromResponsePacket(data: NSData) -> Int {
		let dataAsString = NSString(data: data, encoding: NSASCIIStringEncoding)!
		let potentiometerString = dataAsString.substringWithRange(NSRange(location: 5, length: dataAsString.length-6))
		return Int(potentiometerString)!
	}
	
	private func switchStateFromResponsePacket(data: NSData) -> Bool {
		let dataAsString = NSString(data: data, encoding: NSASCIIStringEncoding)!
		let switchState = dataAsString.substringWithRange(NSRange(location: 6, length: dataAsString.length-7))
		return Int(switchState)! != 0
	}
	
    //Post a notification whenever the potentiometer values or switch state changes
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