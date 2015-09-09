//
//  FMSynth.swift
//  FMOscillator
//
//  Created by Nicholas Arner on 9/8/15.
//  Copyright (c) 2015 Nicholas Arner. All rights reserved.
//

class FMSynth: AKInstrument {
    
    // INSTRUMENT CONTROLS =====================================================
    
    var frequency            = AKInstrumentProperty(value: 40, minimum: 20, maximum: 400)
    var amplitude            = AKInstrumentProperty(value: 0.2, minimum: 0,  maximum: 1)
    var carrierMultiplier    = AKInstrumentProperty(value: 1,   minimum: 0,  maximum: 3)
    var modulatingMultiplier = AKInstrumentProperty(value: 1,   minimum: 0,  maximum: 3)
    var modulationIndex      = AKInstrumentProperty(value: 15,  minimum: 0,  maximum: 30)
    
    // INSTRUMENT DEFINITION ===================================================
    
    override init() {
        super.init()
        
        addProperty(frequency)
        addProperty(amplitude)
        addProperty(carrierMultiplier)
        addProperty(modulatingMultiplier)
        addProperty(modulationIndex)
        
        let fmOscillator = AKFMOscillator(
            waveform: AKTable.standardSineWave(),
            baseFrequency: frequency,
            carrierMultiplier: carrierMultiplier,
            modulatingMultiplier: modulatingMultiplier,
            modulationIndex: modulationIndex,
            amplitude: amplitude
        )
        setAudioOutput(fmOscillator)
    }
}