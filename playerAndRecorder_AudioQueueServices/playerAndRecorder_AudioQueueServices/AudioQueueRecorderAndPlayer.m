//
//  AudioQueueRecorderAndPlayer.m
//  AudioQueueServices
//
//  Created by Luis Castillo on 1/28/17.
//  Copyright © 2017 lc. All rights reserved.
//

#import "AudioQueueRecorderAndPlayer.h"


#pragma mark - debug
static BOOL verboseRecorderPlayer = TRUE;

#pragma mark - properties
static SInt64 currentByte;


//#define NUM_BUFFERS 10
#define NUM_BUFFERS 1
static AudioStreamBasicDescription audioFormat;
static AudioQueueRef queue;
static AudioQueueBufferRef buffers[NUM_BUFFERS];
static AudioFileID audioFileID;

@implementation AudioQueueRecorderAndPlayer

@synthesize delegate;

#pragma mark - Init
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}//eom

#pragma mark - Setup
- (void) setup {
//    audioFormat.mSampleRate = 44100.00;
    audioFormat.mSampleRate = 16000.00;
    audioFormat.mFormatID = kAudioFormatLinearPCM;
//    audioFormat.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    audioFormat.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
    audioFormat.mFramesPerPacket = 1;
    audioFormat.mChannelsPerFrame = 1;
    audioFormat.mBitsPerChannel = 16;
//    audioFormat.mBytesPerFrame = audioFormat.mChannelsPerFrame * sizeof(SInt16);
    audioFormat.mBytesPerFrame = ((audioFormat.mChannelsPerFrame * audioFormat.mBitsPerChannel) / 8);
    audioFormat.mBytesPerPacket = audioFormat.mFramesPerPacket * audioFormat.mBytesPerFrame;
    
    //init state - idle
    self.currentState = AudioQueueState_Idle;
}//eom

#pragma mark - Permission
-(void)requestPermission
{
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        if (granted) {
            [delegate authorization:granted];
            if (verboseRecorderPlayer)
            {
                NSLog(@"Authorization microphone - ACCEPTED");
            }
        }
        else {
            [delegate authorization:granted];
            if (verboseRecorderPlayer)
            {
                NSLog(@"Authorization microphone - REJECTED");
            }
        }
    }];
}//eom

#pragma mark - Recorder
-(void)StartOrStopRecorder
{
    switch (self.currentState) {
        case AudioQueueState_Idle:
            [self startRecording];
            break;
        case AudioQueueState_Playing:
            //do nothing since audio is being played
            break;
        case AudioQueueState_Recording:
                [self stopRecording];
            break;
        default:
            break;
    }
}//eom

-(void)startRecording
{
    //setting session values
    NSError *error;
    [[AVAudioSession sharedInstance] setActive:YES
                                         error:&error];
    if (error != nil) {
        if (verboseRecorderPlayer)
        {
            NSLog(@"Error %@", error.localizedDescription);
        }
        
        [delegate recorderStarted:false];
        return;
    }
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord
                                           error:&error];
    if (error != nil) {
        if (verboseRecorderPlayer)
            {
            NSLog(@"Error %@", error.localizedDescription);
            }
        
        [delegate recorderStarted:false];
        return;
    }
    
    [[AVAudioSession sharedInstance]
     requestRecordPermission:^(BOOL granted)
    {
         if (granted)
         {
             [delegate authorization:true];
             if (verboseRecorderPlayer)
             {
                 NSLog(@"Authorization microphone - ACCEPTED");
             }
         
             //updating state
             self.currentState = AudioQueueState_Recording;
             
             currentByte = 0;
             
             OSStatus status;
             
             status = AudioQueueNewInput(&audioFormat,
                                         AudioInputCallback,
                                         (__bridge void*)self,
                                         CFRunLoopGetCurrent(),
                                         kCFRunLoopCommonModes,
                                         0, &queue);
             
             if (status != noErr) {
                 if (verboseRecorderPlayer)
                     {
                     NSLog(@"Error on 'AudioQueueNewInput' | status code %d", (int)status);
                     }
                 
                 [delegate recorderStarted:false];
                 return;
             }
             
             for (int i = 0; i < NUM_BUFFERS; i++)
             {
                 status = AudioQueueAllocateBuffer(queue,
                                                   16000,
                                                   &buffers[i]);
                 if (status != noErr) {
                     if (verboseRecorderPlayer)
                         if (verboseRecorderPlayer)
                         {
                             NSLog(@"Error on 'AudioQueueAllocateBuffer' | status code %d", (int)status);
                         }
                     
                     [delegate recorderStarted:false];
                     return;
                 }
                 
                 status = AudioQueueEnqueueBuffer(queue,
                                                  buffers[i],
                                                  0,
                                                  NULL);
                 if (status != noErr) {
                     if (verboseRecorderPlayer)
                     {
                         NSLog(@"Error on 'AudioQueueEnqueueBuffer' | status code %d", (int)status);
                     }
                     
                     [delegate recorderStarted:false];
                     return;
                 }
             }//eofl
             
             NSString *directoryName = NSTemporaryDirectory();
             NSString *fileName = [directoryName stringByAppendingPathComponent:@"audioQueueFile.wav"];
             self.audioFileURL = [NSURL URLWithString:fileName];
             
             status = AudioFileCreateWithURL((__bridge CFURLRef)self.audioFileURL,
                                             kAudioFileWAVEType,
                                             &audioFormat,
                                             kAudioFileFlags_EraseFile, &audioFileID);
             
             if (status != noErr) {
                 if (verboseRecorderPlayer)
                     {
                     NSLog(@"Error on 'AudioFileCreateWithURL' | status code %d", (int)status);
                     }
                 
                 [delegate recorderStarted:false];
                 return;
             }
             
             status = AudioQueueStart(queue, NULL);
             if (status != noErr) {
                 if (verboseRecorderPlayer)
                     {
                     NSLog(@"Error on 'AudioQueueStart' | status code %d", (int)status);
                     }
                 
                 [delegate recorderStarted:false];
                 return;
             }
         
             //success
            [delegate recorderStarted:true];
         }
         else
         {
             if (verboseRecorderPlayer)
             {
                 NSLog(@"Authorization microphone - REJECTED");
             }
             
             [delegate authorization:false];
             [delegate recorderStarted:false];
             return;
         }
     }];
    
}//eom

