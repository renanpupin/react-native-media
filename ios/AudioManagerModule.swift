//
//  AudioManagerModule.swift
//  FalaFreud
//
//  Created by Haroldo Shigueaki Teruya on 24/01/2018.
//  Copyright © 2018 Facebook. All rights reserved.
//

import Foundation
import AVFoundation
import MediaPlayer
import AudioToolbox
import AudioToolbox.AudioServices
import CoreBluetooth

@objc(AudioManagerModule)
class AudioManagerModule: NSObject, AVAudioPlayerDelegate{

    // ATTRIBUTES =============================================================================================================

    var bridge: RCTBridge!
    var audioPlayer: AVAudioPlayer!
    var audioTimer: Timer!
    var vibrateTimer: Timer!
    var paused: Bool = false
    var isRingtone: Bool = false
    var timeInterval = 0.2
    var VIBRATE_TIMER_INTERVAL = 1.9

    let DEFAULTSPEAKER: Int = 0
    let EARSPEAKER: Int = 1
    var path : String = ""
    var audioOutputType: Int = 0

    let NEAR = 0;
    let FAR = 1;
    let ONBACKGROUND = 2;
    let ONACTIVE = 3;

    // METHODS ================================================================================================================

    @objc func load(_ path: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) -> Void {

        if self.audioPlayer != nil {
            self.stop()
        }

        self.isRingtone = false
        if let url = URL(string: path) {

            NSLog("AudioManagerModule load")

            do {
                self.audioPlayer = try AVAudioPlayer(contentsOf: url)
                if self.audioPlayer.prepareToPlay() {
                    self.path = path
                    resolve(audioPlayer.duration * 1000)
                } else {
                    resolve(false)
                }
            } catch {
                resolve(false)
            }
        } else {
            resolve(false)
        }
    }

