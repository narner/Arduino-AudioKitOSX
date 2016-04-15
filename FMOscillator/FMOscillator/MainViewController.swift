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
    @IBOutlet var frequencyLabel: NSTextField!
    @IBOutlet var modulationIndexLabel: NSTextField!
    
    @IBOutlet var frequencySlider: NSSlider!
    @IBOutlet var modulationIndexSlider: NSSlider!
    
    var fmSynth: FMSynth!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fmSynth = FMSynth()
        // Do any additional setup after loading the view, typically from a nib.
        
        let availablePorts = ORSSerialPortManager.sharedSerialPortManager().availablePorts
        if availablePorts.count == 0 {
            print("No connected serial ports found. Please connect your Arduino or turn on Bluetooth..\n")
            exit(EXIT_SUCCESS)
        }
        
        //NOTE: Update your own serial port value here
        let serialPort = ORSSerialPort(path: "/dev/tty.usbmodem1411")
        serialCommunicator.serialPort = serialPort
        
        //Receive notifications, and update potentiometer values and switch state
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.potOneValueChanged(_:)), name:"PotentiometerOneChanged", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.potTwoValueChanged(_:)), name:"PotentiometerTwoChanged", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.switchStateChanged(_:)), name:"SwitchStateChanged", object: nil)
    }
    
    func potOneValueChanged(notification: NSNotification){
        fmSynth.fmOscillator.baseFrequency = Double(serialCommunicator.potentiometerOneValue * 4)
        self.frequencyLabel.stringValue = "\(fmSynth.fmOscillator.baseFrequency)"
        self.frequencySlider.floatValue = Float(fmSynth.fmOscillator.baseFrequency)
    }
    
    func potTwoValueChanged(notification: NSNotification){
        fmSynth.fmOscillator.modulationIndex = Double(serialCommunicator.potentiometerTwoValue / 4)
        self.modulationIndexLabel.stringValue = "\(fmSynth.fmOscillator.modulationIndex)"
        self.modulationIndexSlider.floatValue = Float(fmSynth.fmOscillator.modulationIndex)
    }
    
    func switchStateChanged(notification: NSNotification){
        if serialCommunicator.switchState == true {
            fmSynth.startSound()
            self.statusLabel.stringValue = "Stop"
        } else {
            fmSynth.stopSound()
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
