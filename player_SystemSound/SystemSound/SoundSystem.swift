//
//  SoundSystem.swift
//  SystemSound
//
//  Created by Luis Castillo on 1/28/17.
//  Copyright © 2017 lc. All rights reserved.
//

import Foundation
import AudioToolbox

class SoundSystem: NSObject {
    
    private var soundID:SystemSoundID = 0
    
    override init() {
        super.init()
    
    }//eoc
    
    //MARK: - Setup
    func setup()->Bool
    {
        guard let soundURLPath:URL = Bundle.main.url(forResource: "MetalBell", withExtension: "wav") else {
            print("sound path invalid")
            return false
        }
        
        guard let soundURL:CFURL = soundURLPath as CFURL? else {
            print("CFURL conversion failed")
            return false
        }
        
        let status:OSStatus = AudioServicesCreateSystemSoundID(soundURL, &soundID)
        switch status {
        case noErr:
            print("No Errors")
            return true
        default:
            print("Something Happen")
            return false
        }
    }//eom
    
    //MARK: - Actions
    func playSound( vibrate:Bool = true)
    {
        AudioServicesPlaySystemSound(self.soundID)
        
        if vibrate
        {
            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
        }
    }//eom
    
    func unsetup()
    {
        AudioServicesDisposeSystemSoundID(self.soundID)
    }//eom
    
}
