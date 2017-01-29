//
//  ViewController.swift
//  SystemSound
//
//  Created by Luis Castillo on 1/28/17.
//  Copyright © 2017 lc. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var vibrationSwitch: UISwitch!
    
    
    let sysSound:SoundSystem = SoundSystem()
    private var soundReady:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        //setup
        soundReady = sysSound.setup()
        if soundReady {
            messageLabel.text = "Ready"
        }
        else
        {
            messageLabel.text = "NOT ready"
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        sysSound.unsetup()
    }
    
    @IBAction func playAudio(_ sender:Any)
    {
        if soundReady
        {
            let withVibration:Bool = vibrationSwitch.isOn
            sysSound.playSound(vibrate: withVibration)
        }
    }//eo-a

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

