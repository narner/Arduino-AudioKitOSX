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
    
    // MARK - ORSSerialPortDelegate
    
    func serialPortWasRemovedFromSystem(serialPort: ORSSerialPort) {
        self.serialPort = nil
    }
    
    func serialPort(serialPort: ORSSerialPort, didEncounterError error: NSError) {
        println("Serial port \(serialPort) encountered an error: \(error)")
    }
    
    func serialPortWasOpened(serialPort: ORSSerialPort) {
        let descriptor = ORSSerialPacketDescriptor(prefixString: "!pos", suffixString: ";", userInfo: nil)
        serialPort.startListeningForPacketsMatchingDescriptor(descriptor)
    }
    
    func serialPort(serialPort: ORSSerialPort, didReceivePacket packetData: NSData, matchingDescriptor descriptor: ORSSerialPacketDescriptor) {
        if let dataAsString = NSString(data: packetData, encoding: NSASCIIStringEncoding) {
            let valueString = dataAsString.substringWithRange(NSRange(location: 4, length: dataAsString.length-5))
            self.potentiometerOneValue = valueString.toInt()!
            //The above would process one sent value...what about multiple values?
        }
    }
    
    // MARK: - Properties
    
    //To-Do - make these public so the ViewController can access them?
    dynamic private(set) var potentiometerOneValue: Int = 0
    dynamic private(set) var potentiometerTwoValue: Int = 0
    //To-Do: add a property for the push-button switch
    
    
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