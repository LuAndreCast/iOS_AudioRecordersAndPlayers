//
//  ViewController.swift
//  LPCMrecorder
//
//  Created by Luis Castillo on 11/11/16.
//  Copyright © 2016 LC. All rights reserved.
//

import UIKit

import AudioToolbox

class ViewController: UIViewController {

    //MARK: - Properties
    var recorder:SpeechRecorder?
    
    @IBOutlet weak var startStopRecordingButton: UIButton!
    
    
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //having same recorder gives error
        recorder = SpeechRecorder()
    }

    
    //MARK: - Start / End Recording
   
    func startRecording()
    {
        //alloc/init recorder everytime we start recording gives no error
        //recorder = SpeechRecorder()
       
        
        //settings
        recorder?.format = kAudioFormatLinearPCM
        recorder?.sampleRate = 16000;
        recorder?.channelsPerFrame = 1
        recorder?.bitsPerChannel = 16
        recorder?.framesPerPacket = 1
        recorder?.bytesPerFrame = ((recorder!.channelsPerFrame * recorder!.bitsPerChannel) / 8)
        recorder?.bytesPerPacket = recorder!.bytesPerFrame * recorder!.framesPerPacket
        recorder?.formatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked
        
        //outputfile
        let outputfilePath:String = MyFileManager().createTempFilePathWithUniqueName("recorderAudio", andExtension: "wav")
        print("temp filepath: ", outputfilePath)
        recorder?.setOutputFile(path: outputfilePath)
        
        
        //handler
        recorder?.handler = { [weak self] status in
            switch status
            {
                case .busy:
                    print("started Recording\n\n")
                    break
                case .ready:
                    print("finish recorder, ready to start recording\n\n")
                    break
                case .error:
                    print("error occur with recorder\n\n")
                    
                    DispatchQueue.main.async
                    {
                        self?.startStopRecordingButton.isSelected = false
                        self?.view.backgroundColor = UIColor.white
                    }
                    
                    break
                }
        }//
        
        
        recorder?.start()
    }//eom
    
    
    func stopRecording()
    {
      recorder?.stop()
    }//eom
    
    //MARK: - Actions
    @IBAction func startStopRecording()
    {
        if startStopRecordingButton.isSelected
        {
            startStopRecordingButton.isSelected = false
            self.view.backgroundColor = UIColor.white
            startStopRecordingButton.setTitle("Start Recording", for: UIControlState.normal)
            
            self.stopRecording()
        }
        else
        {
            startStopRecordingButton.isSelected = true
            self.view.backgroundColor = UIColor.green
            startStopRecordingButton.setTitle("Stop Recording", for: UIControlState.normal)
            
            self.startRecording()
        }
    }//eom
    
    
    
    //MARK: - Memory
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

