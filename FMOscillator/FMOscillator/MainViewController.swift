//
//  MainViewController.swift
//  FMOscillator
//
//  Created by Nicholas Arner on 6/20/15.
//  Copyright (c) 2015 Nicholas Arner. All rights reserved.
//

import Cocoa
import ORSSerial


class ViewController: NSViewController {
    
    let serialPortManager = ORSSerialPortManager.sharedSerialPortManager()
    let serialCommunicator = SerialCommunicator()
    
    @IBOutlet var statusLabel: NSTextField!
    @IBOutlet var frequencyLabel: AKPropertyLabel!
    @IBOutlet var modulationIndexLabel: AKPropertyLabel!
    
    let instrument = AKFMOscillatorInstrument()
    let note = AKFMOscillatorNote()


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Code below will be used for some sort of UI that will allow
        //the user to select what serial port they want to use as input.
        //This should be added after we've establsihed proof of concept
        //communication between the Arduino and the app.
        
        let availablePorts = ORSSerialPortManager.sharedSerialPortManager().availablePorts as! [ORSSerialPort]
        if availablePorts.count == 0 {
            println("No connected serial ports found. Please connect your Arduino or turn on Bluetooth..\n")
            exit(EXIT_SUCCESS)
        }
        
        let serialPort = ORSSerialPort(path: "/dev/tty.usbmodem1411")
        serialCommunicator.serialPort = serialPort
        
        
        //        println("\nPlease select a serial port: \n")
        //        let availablePorts = ORSSerialPortManager.sharedSerialPortManager().availablePorts as! [ORSSerialPort]
        //        var i = 0
        //        for port in availablePorts {
        //            println("\(i++). \(port.name)")
        //        }
        
        AKOrchestra.addInstrument(instrument)
        AKOrchestra.start()
        
        
        //Receive notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "potOneValueChanged:", name:"PotentiometerOneChanged", object: nil)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "potTwoValueChanged:", name:"PotentiometerTwoChanged", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "switchStateChanged:", name:"SwitchStateChanged", object: nil)
    }
    
    func potOneValueChanged(notification: NSNotification){
        self.frequencyLabel.property = note.frequency
        note.frequency.setValue(Float(serialCommunicator.potentiometerOneValue * 4), afterDelay: Float(0))
    }
    
    func potTwoValueChanged(notification: NSNotification){
        self.modulationIndexLabel.property = note.modulationIndex
        note.modulationIndex.setValue(Float(serialCommunicator.potentiometerTwoValue / 4), afterDelay: Float(0))
    }
    
    func switchStateChanged(notification: NSNotification){
        println(serialCommunicator.switchState)
        
        if serialCommunicator.switchState == true {
            instrument.playNote(note)
            self.statusLabel.stringValue = "Stop"
        } else {
            instrument.stop()
            self.statusLabel.stringValue = "Play Sound"
        }
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
    }
}
