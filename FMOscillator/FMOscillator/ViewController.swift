//
//  ViewController.swift
//  FMOscillator
//
//  Created by Nicholas Arner on 6/20/15.
//  Copyright (c) 2015 Nicholas Arner. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    // STEP 1 : Set up an instance variable for the instrument
    let instrument = AKInstrument()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // STEP 2 : Define the instrument as a simple oscillator
        let oscillator = AKOscillator()
        instrument.connect(oscillator)
        instrument.connect(AKAudioOutput(audioSource: oscillator))
        
        // STEP 3 : Add the instrument to the orchestra and start the orchestra
        AKOrchestra.addInstrument(instrument)
        AKOrchestra.start()
        instrument.play()
    }
}
