//
//  AModelClass.swift
//  LPCMrecorder
//
//  Created by Luis Castillo on 11/14/16.
//  Copyright © 2016 LC. All rights reserved.
//

import Foundation
import AudioToolbox

class AModelClass {
    static let sharedInstance = AModelClass()
    
    private var recorder:SpeechRecorderV2 = SpeechRecorderV2()
    
    
    func start()
    {
        recorder.format = kAudioFormatLinearPCM
        recorder.sampleRate = 16000;
        recorder.channelsPerFrame = 1
        recorder.bitsPerChannel = 16
        recorder.framesPerPacket = 1
        recorder.bytesPerFrame = ((recorder.channelsPerFrame * recorder.bitsPerChannel) / 8)
        recorder.bytesPerPacket = recorder.bytesPerFrame * recorder.framesPerPacket
        recorder.formatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked
        
        //outputfile
        recorder.setOutputFileNameWithDocumentsDirectory(nameDesired: "audioRecording.wav")
        
        //handler
        recorder.handler = { status, data, errorDescription in
            switch status
            {
                case .busy:
                    print("\n\nstarted Recording")
                    break
                case .ready:
                    print("\n\nfinish recorder")
                    
                    if data != nil {
                        print("data information:")
                        print("length: ",data!.length)
                    }
                    
                    break
                case .error:
                    print("\n\nerror occur with recorder")
                    print(errorDescription)
                    
                    break
            }
        }//
        
        recorder.start()
    }//eom
    
    func stop()
    {
        recorder.stop()
    }
    
}
