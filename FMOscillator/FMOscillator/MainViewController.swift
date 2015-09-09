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
    
    @IBOutlet var frequencySlider: AKPropertySlider!
    @IBOutlet var modulationIndexSlider: AKPropertySlider!
    
    let fmSynth = FMSynth()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let availablePorts = ORSSerialPortManager.sharedSerialPortManager().availablePorts as! [ORSSerialPort]
        if availablePorts.count == 0 {
            println("No connected serial ports found. Please connect your Arduino or turn on Bluetooth..\n")
            exit(EXIT_SUCCESS)
        }
        
        //NOTE: Update your own serial port value here
        let serialPort = ORSSerialPort(path: "/dev/tty.usbmodem1411")
        serialCommunicator.serialPort = serialPort
        
        //Adding the AudioKit instrument
        AKOrchestra.addInstrument(fmSynth)
        
        //Receive notifications, and update potentiometer values and switch state
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "potOneValueChanged:", name:"PotentiometerOneChanged", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "potTwoValueChanged:", name:"PotentiometerTwoChanged", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "switchStateChanged:", name:"SwitchStateChanged", object: nil)
    }
    
    func potOneValueChanged(notification: NSNotification){
        fmSynth.frequency.setValue(Float(serialCommunicator.potentiometerOneValue * 4))
        self.frequencyLabel.property = fmSynth.frequency
        self.frequencySlider.property = fmSynth.frequency
    }
    
    func potTwoValueChanged(notification: NSNotification){
        fmSynth.modulationIndex.setValue(Float(serialCommunicator.potentiometerTwoValue / 4))
        self.modulationIndexLabel.property = fmSynth.modulationIndex
        self.modulationIndexSlider.property = fmSynth.modulationIndex
    }
    
    func switchStateChanged(notification: NSNotification){
        if serialCommunicator.switchState == true {
            fmSynth.play()
            self.statusLabel.stringValue = "Stop"
        } else {
            fmSynth.stop()
            self.statusLabel.stringValue = "Play Sound"
        }
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        
        //Get rid of notification observers
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
    }
}
