

import UIKit
import CoreAudio
import AudioToolbox


class SpeechRecorder: NSObject {
    
    static let sharedInstance = SpeechRecorder()
    
    // MARK:- properties
    @objc enum Status: Int {
        case ready
        case busy
        case error
    }
    
    internal struct RecordState {
        var format: AudioStreamBasicDescription
        var queue: UnsafeMutablePointer<AudioQueueRef?>
        var buffers: [AudioQueueBufferRef?]
        var file: AudioFileID?
        var currentPacket: Int64
        var recording: Bool
    };
    
    private var recordState: RecordState?
    
    var format: AudioFormatID {
        get { return recordState!.format.mFormatID }
        set {  recordState!.format.mFormatID = newValue }
    }
    
    var sampleRate: Float64 {
        get { return recordState!.format.mSampleRate }
        set {  recordState!.format.mSampleRate = newValue  }
    }
    
    var formatFlags: AudioFormatFlags {
        get {  return recordState!.format.mFormatFlags }
        set {   recordState!.format.mFormatFlags = newValue  }
    }
    
    var channelsPerFrame: UInt32 {
        get {   return recordState!.format.mChannelsPerFrame }
        set {   recordState!.format.mChannelsPerFrame = newValue }
    }
    
    var bitsPerChannel: UInt32 {
        get {   return recordState!.format.mBitsPerChannel }
        set {   recordState!.format.mBitsPerChannel = newValue  }
    }
    
    var framesPerPacket: UInt32 {
        get {  return recordState!.format.mFramesPerPacket }
        set {   recordState!.format.mFramesPerPacket = newValue }
    }
    
    var bytesPerFrame: UInt32 {
        get {  return recordState!.format.mBytesPerFrame }
        set {   recordState!.format.mBytesPerFrame = newValue }
    }
    
    var bytesPerPacket: UInt32 {
        get { return recordState!.format.mBytesPerPacket  }
        set {  recordState!.format.mBytesPerPacket = newValue }
    }
    
    //MARK: - Handlers
    public var handler: ((Status) -> Void)?
    
    // MARK:- Init
    override init()
    {
        super.init()
        self.recordState = RecordState(format: AudioStreamBasicDescription(),
                                       queue: UnsafeMutablePointer<AudioQueueRef?>.allocate(capacity: 1),
                                       buffers: [AudioQueueBufferRef?](repeating: nil, count: 1),
                                       file: nil,
                                       currentPacket: 0,
                                       recording: false)
    }//eom
    
   
    
    // MARK:- OutputFile
    func setOutputFile(path: String)
    {
        setOutputFile(url: URL(fileURLWithPath: path))
    }
    
    func setOutputFile(url: URL)
    {
        AudioFileCreateWithURL(url as CFURL,
                               kAudioFileWAVEType,
                               &recordState!.format,
                               AudioFileFlags.dontPageAlignAudioData.union(.eraseFile),
                               &recordState!.file)
    }
    
