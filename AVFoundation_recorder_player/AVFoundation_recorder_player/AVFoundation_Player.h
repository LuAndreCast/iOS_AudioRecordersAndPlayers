//
//  audioPlayer.h
//  audioRecorder
//
//  Created by Luis Castillo on 10/26/16.
//  Copyright © 2016 LC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol AVFoundation_PlayerDelegate <NSObject>

    -(void)playerStarted;
    -(void)playerErrorOccurred;
    -(void)playerEnded:(BOOL)success;

@end

@interface AVFoundation_Player : NSObject<AVAudioPlayerDelegate>
{
    AVAudioPlayer * audio_player;
}

@property (strong, nonatomic) id<AVFoundation_PlayerDelegate> delegate;


-(void)playAudioFromURL:(NSURL *) url;
-(void)playAudioFromData:(NSData *) data;
-(void)stop;

-(BOOL)isPlaying;

@end
