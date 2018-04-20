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

    @objc func start(_ path: String, audioOutputFormat: String, timeLimit: Int, sampleRate: Int, channels: Int, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) -> Void {

        // verify the path
        if path == nil || path.isEmpty {
            print("AudioManagerModule: " + path + " is ivalid")
            resolve(Response.INVALID_AUDIO_PATH.rawValue)
            return;
        }

        // reset all objects
        if self.recorder != nil {
            sendEvent(eventName: Event.ON_ENDED.rawValue, response: nil)
            self.destroy(nil, rejecter: nil)
        }

        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() {
                [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {

                        // build settings
                        let settings = [
                            AVFormatIDKey: self.getAudioOutputFormat(audioOutputFormat: audioOutputFormat),
                            AVSampleRateKey: sampleRate,
                            AVNumberOfChannelsKey: channels,
                            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
                        ]

                        // build recorder
                        do {
                            self.recorder = try AVAudioRecorder(url: URL(string: path)!, settings: settings)
                            self.recorder.isMeteringEnabled = true
                            self.recorder.delegate = self
                            if self.recorder.prepareToRecord() {
                                self.recorder.record(forDuration: TimeInterval(timeLimit / 1000))
                                self.bridge.eventDispatcher().sendAppEvent(withName: Event.ON_STARTED.rawValue, body: nil)

                                DispatchQueue.main.async(execute: {
                                    self.audioTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.timeChanged), userInfo: nil, repeats: true)
                                })

                                resolve(Response.SUCCESS.rawValue)
                            }
                        } catch {
                            self.destroy(nil, rejecter: nil)
                            resolve(Response.FAILED.rawValue)
                            return
                        }

                    } else {
                        resolve(Response.NO_PERMISSION.rawValue)
                        return
                    }
                }
            }
        } catch {
            print(error)
            resolve(Response.UNKNOWN_ERROR.rawValue)
        }
    }

    func timeChanged() {

        if recorder != nil {
            self.sendEvent(eventName: Event.ON_TIME_CHANGED.rawValue, response: recorder.currentTime * 1000)
        } else {
            audioTimer.invalidate()
        }
    }

    @objc func stop(_ resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) -> Void {
        print("AudioManagerModule: stop")

        if self.recorder == nil {
            resolve(Response.NOTHING_TO_STOP.rawValue)
        } else {
            self.bridge.eventDispatcher().sendAppEvent(withName: Event.ON_ENDED.rawValue, body: nil)
            self.destroy(nil, rejecter: nil)
            resolve(Response.SUCCESS.rawValue)
        }
    }

    @objc func destroy(_ resolve: RCTPromiseResolveBlock?, rejecter reject: RCTPromiseRejectBlock?) -> Void {
        print("AudioManagerModule: destroy")

        // destroy
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

    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        print("AudioManagerModule: audioRecorderDidFinishRecording")

        if flag {
            self.bridge.eventDispatcher().sendAppEvent(withName: Event.ON_ENDED.rawValue, body: nil)
            self.destroy(nil, rejecter: nil)
        }
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

    func sendEvent(eventName: String, response: Any?) -> Void {
        // print(eventName);
        self.bridge.eventDispatcher().sendAppEvent(withName: eventName, body: response)
    }
}
