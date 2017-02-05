//
//  AVFoundation_Recorder.h
//  AVFoundation_recorder_player
//
//  Created by Luis Castillo on 2/4/17.
//  Copyright © 2017 lc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>


@protocol AVFoundation_RecorderDelegate <NSObject>

    -(void)recorderNeedsPermission;

    -(void)recorderStarted;
    -(void)recorderErrorOccurred;
    -(void)recorderEnded:(BOOL)success;

@end


@interface AVFoundation_Recorder : NSObject<AVAudioRecorderDelegate>
{
    NSURL *outputFileURL;
    AVAudioRecorder *audioRecorder;
    NSDictionary * recordSettings;
    
    CGFloat soundMouter;
    NSTimer *soundMouterTimer;
}


@property (nonatomic, weak) id<AVFoundation_RecorderDelegate> delegate;

- (NSTimeInterval)currentRecordFileDuration;
-(BOOL)isRecording;

-(void)requestPermission;

-(void)record:(NSURL *)fileURL;
-(void)stop;


@end
