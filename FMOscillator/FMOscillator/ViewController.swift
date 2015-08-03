//
//  ViewController.swift
//  FMOscillator
//
//  Created by Nicholas Arner on 6/20/15.
//  Copyright (c) 2015 Nicholas Arner. All rights reserved.
//

import Cocoa
import ORSSerial 

class ViewController: NSViewController, ORSSerialPortDelegate {
    
    let serialPortManager = ORSSerialPortManager.sharedSerialPortManager()

    var serialPort: ORSSerialPort? {
        didSet {
            oldValue?.close()
            oldValue?.delegate = nil
            serialPort?.delegate = self
        }
    }
    

    let instrument = AKInstrument()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        self.serialPort = ORSSerialPort(path: "/dev/cu.usbmodem1421")
        serialPort?.baudRate = 4800
        serialPort?.open()
        
        /*Code below will be used for some sort of UI that will allow 
        the user to select what serial port they want to use as input.
        This should be added after we've establsihed proof of concept 
        communication between the Arduino and the app.
        
        let availablePorts = ORSSerialPortManager.sharedSerialPortManager().availablePorts as! [ORSSerialPort]
        if availablePorts.count == 0 {
            println("No connected serial ports found. Please connect your Arduino or turn on Bluetooth..\n")
            exit(EXIT_SUCCESS)
        }
        
        println("\nPlease select a serial port: \n")
        let availablePorts = ORSSerialPortManager.sharedSerialPortManager().availablePorts as! [ORSSerialPort]
        var i = 0
        for port in availablePorts {
            println("\(i++). \(port.name)")
        }

        */
        

        
        //AK
        let oscillator = AKOscillator()
        instrument.connect(oscillator)
        instrument.connect(AKAudioOutput(audioSource: oscillator))
        
        //AK
        AKOrchestra.addInstrument(instrument)
        AKOrchestra.start()
    }
    
    
    @IBAction func startSound(sender: NSButton) {
        if !(sender.title == "Stop") {
            instrument.play()
            sender.title = "Stop"
        } else {
            instrument.stop()
            sender.title = "Play Sound"
        }
    }
    
    
    
    // MARK: - ORSSerialPortDelegate
    
    func serialPortWasOpened(serialPort: ORSSerialPort) {
        print("SerialPort \(serialPort) was opened")
    }
    
    func serialPort(serialPort: ORSSerialPort, didReceiveData data: NSData) {
        print("we received some data")
    }
    
    func serialPortWasClosed(serialPort: ORSSerialPort) {
        print("SerialPort \(serialPort) was closed")
    }
    
    func serialPortWasRemovedFromSystem(serialPort: ORSSerialPort) {
        self.serialPort = nil
        print("SerialPort \(serialPort) was removed from system")
    }
    
    func serialPort(serialPort: ORSSerialPort, didEncounterError error: NSError) {
        print("SerialPort \(serialPort) encountered an error: \(error)")
    }
    
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        serialPort?.close()
    }
}
