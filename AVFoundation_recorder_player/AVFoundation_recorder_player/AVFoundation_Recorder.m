//
//  AVFoundation_Recorder.m
//  AVFoundation_recorder_player
//
//  Created by Luis Castillo on 2/4/17.
//  Copyright © 2017 lc. All rights reserved.
//

#import "AVFoundation_Recorder.h"

@implementation AVFoundation_Recorder

@synthesize delegate;

#pragma mark - Init
-(instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    
    return self;
}//eom

#pragma mark - Setup
-(BOOL)setupRecorderWithFileURL:(NSURL *) fileURL
{
    if ( [self session_record_enable] == FALSE )
    {
        [delegate recorderErrorOccurred];
        return FALSE;
    }
    
    outputFileURL = fileURL;
    
    if (outputFileURL == nil) {
        [delegate recorderErrorOccurred];
        return false;
    }

    recordSettings  = @{
                                        
                        AVFormatIDKey:@(kAudioFormatLinearPCM),
                        AVSampleRateKey:@(16000.0),
                        AVNumberOfChannelsKey:@(1),
                        AVLinearPCMBitDepthKey:@(16),
                        AVLinearPCMIsBigEndianKey:@(NO),
                        AVLinearPCMIsFloatKey:@(YES)
                        
                        };
    
    NSLog(@"recorder settings: %@", recordSettings.description);
    NSLog(@"outputFileURL: %@", outputFileURL.description);
    
    NSError * error;
    audioRecorder = [[AVAudioRecorder alloc]
                         initWithURL:outputFileURL
                         settings:recordSettings
                         error:&error];
    if (error != nil) {
        [self printDebug:@"initWithURL" andError:error];
        [delegate recorderErrorOccurred];
        return false;
    }
    
    self->audioRecorder.delegate = self;
    self->audioRecorder.meteringEnabled = YES;
    
    if ([self->audioRecorder prepareToRecord] == false) {
        [delegate recorderErrorOccurred];
        return false;
    }
    
    if (self->soundMouterTimer) {
        [self->soundMouterTimer invalidate];
        self->soundMouterTimer = nil;
    }
    self->soundMouterTimer = [NSTimer scheduledTimerWithTimeInterval:0.3
                                                              target:self
                                                            selector:@selector(updateSoundMouter:)
                                                            userInfo:nil
                                                             repeats:YES];
    [self->soundMouterTimer fire];
    
    return true;
}//eom

#pragma mark - Request Permission
-(void)requestPermission
{
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        if (granted) {
            NSLog(@"Permission Granted");
        } else {
            NSLog(@"Permission NOT Granted");
            [delegate recorderNeedsPermission];
        }
    }];
}//eom

#pragma mark - Play
-(void)record:(NSURL *)fileURL
{
    if ( [self setupRecorderWithFileURL:fileURL] )
    {
        [self->audioRecorder record];
        
        [delegate recorderStarted];
    }
}//eom

#pragma mark - Stop
-(void)stop
{
    if ([self isRecording]) {
        [self->audioRecorder stop];
    }
    
    [self session_record_disable];
}//eom

#pragma mark - Helpers
-(void)updateSoundMouter:(NSTimer *)timer
{
    [self->audioRecorder updateMeters];
    
    float soundLoudly = [self->audioRecorder peakPowerForChannel:0];
    soundMouter = pow(10, (0.05 * soundLoudly));
    
    NSLog(@"audio soundMouter: %f ", soundMouter);
}//eom

- (NSTimeInterval)currentRecordFileDuration
{
    if ([self isRecording]) {
        return self->audioRecorder.currentTime;
    }
    
    return  0;
}

-(BOOL)isRecording
{
    if (self->audioRecorder != nil) {
        return  [self->audioRecorder isRecording];
    }
    
    return  false;
}

#pragma mark - Sessions
-(BOOL)session_record_enable
{
    NSError * error;
    [[AVAudioSession sharedInstance] setActive:YES error:&error];
    if (error != nil) {
        [self printDebug:@"setActive" andError:error];
        return false;
    }
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord
                                           error:&error];
    if (error != nil) {
        [self printDebug:@"setCategory" andError:error];
        return false;
    }
    
    return true;
}//eom

-(BOOL)session_record_disable
{
    NSError * error;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient
                                           error:&error];
    if (error != nil) {
        [self printDebug:@"setCategory" andError:error];

        return false;
    }
    
    [[AVAudioSession sharedInstance] setActive:NO error:&error];
    if (error != nil) {
        [self printDebug:@"setActive" andError:error];
        
        return false;
    }
    
    return true;
}//eom

#pragma mark - Delegates
-(void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder
                                  error:(NSError *)error
{
    [self session_record_disable];
    
    [self printDebug:@"audioRecorderEncodeErrorDidOccur" andError:error];
    
    [delegate recorderEnded:false];
}

-(void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder
                          successfully:(BOOL)flag
{
    if (self->soundMouterTimer) {
        [self->soundMouterTimer invalidate];
        self->soundMouterTimer = nil;
    }
    
    [delegate recorderEnded:flag];
    
    if (flag) {
        NSLog(@"audioRecorderDidFinishRecording - success");
    }
    else
    {
        NSLog(@"audioRecorderDidFinishRecording - failure");
    }
}//eom

#pragma mark - Debug
-(void)printDebug:(NSString *)message andError:(NSError *)error
{
    NSLog(@"%@ | %@ %ld %@", message, [error domain], (long)[error code], [[error userInfo] description]);
}


@end
