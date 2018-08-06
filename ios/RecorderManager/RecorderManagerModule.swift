//
//  RecorderManagerModule.swift
//  RNReactNativeMedia
//
//  Created by Haroldo Shigueaki Teruya on 18/04/2018.
//  Copyright © 2018 Facebook. All rights reserved.
//

import Foundation
import AVKit

@objc(RecorderManagerModule)
class RecorderManagerModule: NSObject, AVAudioRecorderDelegate {
    
    let TAG: String = "RecorderManager";
    
    // =============================================================================================
    // ATRIBUTES ===================================================================================
    
    enum Event : String {
        case ON_STARTED      = "ON_STARTED";
        case ON_TIME_CHANGED = "ON_TIME_CHANGED";
        case ON_ENDED        = "ON_ENDED";
    }
    
    enum Response : Int {
        case IS_RECORDING       = 0;
        case SUCCESS            = 1;
        case FAILED             = 2;
        case UNKNOWN_ERROR      = 3;
        case INVALID_AUDIO_PATH = 4;
        case NOTHING_TO_STOP    = 5;
        case NO_PERMISSION      = 6;
    }
    
    enum AudioOutputFormat : String {
        case MPEG4AAC       = "mpeg_4"; // default aac
        case LinearPCM      = "lpcm";
        case AppleIMA4      = "ima4";
        case MACE3          = "MAC3";
        case MACE6          = "MAC6";
        case ULaw           = "ulaw";
        case ALaw           = "alaw";
        case MPEGLayer1     = ".mp1";
        case MPEGLayer2     = ".mp2";
        case MPEGLayer3     = ".mp3";
        case AppleLossless  = "alac";
    }
    
    var bridge: RCTBridge!
    var recorder: AVAudioRecorder!
    var recordingSession: AVAudioSession = AVAudioSession.sharedInstance()
    var audioTimer: Timer!
    
    // =============================================================================================
    // CONSTRUCTOR =================================================================================
    
    // =============================================================================================
    // METHODS =====================================================================================
    
