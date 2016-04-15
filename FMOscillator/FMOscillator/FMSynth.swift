//
//  FMSynth.swift
//  FMOscillator
//
//  Created by Nicholas Arner on 9/8/15.
//  Copyright (c) 2015 Nicholas Arner. All rights reserved.
//

import AudioKit

public class FMSynth: NSObject {
    
    let fmOscillator = AKFMOscillator(
        waveform: AKTable(.Sine),
        baseFrequency: 440,
        carrierMultiplier: 1,
        modulatingMultiplier: 1,
        modulationIndex: 1,
        amplitude: 0.2
    )
    
    // INSTRUMENT DEFINITION ===================================================
    
    override init() {
        super.init()
        AudioKit.output = fmOscillator
        AudioKit.start()
    }
    
    
    public func startSound() {
        fmOscillator.start()
    }
    
    public func stopSound(){
        fmOscillator.stop()
    }
}