    @objc func play(_ loop: Bool, playFromTime: Int, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) -> Void {

        if self.paused {
            resolve(false)
        } else if( self.audioPlayer != nil && !self.audioPlayer.isPlaying ){

            NSLog("AudioManagerModule play")

            if loop {
                self.audioPlayer.numberOfLoops = -1
            } else {
                self.audioPlayer.numberOfLoops = 0
            }

            self.audioPlayer.delegate = self
            if playFromTime > 0 {
                self.audioPlayer.currentTime = TimeInterval(Double(playFromTime)/1000)
            }
            self.audioPlayer.play()

            self.setCategory(self.audioOutputType)

            self.bridge.eventDispatcher().sendAppEvent( withName: "onTimeChanged", body: Int(audioPlayer.currentTime * 1000) )

            DispatchQueue.main.async(execute: {
                self.audioTimer = Timer.scheduledTimer(timeInterval: self.timeInterval, target: self, selector: #selector(self.timeChanged), userInfo: nil, repeats: true)
            })

            resolve(true)
        } else {
            resolve(false);
        }
    }

    @objc func playRingtone(_ path: String, type: Int, loop: Bool, vibrate: Bool, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) -> Void {

        if self.audioPlayer != nil {
            self.stop()
        }
        NSLog("AudioManagerModule playRingtone")
        self.isRingtone = true
        if let url = URL(string: path) {
            do {
                self.audioPlayer = try AVAudioPlayer(contentsOf: url)
                if self.audioPlayer.prepareToPlay() {

                    self.path = path
                    if loop {
                        self.audioPlayer.numberOfLoops = -1
                    } else {
                        self.audioPlayer.numberOfLoops = 0
                    }
                    self.audioPlayer.delegate = self
                    self.audioPlayer.play()

                    if vibrate {
                        self.vibrate()
                        DispatchQueue.main.async(execute: {
                            self.audioTimer = Timer.scheduledTimer(timeInterval: self.VIBRATE_TIMER_INTERVAL, target: self, selector: #selector(self.vibrate), userInfo: nil, repeats: true)
                        })
                    }

                    self.setCategory(type)

                    resolve(true)
                } else {
                    resolve(false)
                }
            } catch {
                resolve(false)
            }
        } else {
            resolve(false)
        }
    }

    @objc func vibrate() -> Void {

        NSLog("AudioManagerModule vibrate: %d", self.isRingtone)
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {

        NSLog("AudioManagerModule audioPlayerDidFinishPlaying: %d", self.isRingtone)
        if ( self.isRingtone ) {

        } else {
            self.bridge.eventDispatcher().sendAppEvent(withName: "onAudioFinished", body: nil)
        }
        self.stop()
    }

    func timeChanged() {

        NSLog("AudioManagerModule timeChanged")

        if self.audioPlayer != nil && !self.paused {
            self.bridge.eventDispatcher().sendAppEvent(withName: "onTimeChanged", body: Int(self.audioPlayer.currentTime * 1000) )
        } else if ( self.paused ) {
        } else if(self.audioTimer != nil) {
            self.audioTimer.invalidate()
        }
    }

    @objc func pause(_ resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) -> Void {

        NSLog("AudioManagerModule pause")

        if( self.audioPlayer != nil && self.audioPlayer.isPlaying ){
            self.paused = true
            self.audioPlayer.pause()
            resolve(true)
        } else {
            resolve(false);
        }
    }

    @objc func forcePause(sucess : Bool) {

        NSLog("AudioManagerModule forcePause")

        if( self.audioPlayer != nil && self.audioPlayer.isPlaying ){
            self.paused = true
            self.audioPlayer.pause()
        }
    }

    @objc func resume(_ resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) -> Void {

        NSLog("AudioManagerModule resume")

        if( self.audioPlayer != nil && !self.audioPlayer.isPlaying && self.paused ){
            self.paused = false
            self.audioPlayer.play()
            resolve(true)
        } else {
            resolve(false);
        }
    }

    @objc func stop(_ resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) -> Void {
        resolve(stop());
    }

    func stop() -> Bool {

        NSLog(self.TAG + " stop")

        do {
            self.path = ""
            self.paused = false
            self.isRingtone = false
            
            if self.audioTimer != nil {
                NSLog(self.TAG + " audioTimer invalidate")
                try self.audioTimer.invalidate()
                self.audioTimer = nil
            }
            if self.vibrateTimer != nil {
                NSLog(self.TAG + " vibrateTimer invalidate")
                try self.vibrateTimer.invalidate()
                self.vibrateTimer = nil
            }
            if( self.audioPlayer != nil ){
                NSLog(self.TAG + " audioPlayer destriy")
                try self.audioPlayer.stop()
                self.audioPlayer = nil
                
            }
        } catch let error {
          NSLog(self.TAG + " stop error " + error.localizedDescription)
        }
    }

    @objc func seekTime(_ time: Double, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) -> Void {

        NSLog("AudioManagerModule seekTime")

        var tempTime = time / 1000

        if( self.audioPlayer != nil ){
            self.audioPlayer.currentTime = TimeInterval(Double(tempTime))
            resolve(true)
        } else {
            resolve(false);
        }
    }

    @objc func setTimeInterval(_ timeInterval: Double, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) -> Void {

        NSLog("AudioManagerModule setTimeInterval")

        var tempTimeInterval = timeInterval / 1000

        if tempTimeInterval < 0.1 {
            resolve(false)
        } else {
            self.timeInterval = tempTimeInterval
            resolve(true)
        }
    }

    @objc func getVolume(_ resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) -> Void {

        NSLog("AudioManagerModule getVolume")

        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(true)
            var sucess = audioSession.outputVolume
            try audioSession.setActive(false)
            resolve(sucess)
        } catch let error {
            NSLog("AudioManagerModule getVolume %@", error.localizedDescription)
            resolve(false)
        }
    }

    func setCategory(_ type: Int) -> Bool {

        NSLog("AudioManagerModule setCategory")

        let session = AVAudioSession.sharedInstance()
        if type == self.EARSPEAKER {
            // ear = 1
            do {
                try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
                try session.setActive(true)
                NSLog("AudioManagerModule setCategory AVAudioSessionCategoryPlayAndRecord")
                return true
            } catch {
                return false
            }
        } else if type == self.DEFAULTSPEAKER {
            // default = 0
            do {
                if self.isRingtone {
                    try session.setCategory(AVAudioSessionCategorySoloAmbient, with: [AVAudioSessionCategoryOptions.allowBluetooth])
                    NSLog("AudioManagerModule setCategory AVAudioSessionCategorySoloAmbient")
                } else {
                    try session.setCategory(AVAudioSessionCategoryPlayback, with: [AVAudioSessionCategoryOptions.allowBluetooth])
                    try session.setPreferredInput(session.preferredInput)
                    NSLog("AudioManagerModule setCategory AVAudioSessionCategoryPlayback")
                }
                try session.setActive(true)
                return true
            } catch {
                return false
            }
        }
        return false
    }

    @objc func setAudioOutputRoute(_ type: Int, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {

        NSLog("AudioManagerModule setAudioOutputRoute")

        self.audioOutputType = type
        resolve(self.setCategory(type))
    }

    @objc func setAudioOutputType(_ type: Int, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {

        NSLog("AudioManagerModule setAudioOutputType")

        self.audioOutputType = type
        resolve(true)
    }

    @objc func getCurrentAudioName(_ fullPath: Bool, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {

        NSLog("AudioManagerModule getCurrentAudioName")

        if self.audioPlayer != nil {
            if !fullPath {
                let fileName = (self.path as NSString).lastPathComponent
                resolve(fileName)
            } else {
                resolve(path);
            }
        } else {
            resolve("");
        }
    }

    @objc func hasWiredheadsetPlugged(_ resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {

        NSLog("AudioManagerModule hasWiredheadsetPlugged")

        if self.getDeviceConnected() == "" {
            resolve(false)
        } else {
            resolve(true)
        }
    }

    func getDeviceConnected() -> String {

        let currentRoute = AVAudioSession.sharedInstance().currentRoute
        if currentRoute.outputs != nil {
            for description in currentRoute.outputs {
                if description.portType == AVAudioSessionPortHeadphones {
                    NSLog("AudioManagerModule getDeviceConnected headphone plugged in")
                    return description.portType
                } else if description.portType == AVAudioSessionPortBluetoothA2DP {
                    NSLog("AudioManagerModule getDeviceConnected AVAudioSessionPortBluetoothA2DP connected")
                    return description.portType
                } else if description.portType == AVAudioSessionPortBluetoothHFP {
                    NSLog("AudioManagerModule getDeviceConnected AVAudioSessionPortBluetoothA2DP connected")
                    return description.portType
                } else if description.portType == AVAudioSessionPortBluetoothLE {
                    NSLog("AudioManagerModule getDeviceConnected AVAudioSessionPortBluetoothA2DP connected")
                    return description.portType
                } else {
                    NSLog("AudioManagerModule getDeviceConnected nothing")
                    return ""
                }
            }
        }
        return ""
    }

    dynamic private func audioRouteChangeListener(notification:NSNotification) {

        let audioRouteChangeReason = notification.userInfo![AVAudioSessionRouteChangeReasonKey] as! UInt
        switch audioRouteChangeReason {
        case AVAudioSessionRouteChangeReason.newDeviceAvailable.rawValue:
            self.bridge.eventDispatcher().sendAppEvent(withName: "onWiredHeadsetPlugged", body: true)
        case AVAudioSessionRouteChangeReason.oldDeviceUnavailable.rawValue:
            self.bridge.eventDispatcher().sendAppEvent(withName: "onWiredHeadsetPlugged", body: false)
        default:
            break
        }
    }

    @objc func addAppStateListener() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.audioRouteChangeListener), name: .AVAudioSessionRouteChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.appMovedToBackground), name: .UIApplicationWillResignActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.appMovedToActive), name: .UIApplicationDidBecomeActive, object: nil)
    }

    @objc func appMovedToBackground() {

        NSLog("AudioManagerModule appMovedToBackground")

        if self.audioPlayer != nil && self.audioPlayer.isPlaying {
            self.paused = true
            self.audioPlayer.pause()
        }

        if (self.bridge != nil) {
            self.bridge.eventDispatcher().sendAppEvent( withName: "onProximityChanged", body: self.ONBACKGROUND)
        }
    }

    @objc func appMovedToActive() {

        NSLog("AudioManagerModule appMovedToActive")

        if (self.bridge != nil) {
            self.bridge.eventDispatcher().sendAppEvent( withName: "onProximityChanged", body: self.ONACTIVE)
        }
    }
}
