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

    //MARK: - Models
    private var model:AModelClass = AModelClass.sharedInstance
    
    //MARK: - Properties
    @IBOutlet weak var startStopRecordingButton: UIButton!
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }//eom

    
    //MARK: - Actions
    @IBAction func startStopRecording()
    {
        if startStopRecordingButton.isSelected
        {
            startStopRecordingButton.isSelected = false
            self.view.backgroundColor = UIColor.white
            startStopRecordingButton.setTitle("Start Recording", for: UIControlState.normal)
            
            model.stop()
        }
        else
        {
            startStopRecordingButton.isSelected = true
            self.view.backgroundColor = UIColor.green
            startStopRecordingButton.setTitle("Stop Recording", for: UIControlState.normal)
            
            model.start()
        }
    }//eom
    
    //MARK: - Memory
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

