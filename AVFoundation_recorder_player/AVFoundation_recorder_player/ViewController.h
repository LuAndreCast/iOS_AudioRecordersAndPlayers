//
//  ViewController.h
//  AVFoundation_recorder_player
//
//  Created by Luis Castillo on 2/4/17.
//  Copyright © 2017 lc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AVFoundation_Recorder.h"
#import "AVFoundation_Player.h"

@interface ViewController : UIViewController<AVFoundation_RecorderDelegate, AVFoundation_PlayerDelegate>


@end

