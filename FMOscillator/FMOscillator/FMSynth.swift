//
//  FMSynth.swift
//  FMOscillator
//
//  Created by Nicholas Arner on 9/8/15.
//  Copyright (c) 2015 Nicholas Arner. All rights reserved.
//

import AudioKit

open class FMSynth: NSObject {
    
    let fmOscillator = AKFMOscillator(
        waveform: AKTable(.sine),
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
    
    
    open func startSound() {
        fmOscillator.start()
    }
    
    open func stopSound(){
        fmOscillator.stop()
    }
}
