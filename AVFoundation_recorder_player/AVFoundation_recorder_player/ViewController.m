//
//  ViewController.m
//  AVFoundation_recorder_player
//
//  Created by Luis Castillo on 2/4/17.
//  Copyright © 2017 lc. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
        //Models
    AVFoundation_Recorder * recorder;
    AVFoundation_Player * player;
    NSString * recordedAudio;

}
    //UI
@property (weak, nonatomic) IBOutlet UIButton *recorderButton;
@property (weak, nonatomic) IBOutlet UIButton *playerButton;
@property (weak, nonatomic) IBOutlet UILabel *audioLabel;

@end

@implementation ViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _audioLabel.text = @"";
    _playerButton.hidden = true;
    
    recorder = [[AVFoundation_Recorder alloc] init];
    recorder.delegate = self;
    
    player = [[AVFoundation_Player alloc] init];
    player.delegate = self;
}

#pragma mark - Actions
- (IBAction)recordOrStop:(UIButton *)sender {
    
    if ([recorder isRecording]) {
        [recorder stop];
        [self.recorderButton setTitle:@"Record" forState:UIControlStateNormal];
        self.playerButton.hidden = false;
    }
    else {
        recordedAudio =  [NSTemporaryDirectory() stringByAppendingPathComponent:@"recording.wav"];
        [recorder record: [NSURL URLWithString:recordedAudio] ];
        
        [self.recorderButton setTitle:@"Stop" forState:UIControlStateNormal];
        self.playerButton.hidden = true;
    }
}//eom

- (IBAction)playOrStop:(UIButton *)sender {
    if ([player isPlaying]) {
        [player stop];
        [self.playerButton setTitle:@"Play" forState:UIControlStateNormal];
        self.recorderButton.hidden = false;
    }
    else
    {
        [player playAudioFromData:[[NSData alloc] initWithContentsOfFile:recordedAudio]];
        [self.playerButton setTitle:@"Stop" forState:UIControlStateNormal];
        self.recorderButton.hidden = true;
    }
}//eom

#pragma mark - Recorder Delegates
-(void)recorderEnded:(BOOL)success
{
    if (success) {
        [self updateMessage:@"Recorder Finished Successfully"];
    }
    else
    {
        [self updateMessage:@"Recorder Finished with Failure"];
    }
}

-(void)recorderErrorOccurred
{
    [self updateMessage:@"Recorder Failure"];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.recorderButton setTitle:@"Record" forState:UIControlStateNormal];
        self.playerButton.hidden = false;
    });
}

-(void)recorderStarted
{
     [self updateMessage:@"Started Recording"];
}

-(void)recorderNeedsPermission
{
    [self updateMessage:@"Recorder requires permission"];
}

-(void)updateMessage:(NSString *)message
{
    dispatch_async(dispatch_get_main_queue(), ^{
        _audioLabel.text = message;
    });
}


#pragma mark - Player Delegates
-(void)playerErrorOccurred
{
    [self updateMessage:@"Player Failure"];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.playerButton setTitle:@"Play" forState:UIControlStateNormal];
        self.recorderButton.hidden = false;
    });
}

-(void)playerEnded:(BOOL)success
{
    if (success) {
         [self updateMessage:@"Player Finished Successfully"];
    } else {
         [self updateMessage:@"Player Finished with Failure"];
    }

}

-(void)playerStarted
{
     [self updateMessage:@"Player playing"];
}

#pragma mark - Memory

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