    @objc func start(_ path: String, audioOutputFormat: String, sampleRate: Int, channels: Int, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) -> Void {
        
        if self.recorder != nil {
            NSLog(TAG + " start: is recording")
            resolve(Response.IS_RECORDING.rawValue);
            return;
        }
        
        // verify the path
        if path == nil || path.isEmpty {
            NSLog(TAG + " start: " + path + " is ivalid")
            resolve(Response.INVALID_AUDIO_PATH.rawValue)
            return;
        }
        
        // build settings
        let settings = [
            AVFormatIDKey: self.getAudioOutputFormat(audioOutputFormat: audioOutputFormat),
            AVSampleRateKey: sampleRate,
            AVNumberOfChannelsKey: channels,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        // clean variables
        self.destroy(nil, rejecter: nil)
        
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() {
                
                [unowned self] allowed in
                
                DispatchQueue.main.async {
                    if allowed {
                        
                        // build recorder
                        do {
                            self.recorder = try AVAudioRecorder(url: URL(string: path)!, settings: settings)
                            self.recorder.delegate = self
                            
                            if self.recorder != nil, self.recorder.record() {
                                
                                self.emitEvent(eventName: Event.ON_STARTED.rawValue, data: nil)
                                self.audioTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.timeChanged), userInfo: nil, repeats: true)
                                NSLog(self.TAG + " start succesuful");
                                
                                resolve(Response.SUCCESS.rawValue)
                            } else {
                                NSLog(self.TAG + " cannot start");
                                self.destroy(nil, rejecter: nil)
                                resolve(Response.FAILED.rawValue)
                                return
                            }
                        } catch {
                            NSLog(self.TAG + " start error: " + error.localizedDescription);
                            self.destroy(nil, rejecter: nil)
                            resolve(Response.FAILED.rawValue)
                            return
                        }
                    } else {
                        NSLog(self.TAG + " start no permission");
                        resolve(Response.NO_PERMISSION.rawValue)
                        return
                    }
                }
            }
        } catch {
            NSLog(TAG + " start error: " + error.localizedDescription);
            resolve(Response.UNKNOWN_ERROR.rawValue)
        }
    }
    
    @objc func timeChanged() {
        
        NSLog(self.TAG + " timeChanged")
        
        if recorder != nil {
            self.emitEvent(eventName: Event.ON_TIME_CHANGED.rawValue, data: self.recorder.currentTime * 1000)
        } else if(audioTimer != nil) {
            audioTimer.invalidate()
            audioTimer = nil
        }
    }
    
    @objc func stop(_ resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) -> Void {
        
        NSLog(self.TAG + " stop")
        
        if self.recorder == nil {
            resolve(Response.NOTHING_TO_STOP.rawValue)
        } else {
            self.emitEvent(eventName: Event.ON_ENDED.rawValue, data: nil)
            resolve(Response.SUCCESS.rawValue)
        }
        self.destroy(nil, rejecter: nil)
    }
    
    @objc func destroy(_ resolve: RCTPromiseResolveBlock?, rejecter reject: RCTPromiseRejectBlock?) -> Void {
        
        NSLog(self.TAG + " destroy")
        
        if ( self.recorder != nil ) {
            self.recorder.stop()
            self.recorder = nil
        }
        
        if audioTimer != nil {
            audioTimer.invalidate()
            audioTimer = nil
        }
        
        if resolve != nil {
            resolve!(Response.SUCCESS.rawValue)
        }
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        
        if error != nil {
            NSLog(self.TAG + " audioRecorderEncodeErrorDidOccur " + (error?.localizedDescription)!)
        } else {
            NSLog(self.TAG + " audioRecorderEncodeErrorDidOccur unknow error")
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        
        if flag {
            NSLog(self.TAG + " audioRecorderDidFinishRecording success")
        } else {
            NSLog(self.TAG + " audioRecorderDidFinishRecording failed")
        }
        self.emitEvent(eventName: Event.ON_ENDED.rawValue, data: nil)
        self.destroy(nil, rejecter: nil)
    }
    
    func getAudioOutputFormat(audioOutputFormat: String) -> Int {
        
        switch audioOutputFormat {
        case AudioOutputFormat.LinearPCM.rawValue:
            return Int(kAudioFormatLinearPCM);
        case AudioOutputFormat.AppleIMA4.rawValue:
            return Int(kAudioFormatAppleIMA4);
        case AudioOutputFormat.MPEG4AAC.rawValue:
            return Int(kAudioFormatMPEG4AAC);
        case AudioOutputFormat.MACE3.rawValue:
            return Int(kAudioFormatMACE3);
        case AudioOutputFormat.MACE6.rawValue:
            return Int(kAudioFormatMACE6);
        case AudioOutputFormat.ULaw.rawValue:
            return Int(kAudioFormatULaw);
        case AudioOutputFormat.ALaw.rawValue:
            return Int(kAudioFormatALaw);
        case AudioOutputFormat.MPEGLayer1.rawValue:
            return Int(kAudioFormatMPEGLayer1);
        case AudioOutputFormat.MPEGLayer2.rawValue:
            return Int(kAudioFormatMPEGLayer2);
        case AudioOutputFormat.MPEGLayer3.rawValue:
            return Int(kAudioFormatMPEGLayer3);
        case AudioOutputFormat.AppleLossless.rawValue:
            return Int(kAudioFormatAppleLossless);
        default:
            return Int(kAudioFormatMPEG4AAC);
        }
    }
    
    func emitEvent(eventName: String, data: Any?) -> Void {
        
        if self.bridge != nil, self.bridge.eventDispatcher() != nil {
            self.bridge.eventDispatcher().sendAppEvent(withName: eventName, body: data)
        } else {
            NSLog(self.TAG + " fail to emitEvent: " + eventName);
        }
    }
}
