//
//  audioPlayer.m
//  audioRecorder
//
//  Created by Luis Castillo on 10/26/16.
//  Copyright © 2016 LC. All rights reserved.
//

#import "AVFoundation_Player.h"

@implementation AVFoundation_Player

@synthesize delegate;


#pragma mark - Play
-(void)playAudioFromData:(NSData *) data
{
    if ( [self session_player_enable] == FALSE )
    {
        [delegate playerErrorOccurred];
        return ;
    }
    
    NSError * audioError;
    audio_player = [[AVAudioPlayer alloc] initWithData:data
                                                              error:&audioError];
    if (audioError != nil) {
        [self printDebug:@"player initWithContentsOfURL" andError:audioError];
        [delegate playerErrorOccurred];
        return;
    }
    
    [audio_player setDelegate:self];
    if (audio_player .prepareToPlay)
    {
        [self->audio_player play];
        [delegate playerStarted];
    }
    else
    {
        [delegate playerErrorOccurred];
    }
}//eom

-(void)playAudioFromURL:(NSURL *) url
{
    if ( [self session_player_enable] == FALSE)
    {
        [delegate playerErrorOccurred];
        return ;
    }
    
    NSError * audioError;
    audio_player = [[AVAudioPlayer alloc] initWithContentsOfURL:url
                                                                       error:&audioError];
    if (audioError != nil) {
        [self printDebug:@"player initWithContentsOfURL" andError:audioError];
        [delegate playerErrorOccurred];
        return;
    }
    
    [self->audio_player setDelegate:self];
    if ([self->audio_player prepareToPlay]) {
        [self->audio_player play];
        
        [delegate playerStarted];
    }
    else
    {
        [delegate playerErrorOccurred];
    }
}//eom

#pragma mark - Stop
-(void)stop
{
    if ([self isPlaying]) {
        [audio_player stop];
    }
    
    [self session_player_disable];
}//eom

#pragma mark - Helpers
-(BOOL)isPlaying
{
    if (audio_player != nil) {
        return [audio_player isPlaying];
    }
    
    return  false;
}//eom
#pragma mark - Session
-(BOOL)session_player_enable
{
    NSError * error;
    [[AVAudioSession sharedInstance] setActive:YES error:&error];
    if (error != nil) {
        [self printDebug:@"setActive" andError:error];
        return false;
    }
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback
                                           error:&error];
    if (error != nil) {
        [self printDebug:@"setCategory" andError:error];
        return false;
    }
    
    return true;
}//eom

-(BOOL)session_player_disable
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

#pragma mark - Player delegates
-(void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    [self session_player_disable];
    
    [self printDebug:@"audioPlayerDecodeErrorDidOccur" andError:error];
   
    [delegate playerErrorOccurred];
}//eom

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [delegate playerEnded:flag];
    
    if (flag) {
        NSLog(@"audioPlayerDidFinishPlaying - success");
    }
    else
    {
        NSLog(@"audioPlayerDidFinishPlaying - failure");
    }
}//eom

#pragma mark - Debug
-(void)printDebug:(NSString *)message andError:(NSError *) error
{
    NSLog(@"%@ | %@ %ld %@", message, [error domain], (long)[error code], [[error userInfo] description]);
}//eom



@end
