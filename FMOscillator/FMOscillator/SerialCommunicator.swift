//
//  SerialCommunicator.swift
//  FMOscillator
//
//  Created by Nicholas Arner on 8/11/15.
//  Copyright (c) 2015 Nicholas Arner. All rights reserved.
//

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
    
    // MARK - ORSSerialPortDelegate
    
    
    
    func serialPortWasRemovedFromSystem(serialPort: ORSSerialPort) {
        self.serialPort = nil
    }
    
    func serialPort(serialPort: ORSSerialPort, didEncounterError error: NSError) {
        print("Serial port \(serialPort) encountered an error: \(error)")
    }
    
    func serialPortWasOpened(serialPort: ORSSerialPort) {
        let descriptorPotOne = ORSSerialPacketDescriptor(prefixString: "!pos1", suffixString: ";", userInfo: SerialPortPacketType.PotentiometerOne.rawValue)
        let descriptorPotTwo = ORSSerialPacketDescriptor(prefixString: "!pos2", suffixString: ";", userInfo: SerialPortPacketType.PotentiometerTwo.rawValue)
        let descriptorState = ORSSerialPacketDescriptor(prefixString: "!state", suffixString: ";", userInfo: SerialPortPacketType.State.rawValue)

        serialPort.startListeningForPacketsMatchingDescriptor(descriptorPotOne)
        serialPort.startListeningForPacketsMatchingDescriptor(descriptorPotTwo)
        serialPort.startListeningForPacketsMatchingDescriptor(descriptorState)
    }
    
    
    private func potentiometerFromResponsePacket(data: NSData) -> Int {
        let dataAsString = NSString(data: data, encoding: NSASCIIStringEncoding)!
        let potentiometerString = dataAsString.substringWithRange(NSRange(location: 5, length: dataAsString.length-6))
        return potentiometerString.toInt()!
    }
    
    
    private func switchStateFromResponsePacket(data: NSData) -> Bool {
        let dataAsString = NSString(data: data, encoding: NSASCIIStringEncoding)!
        
        let switchState = dataAsString.substringWithRange(NSRange(location: 6, length: dataAsString.length-7))
        return switchState.toInt()! != 0
    }
    
    
    func serialPort(serialPort: ORSSerialPort, didReceivePacket packetData: NSData, matchingDescriptor descriptor: ORSSerialPacketDescriptor) {
//        if let dataAsString = NSString(data: packetData, encoding: NSASCIIStringEncoding) {
//            let valueString = dataAsString.substringWithRange(NSRange(location: 4, length: dataAsString.length-5))
//            self.potentiometerOneValue = valueString.toInt()!
        let packetType = SerialPortPacketType(rawValue: descriptor.userInfo as! Int)!
        switch packetType {
        case .PotentiometerOne:
            self.potentiometerOneValue = self.potentiometerFromResponsePacket(packetData)
            println(self.potentiometerOneValue)
        case .PotentiometerTwo:
            self.potentiometerTwoValue = self.potentiometerFromResponsePacket(packetData)
            println(self.potentiometerTwoValue)
        case .State:
            self.switchState = self.switchStateFromResponsePacket(packetData)
            println(self.switchState)
        }
    }
    
    
    // MARK: - Properties
    
    dynamic private(set) var potentiometerOneValue: Int = 0
    dynamic private(set) var potentiometerTwoValue: Int = 0
    dynamic private(set) var switchState: Bool = true
    
    
    
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