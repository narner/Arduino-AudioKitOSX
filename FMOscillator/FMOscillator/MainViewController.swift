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
    
    let serialPortManager = ORSSerialPortManager.shared()
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
        
        let availablePorts = ORSSerialPortManager.shared().availablePorts
        if availablePorts.count == 0 {
            print("No connected serial ports found. Please connect your Arduino or turn on Bluetooth..\n")
            exit(EXIT_SUCCESS)
        }
        
        //NOTE: Update your own serial port value here
        let serialPort = ORSSerialPort(path: "/dev/tty.usbmodem1411")
        serialCommunicator.serialPort = serialPort
        
        //Receive notifications, and update potentiometer values and switch state
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.potOneValueChanged(_:)), name:NSNotification.Name(rawValue: "PotentiometerOneChanged"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.potTwoValueChanged(_:)), name:NSNotification.Name(rawValue: "PotentiometerTwoChanged"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.switchStateChanged(_:)), name:NSNotification.Name(rawValue: "SwitchStateChanged"), object: nil)
    }
    
    func potOneValueChanged(_ notification: Notification){
        fmSynth.fmOscillator.baseFrequency = Double(serialCommunicator.potentiometerOneValue * 4)
        self.frequencyLabel.stringValue = "\(fmSynth.fmOscillator.baseFrequency)"
        self.frequencySlider.floatValue = Float(fmSynth.fmOscillator.baseFrequency)
    }
    
    func potTwoValueChanged(_ notification: Notification){
        fmSynth.fmOscillator.modulationIndex = Double(serialCommunicator.potentiometerTwoValue / 4)
        self.modulationIndexLabel.stringValue = "\(fmSynth.fmOscillator.modulationIndex)"
        self.modulationIndexSlider.floatValue = Float(fmSynth.fmOscillator.modulationIndex)
    }
    
    func switchStateChanged(_ notification: Notification){
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
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
    }
}