-(void)stopRecording
{
    self.currentState = AudioQueueState_Idle;
    
    AudioQueueStop(queue, true);
    
    for (int i = 0; i < NUM_BUFFERS; i++) {
        AudioQueueFreeBuffer(queue, buffers[i]);
    }//eofl
    
    AudioQueueDispose(queue, true);
    AudioFileClose(audioFileID);
    
    if (verboseRecorderPlayer)
    {
        NSLog(@"Recorder ended");
    }
    
    [delegate recorderEnded:true];
}//eom

#pragma mark - Recorder Helper

/*
 Used in Recording
 */
void AudioInputCallback(
                        void *inUserData,
                        AudioQueueRef inAQ,
                        AudioQueueBufferRef inBuffer,
                        const AudioTimeStamp *inStartTime,
                        UInt32 inNumberPacketDescriptions,
                        const AudioStreamPacketDescription *inPacketDescs
                        )
{
    
        //    ViewController *viewController = (__bridge ViewController*)inUserData;
        //
        //    if (viewController.currentState != AudioQueueState_Recording) {
        //        return;
        //    }
    
    AudioQueueRecorderAndPlayer *audioClass = (__bridge AudioQueueRecorderAndPlayer*)inUserData;
    if (audioClass.currentState != AudioQueueState_Recording) {
        return;
    }
    
    UInt32 ioBytes = audioFormat.mBytesPerPacket * inNumberPacketDescriptions;
    
    OSStatus status = AudioFileWriteBytes(audioFileID,
                                          false,
                                          currentByte,
                                          &ioBytes,
                                          inBuffer->mAudioData);
    
    if (status != noErr) {
        if (verboseRecorderPlayer)
            {
            NSLog(@"Error on 'AudioFileWriteBytes' | status code %d", (int)status);
            }
        
        [audioClass.delegate recorderErrorOccurred];
        return;
    }
    
    currentByte += ioBytes;
    
    status = AudioQueueEnqueueBuffer(queue, inBuffer, 0, NULL);
    
    if (verboseRecorderPlayer)
    {
        NSLog(@"[AudioInputCallback] recording...");
    }
}//eom



#pragma mark - Player
-(void)StartOrStopPlayer
{
    switch (self.currentState) {
        case AudioQueueState_Idle:
            [self startPlayback];
            break;
        case AudioQueueState_Playing:
            [self stopPlayback];
            return;
        case AudioQueueState_Recording:
                //TODO: handle error
            
                //we should not be recorder - stop it!
                [self stopRecording];
            break;
        default:
            break;
    }
}//eom

