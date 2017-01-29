//
//  AudioQueueRecorder.h
//  AudioQueueServices
//
//  Created by Luis Castillo on 1/28/17.
//  Copyright © 2017 John Nastos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "AudioQueueServicesConstants.h"


@protocol AudioQueueRecorderAndPlayerDelegate <NSObject>

    //microphone authorization
-(void)authorization:(BOOL)success;


    //recorder
-(void)recorderStarted:(BOOL)success;
-(void)recorderEnded:(BOOL)success;
-(void)recorderErrorOccurred;

    //player
-(void)playerStarted:(BOOL)success;
-(void)playerEnded:(BOOL)success;
-(void)playerErrorOccurred;

@end


@interface AudioQueueRecorderAndPlayer : NSObject

@property AudioQueueState currentState;
@property (strong, nonatomic) NSURL *audioFileURL;

@property (nonatomic, weak) id<AudioQueueRecorderAndPlayerDelegate>delegate;

-(void)requestPermission;
-(void)StartOrStopRecorder;
-(void)StartOrStopPlayer;


@end
