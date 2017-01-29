//
//  HomeViewController.h
//  AudioQueueServices
//
//  Created by Luis Castillo on 1/29/17.
//  Copyright © 2017 John Nastos. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AudioQueueRecorderAndPlayer.h"

@interface HomeViewController : UIViewController<AudioQueueRecorderAndPlayerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *authorizationLabel;

@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UIButton *playerButton;

@property (weak, nonatomic) IBOutlet UILabel *recorderStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *playerStatusLabel;


@end
