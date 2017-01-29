//
//  HomeViewController.m
//  AudioQueueServices
//
//  Created by Luis Castillo on 1/29/17.
//  Copyright © 2017 John Nastos. All rights reserved.
//

#import "HomeViewController.h"

@interface HomeViewController ()

@property AudioQueueRecorderAndPlayer * model;



@end

@implementation HomeViewController

@synthesize recordButton, playerButton;
@synthesize recorderStatusLabel, playerStatusLabel,authorizationLabel;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _model = [[AudioQueueRecorderAndPlayer alloc]init];
    _model.delegate = self;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [_model requestPermission];
}//eom

#pragma mark - Actions
- (IBAction)recordButtonPressed:(id)sender {
    [_model StartOrStopRecorder];
}


- (IBAction)playButtonPressed:(id)sender {
    [_model StartOrStopPlayer];
}


#pragma mark - Delegates

#pragma mark Authorization
-(void)authorization:(BOOL)success
{
    if (authorizationLabel) {
        dispatch_async( dispatch_get_main_queue(), ^{
            authorizationLabel.text = @"AUTHORIZED";
        });
    }
    else {
        dispatch_async( dispatch_get_main_queue(), ^{
            authorizationLabel.text = @"UNAUTHORIZED";
        });
    }
}//eom

#pragma mark recorder
-(void)recorderStarted:(BOOL)success
{
    if (success) {
        dispatch_async( dispatch_get_main_queue(), ^{
            recorderStatusLabel.text = @"STARTED";
        });
    }
    else {
        dispatch_async( dispatch_get_main_queue(), ^{
            recorderStatusLabel.text = @"FAILED START";
        });
    }
}//eom

-(void)recorderEnded:(BOOL)success
{
    if (success) {
        dispatch_async( dispatch_get_main_queue(), ^{
            recorderStatusLabel.text = @"ENDED";
        });
    }
    else {
        dispatch_async( dispatch_get_main_queue(), ^{
            recorderStatusLabel.text = @"FAILED ENDED";
        });
    }
}//eom

-(void)recorderErrorOccurred
{
    dispatch_async( dispatch_get_main_queue(), ^{
        recorderStatusLabel.text = @"ERROR";
    });
}//eom

#pragma mark player
-(void)playerStarted:(BOOL)success
{
    if (success) {
        dispatch_async( dispatch_get_main_queue(), ^{
            playerStatusLabel.text = @"STARTED";
        });
    }
    else {
        dispatch_async( dispatch_get_main_queue(), ^{
            playerStatusLabel.text = @"FAILED STARTED";
        });
    }
}//eom

-(void)playerEnded:(BOOL)success
{
    if (success) {
        dispatch_async( dispatch_get_main_queue(), ^{
            playerStatusLabel.text = @"ENDED";
        });
    }
    else {
        dispatch_async( dispatch_get_main_queue(), ^{
            playerStatusLabel.text = @"FAILED ENDED";
        });
    }
}//eom

-(void)playerErrorOccurred
{
    dispatch_async( dispatch_get_main_queue(), ^{
        playerStatusLabel.text = @"ERROR";
    });
}//eom

#pragma mark - Memory
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