    // MARK:- Start / Stop Recording
    func start()
    {
        handler?(.busy)
        
        let inputAudioQueue: AudioQueueInputCallback =
            { (userData: UnsafeMutableRawPointer?,
                audioQueue: AudioQueueRef,
                bufferQueue: AudioQueueBufferRef,
                startTime: UnsafePointer<AudioTimeStamp>,
                packets: UInt32,
                packetDescription: UnsafePointer<AudioStreamPacketDescription>?) in
                
                let internalRSP = unsafeBitCast(userData, to: UnsafeMutablePointer<RecordState>.self)
                if packets > 0
                {
                    var packetsReceived = packets
                    let outputStream:OSStatus = AudioFileWritePackets(internalRSP.pointee.file!,
                                                                      false,
                                                                      bufferQueue.pointee.mAudioDataByteSize,
                                                                      packetDescription,
                                                                      internalRSP.pointee.currentPacket,
                                                                      &packetsReceived,
                                                                      bufferQueue.pointee.mAudioData)
                    if outputStream != 0
                    {
                        //<----DEBUG
                        switch outputStream
                        {
                            case kAudioFilePermissionsError:
                                print("kAudioFilePermissionsError")
                                break
                            case kAudioFileNotOptimizedError:
                                print("kAudioFileNotOptimizedError")
                                break
                            case kAudioFileInvalidChunkError:
                                print("kAudioFileInvalidChunkError")
                                break
                            case kAudioFileDoesNotAllow64BitDataSizeError:
                                print("kAudioFileDoesNotAllow64BitDataSizeError")
                                break
                            case kAudioFileInvalidPacketOffsetError:
                                print("kAudioFileInvalidPacketOffsetError")
                                break
                            case kAudioFileInvalidFileError:
                                print("kAudioFileInvalidFileError")
                                break
                            case kAudioFileOperationNotSupportedError:
                                print("kAudioFileOperationNotSupportedError")
                                break
                            case kAudioFileNotOpenError:
                                print("kAudioFileNotOpenError")
                                break
                            case kAudioFileEndOfFileError:
                                print("kAudioFileEndOfFileError")
                                break
                            case kAudioFilePositionError:
                                print("kAudioFilePositionError")
                                break
                            case kAudioFileFileNotFoundError:
                                print("kAudioFileFileNotFoundError")
                                break
                            case kAudioFileUnspecifiedError:
                                print("kAudioFileUnspecifiedError")
                                break
                            case kAudioFileUnsupportedFileTypeError:
                                print("kAudioFileUnsupportedFileTypeError")
                                break
                            case kAudioFileUnsupportedDataFormatError:
                                print("kAudioFileUnsupportedDataFormatError")
                                break
                            case kAudioFileUnsupportedPropertyError:
                                print("kAudioFileUnsupportedPropertyError")
                                break
                            case kAudioFileBadPropertySizeError:
                                print("kAudioFileBadPropertySizeError")
                                break
                            default:
                                print("unknown error")
                                break
                        }
                        //<----DEBUG
                    }
                    internalRSP.pointee.currentPacket += Int64(packetsReceived)
                }
                
                if internalRSP.pointee.recording
                {
                    let outputStream:OSStatus = AudioQueueEnqueueBuffer(audioQueue, bufferQueue, 0, nil)
                    if outputStream != 0
                    {
                        //<----DEBUG
                        switch outputStream
                        {
                            case kAudioFilePermissionsError:
                                print("kAudioFilePermissionsError")
                                break
                            case kAudioFileNotOptimizedError:
                                print("kAudioFileNotOptimizedError")
                                break
                            case kAudioFileInvalidChunkError:
                                print("kAudioFileInvalidChunkError")
                                break
                            case kAudioFileDoesNotAllow64BitDataSizeError:
                                print("kAudioFileDoesNotAllow64BitDataSizeError")
                                break
                            case kAudioFileInvalidPacketOffsetError:
                                print("kAudioFileInvalidPacketOffsetError")
                                break
                            case kAudioFileInvalidFileError:
                                print("kAudioFileInvalidFileError")
                                break
                            case kAudioFileOperationNotSupportedError:
                                print("kAudioFileOperationNotSupportedError")
                                break
                            case kAudioFileNotOpenError:
                                print("kAudioFileNotOpenError")
                                break
                            case kAudioFileEndOfFileError:
                                print("kAudioFileEndOfFileError")
                                break
                            case kAudioFilePositionError:
                                print("kAudioFilePositionError")
                                break
                            case kAudioFileFileNotFoundError:
                                print("kAudioFileFileNotFoundError")
                                break
                            case kAudioFileUnspecifiedError:
                                print("kAudioFileUnspecifiedError")
                                break
                            case kAudioFileUnsupportedFileTypeError:
                                print("kAudioFileUnsupportedFileTypeError")
                                break
                            case kAudioFileUnsupportedDataFormatError:
                                print("kAudioFileUnsupportedDataFormatError")
                                break
                            case kAudioFileUnsupportedPropertyError:
                                print("kAudioFileUnsupportedPropertyError")
                                break
                            case kAudioFileBadPropertySizeError:
                                print("kAudioFileBadPropertySizeError")
                                break
                            default:
                                print("unknown error")
                                break
                        }
                        //<----DEBUG
                    }
                }
        }
        
        let queueResults = AudioQueueNewInput(&recordState!.format, inputAudioQueue, &recordState, nil, nil, 0, recordState!.queue)
        if queueResults == 0
        {
            let bufferByteSize: Int = calculate(format: recordState!.format, seconds: 0.5)
            for index in (0..<recordState!.buffers.count)
            {
                AudioQueueAllocateBuffer(recordState!.queue.pointee!, UInt32(bufferByteSize), &recordState!.buffers[index])
                AudioQueueEnqueueBuffer(recordState!.queue.pointee!, recordState!.buffers[index]!, 0, nil)
            }
            
            AudioQueueStart(recordState!.queue.pointee!, nil)
            recordState?.recording = true
        }
        else
        {
            print("Error setting audio input.")
            handler?(.error)
        }
    }//eom
    
    func stop()
    {
        recordState?.recording = false
        if let recordingState: RecordState = recordState
        {
            AudioQueueStop(recordingState.queue.pointee!, true)
            AudioQueueDispose(recordingState.queue.pointee!, true)
            AudioFileClose(recordingState.file!)
            
            handler?(.ready)
        }
    }//eom
    
    // MARK:- Helper methods
    func calculate(format: AudioStreamBasicDescription, seconds: Double) -> Int
    {
        let framesRequiredForBufferTime = Int(ceil(seconds * format.mSampleRate))
        if framesRequiredForBufferTime > 0
            
        {
            return (framesRequiredForBufferTime * Int(format.mBytesPerFrame))
        }
        else
        {
            var maximumPacketSize = UInt32(0)
            if format.mBytesPerPacket > 0
            {
                maximumPacketSize = format.mBytesPerPacket
            }
            else
            {
                audioQueueProperty(propertyId: kAudioQueueProperty_MaximumOutputPacketSize, value: &maximumPacketSize)
            }
            
            var packets = 0
            if format.mFramesPerPacket > 0
            {
                packets = (framesRequiredForBufferTime / Int(format.mFramesPerPacket))
            } else
            {
                packets = framesRequiredForBufferTime
            }
            
            if packets == 0
            {
                packets = 1
            }
            
            return (packets * Int(maximumPacketSize))
        }
    }//eom
    
    func audioQueueProperty<T>(propertyId: AudioQueuePropertyID, value: inout T)
    {
        let propertySize = UnsafeMutablePointer<UInt32>.allocate(capacity: 1)
        propertySize.pointee = UInt32(MemoryLayout<T>.size)
        
        let queueResults = AudioQueueGetProperty(recordState!.queue.pointee!, propertyId, &value, propertySize)
        propertySize.deallocate(capacity: 1)
        
        if queueResults != 0 {
            print("Unable to get audio queue property.")
        }
    }//eom
}
