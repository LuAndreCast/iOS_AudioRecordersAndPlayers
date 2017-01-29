//
//  PCMrecorder.swift
//  recordAndPlayAudio
//
//  Created by Luis Castillo on 6/1/16.
//  Copyright © 2016 LC. All rights reserved.
//

/*

import Foundation
import CoreAudio
import AudioToolbox

@objc enum speechRecordingStatus:Int {
    case READY
    case BUSY
    case ERROR //try again
}

@objc protocol speechRecorderDelegate {
    func speechRecorderStatusChanged(status: speechRecordingStatus)
}


struct RecorderState {
    var setupComplete: Bool
    var dataFormat: AudioStreamBasicDescription
    var queue: UnsafeMutablePointer<AudioQueueRef>
    var buffers: [AudioQueueBufferRef]
    var recordFile: AudioFileID
    var bufferByteSize: UInt32
    var currentPacket: Int64
    var isRunning: Bool
    var recordPacket: Int64
    var errorHandler: ((error:NSError) -> Void)?
}

@objc class PCMrecorder: NSObject {
    
    //singleton
    static let sharedInstance = PCMrecorder()
    
    //properties
    private var recorderState: RecorderState?
    
    private var _recordingStatus:speechRecordingStatus = speechRecordingStatus.READY
    
    var delegate:speechRecorderDelegate?
    
    
    //MARK: - Constructor
    override init() {
        super.init()
        
        self.recorderState = RecorderState(
            setupComplete: false,
            dataFormat: AudioStreamBasicDescription(),
            queue: UnsafeMutablePointer<AudioQueueRef>.alloc(1),
            buffers: Array<AudioQueueBufferRef>(count: 1, repeatedValue: nil),
            recordFile: nil,
            bufferByteSize: 0,
            currentPacket: 0,
            isRunning: false,
            recordPacket: 0,
            errorHandler: nil)
    }
    
    //MARK: - Setup
    func setupRecording(outputFileName:String)
    {
        let sampleRate:Float64      = 16000
        let channels:UInt32         = 1
        let bitsPerChannel:UInt32   = 16
        
        //settings
        self.recorderState?.dataFormat.mFormatID = kAudioFormatLinearPCM
        self.recorderState?.dataFormat.mSampleRate = sampleRate
        self.recorderState?.dataFormat.mChannelsPerFrame = channels
        self.recorderState?.dataFormat.mBitsPerChannel = bitsPerChannel
        self.recorderState?.dataFormat.mFramesPerPacket = 1
        self.recorderState?.dataFormat.mBytesPerFrame = (self.recorderState?.dataFormat.mChannelsPerFrame)! * ((self.recorderState?.dataFormat.mBitsPerChannel)! / 8)
        self.recorderState?.dataFormat.mBytesPerPacket = (self.recorderState?.dataFormat.mBytesPerFrame)! * (self.recorderState?.dataFormat.mFramesPerPacket)!
        
        self.recorderState?.dataFormat.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked
        
        self.recorderState?.errorHandler = nil
        
        //creating audio file
        AudioFileCreateWithURL(
            NSURL(fileURLWithPath: outputFileName),
            kAudioFileWAVEType,
            &self.recorderState!.dataFormat,
            AudioFileFlags.DontPageAlignAudioData.union(.EraseFile),
            &self.recorderState!.recordFile)
        
        self.recorderState?.setupComplete = true
    }//eom
    
    
    
    //MARK: - Recording
    func startRecording()
    {
        if self.recorderState?.setupComplete == true
        {
            //notify listeners
            _recordingStatus = speechRecordingStatus.BUSY
            
            let audioQueueInput:AudioQueueInputCallback =
                { (inUserData:UnsafeMutablePointer<Void>,
                    inAQ:AudioQueueRef,
                    inBuffer:AudioQueueBufferRef,
                    inStartTime:UnsafePointer<AudioTimeStamp>,
                    inNumPackets:UInt32,
                    inPacketDesc:UnsafePointer<AudioStreamPacketDescription>) in
                    
                    
                    let internalRSP = unsafeBitCast(inUserData, UnsafeMutablePointer<RecorderState>.self)
                    
                    if inNumPackets > 0
                    {
                        var packets = inNumPackets
                        
                        let os = AudioFileWritePackets(internalRSP.memory.recordFile, false, inBuffer.memory.mAudioDataByteSize, inPacketDesc, internalRSP.memory.recordPacket, &packets, inBuffer.memory.mAudioData)
                        if os != 0 && internalRSP.memory.errorHandler != nil
                        {
                            internalRSP.memory.errorHandler!(error:NSError(domain: NSOSStatusErrorDomain, code: Int(os), userInfo: nil))
                        }
                        
                        internalRSP.memory.recordPacket += Int64(packets)
                    }
                    
                    if internalRSP.memory.isRunning
                    {
                        let os = AudioQueueEnqueueBuffer(inAQ, inBuffer, 0, nil)
                        if os != 0 && internalRSP.memory.errorHandler != nil
                        {
                            internalRSP.memory.errorHandler!(error:NSError(domain: NSOSStatusErrorDomain, code: Int(os), userInfo: nil))
                        }
                    }
            }
            
            //
            let queueResults = AudioQueueNewInput(&self.recorderState!.dataFormat,
                                                  audioQueueInput, &self.recorderState, nil,
                                                  nil,
                                                  0,
                                                  self.recorderState!.queue)
            
            
            
            if queueResults == 0
            {
                
                let bufferByteSize:Int = self.computeRecordedBufferSize(self.recorderState!.dataFormat, seconds: 0.5)
                
                for i in (0..<self.recorderState!.buffers.count)
                {
                    AudioQueueAllocateBuffer(self.recorderState!.queue.memory,
                                             UInt32(bufferByteSize),
                                             &self.recorderState!.buffers[i])
                    
                    AudioQueueEnqueueBuffer(self.recorderState!.queue.memory,
                                            self.recorderState!.buffers[i],
                                            0,
                                            nil)
                }//eofl
                
                AudioQueueStart(self.recorderState!.queue.memory, nil)
                
                self.recorderState!.isRunning = true
            }
            else
            {
                print("error setting audio input")
                
                //notify listeners
                _recordingStatus = speechRecordingStatus.ERROR
                delegate?.speechRecorderStatusChanged(_recordingStatus)
            }
        }
        else
        {
            print("setup needs to be called before starting!")
            
            //notify listeners
            _recordingStatus = speechRecordingStatus.ERROR
            delegate?.speechRecorderStatusChanged(_recordingStatus)
        }
    }//eom
    
    func stopRecording()
    {
        self.recorderState?.isRunning = false
        
        if let recordingState:RecorderState = self.recorderState
        {
            AudioQueueStop(recordingState.queue.memory, true)
            AudioQueueDispose(recordingState.queue.memory, true)
            AudioFileClose(recordingState.recordFile)
            
            //notify listeners
            _recordingStatus = speechRecordingStatus.READY
            delegate?.speechRecorderStatusChanged(_recordingStatus)
        }
    }//eom
    
    //MARK: - Helpers
    private func computeRecordedBufferSize(format:AudioStreamBasicDescription, seconds:Double)-> Int
    {
        let framesNeededForBufferTime = Int(ceil(seconds * format.mSampleRate))
        
        if format.mBytesPerFrame > 0
        {
            return framesNeededForBufferTime * Int(format.mBytesPerFrame)
        }
        else
        {
            var maxPacketSize = UInt32(0)
            
            if format.mBytesPerPacket > 0
            {
                maxPacketSize = format.mBytesPerPacket
            }
            else
            {
                self.getAudioQueueProperty(kAudioQueueProperty_MaximumOutputPacketSize, value: &maxPacketSize)
            }
            
            var packets = 0
            if format.mFramesPerPacket > 0
            {
                packets = framesNeededForBufferTime / Int(format.mFramesPerPacket)
            }
            else
            {
                packets = framesNeededForBufferTime
            }
            
            if packets == 0
            {
                packets = 1
            }
            
            return packets * Int(maxPacketSize)
        }
        
    }//eom
    
    private func getAudioQueueProperty<T>(propertyId:AudioQueuePropertyID, inout value:T)
    {
        let propertySize    = UnsafeMutablePointer<UInt32>.alloc(1)
        propertySize.memory = UInt32(sizeof(T))
        
        let queueResults = AudioQueueGetProperty(self.recorderState!.queue.memory,
                                                 propertyId,
                                                 &value,
                                                 propertySize)
        
        propertySize.dealloc(1)
        
        if queueResults != 0
        {
            print("un-able to get audio queue property")
        }
        
    }//eom
    
}//eoc

*/