- (void) startPlayback {
    
    NSError *error;
    [[AVAudioSession sharedInstance] setActive:YES error:&error];
    if (error != nil) {
        
        if (verboseRecorderPlayer)
        {
           NSLog(@"Error %@", error.localizedDescription);
        }
        
        [delegate playerErrorOccurred];
        return;
    }
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback
                                           error:&error];
    if (error != nil) {
        if (verboseRecorderPlayer)
        {
            NSLog(@"Error %@", error.localizedDescription);
        }
    
        [delegate playerErrorOccurred];
        return;
    }
    
    currentByte = 0;
    OSStatus status = AudioFileOpenURL((__bridge CFURLRef) (self.audioFileURL),
                                       kAudioFileReadPermission,
                                       kAudioFileWAVEType,
                                       &audioFileID);
    
    if (status != noErr) {
        if (verboseRecorderPlayer)
        {
            NSLog(@"Error on 'AudioFileOpenURL' | status code %d", (int)status);
        }
        
        [delegate playerStarted:false];
        return;
    }
    
    status = AudioQueueNewOutput(&audioFormat,
                                 AudioOutputCallback,
                                 (__bridge void*)self
                                 , CFRunLoopGetCurrent(),
                                 kCFRunLoopCommonModes,
                                 0,
                                 &queue);
    if (status != noErr) {
        if (verboseRecorderPlayer)
        {
            NSLog(@"Error on 'AudioQueueNewOutput' | status code %d", (int)status);
        }
        
        [delegate playerStarted:false];
        return;
    }
    
    self.currentState = AudioQueueState_Playing;
    
    for (int i = 0; i < NUM_BUFFERS
                    && self.currentState == AudioQueueState_Playing; i++)
    {
        status = AudioQueueAllocateBuffer(queue,
                                          16000,
                                          &buffers[i]);
        if (status != noErr) {
            if (verboseRecorderPlayer)
            {
                NSLog(@"Error on 'AudioQueueAllocateBuffer' | status code %d", (int)status);
            }
            
            [delegate playerStarted:false];
            return;
        }
        
        AudioOutputCallback((__bridge void*)self,
                            queue,
                            buffers[i]);
    }//eofl
    
    status = AudioQueueStart(queue, NULL);
    if (status != noErr) {
        if (verboseRecorderPlayer)
        {
            NSLog(@"Error on 'AudioQueueStart' | status code %d", (int)status);
        }
        
        [delegate playerStarted:false];
        return;
    }
    
    //success
    [delegate playerStarted:true];
}//eom

-(void)stopPlayback
{
    self.currentState = AudioQueueState_Idle;

    for (int i = 0; i < NUM_BUFFERS; i++) {
        AudioQueueFreeBuffer(queue, buffers[i]);
    }//eofl

    AudioQueueDispose(queue, true);
    AudioFileClose(audioFileID);
    
    if (verboseRecorderPlayer)
    {
        NSLog(@"Played ended");
    }
    
    [delegate playerEnded:true];
    
    
}//eom


#pragma mark Player Helper

/*
 Used in Player
 */
void AudioOutputCallback(void *inUserData,
                         AudioQueueRef outAQ,
                         AudioQueueBufferRef outBuffer
                         )
{
    
        //    ViewController *viewController = (__bridge ViewController*)inUserData;
        //
        //    if (viewController.currentState != AudioQueueState_Playing) {
        //        return;
        //    }
    
    AudioQueueRecorderAndPlayer *audioClass = (__bridge AudioQueueRecorderAndPlayer*)inUserData;
    if (audioClass.currentState != AudioQueueState_Playing) {
        return;
    }
    
    UInt32 numBytes = 16000;
    
    OSStatus status = AudioFileReadBytes(audioFileID,
                                         false,
                                         currentByte,
                                         &numBytes,
                                         outBuffer->mAudioData);
    
    if (status != noErr && status != kAudioFileEndOfFileError) {
        if (verboseRecorderPlayer)
            {
            NSLog(@"Error on 'AudioFileReadBytes' | status code %d", (int)status);
            }
        
        [audioClass.delegate playerErrorOccurred];
        return;
    }
    
    if (numBytes > 0) {
        outBuffer->mAudioDataByteSize = numBytes;
        OSStatus statusOfEnqueue = AudioQueueEnqueueBuffer(queue,
                                                           outBuffer,
                                                           0,
                                                           NULL);
        if (statusOfEnqueue != noErr) {
            if (verboseRecorderPlayer)
                {
                NSLog(@"Error on 'AudioQueueEnqueueBuffer' | status code %d", (int)status);
                }
            
            [audioClass.delegate playerErrorOccurred];
            return;
        }
        
        currentByte += numBytes;
    }
    
    if (numBytes == 0 || status == kAudioFileEndOfFileError) {
        AudioQueueStop(queue,false);
        AudioFileClose(audioFileID);
        
            //resetting state
            //        viewController.currentState = AudioQueueState_Idle;
        audioClass.currentState = AudioQueueState_Idle;
        
        if (verboseRecorderPlayer)
        {
            NSLog(@"[AudioOutputCallback] finished recording");
        }
        
        
        [audioClass.delegate playerEnded:true];
    }
}//eom

@end
