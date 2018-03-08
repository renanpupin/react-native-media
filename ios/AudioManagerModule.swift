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

@objc(AudioManagerModule)
class AudioManagerModule: NSObject, AVAudioPlayerDelegate {

    // ATTRIBUTES =============================================================================================================

    var bridge: RCTBridge!
    var audioPlayer: AVAudioPlayer!
    var audioTimer: Timer!
    var paused: Bool = false
    var timeInterval = 0.2

    let DEFAULTSPEAKER: Int = 0
    let EARSPEAKER: Int = 1
    var path : String = ""

    let NEAR = 0;
    let FAR = 1;
    let ONBACKGROUND = 2;
    let ONACTIVE = 3;

    // METHODS ================================================================================================================

    @objc func load(_ path: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) -> Void {

        if audioPlayer != nil {
            stop()
        }

        if let url = URL(string: path) {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                if audioPlayer.prepareToPlay() {
                    self.path = path
                    resolve(audioPlayer.duration)

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

//        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIApplicationDidBecomeActive, object: true)

        if paused {
            resolve(false)
        } else if( audioPlayer != nil && !audioPlayer.isPlaying ){

            if loop {
                audioPlayer.numberOfLoops = -1
            } else {
                audioPlayer.numberOfLoops = 0
            }

            audioPlayer.delegate = self
            if playFromTime > 0 {
                audioPlayer.currentTime = TimeInterval(Double(playFromTime)/1000)
            }
            audioPlayer.play()

            bridge.eventDispatcher().sendAppEvent( withName: "onTimeChanged", body: Int(audioPlayer.currentTime * 1000) )

            DispatchQueue.main.async(execute: {
                self.audioTimer = Timer.scheduledTimer(timeInterval: self.timeInterval, target: self, selector: #selector(self.timeChanged), userInfo: nil, repeats: true)
            })

            resolve(true)
        } else {
            resolve(false);
        }
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        bridge.eventDispatcher().sendAppEvent( withName: "onAudioFinished", body: nil )

        stop()
    }

    func timeChanged() {

        if audioPlayer != nil && !paused {
            bridge.eventDispatcher().sendAppEvent( withName: "onTimeChanged", body: Int(audioPlayer.currentTime * 1000) )
        } else if ( paused ) {

        } else {
            audioTimer.invalidate()
        }
    }

    @objc func pause(_ resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) -> Void {

        if( audioPlayer != nil && audioPlayer.isPlaying ){
            paused = true
            audioPlayer.pause()
            resolve(true)
        } else {
            resolve(false);
        }
    }

    @objc func forcePause(sucess : Bool) {

        print("pausing")
        if( audioPlayer != nil && audioPlayer.isPlaying ){
            paused = true
            audioPlayer.pause()
        }
    }

    @objc func resume(_ resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) -> Void {

        if( audioPlayer != nil && !audioPlayer.isPlaying && paused ){
            paused = false
            audioPlayer.play()
            resolve(true)
        } else {
            resolve(false);
        }
    }

    @objc func stop(_ resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) -> Void {
        resolve(stop());
    }

    func stop() -> Bool {
        if( audioPlayer != nil ){
            self.path = ""
            paused = false
            audioPlayer.stop()
            audioPlayer = nil

            if audioTimer != nil {
                audioTimer.invalidate()
                audioTimer = nil
            }

            return (true)
        } else {
            return (false);
        }
    }

    @objc func seekTo(_ time: Double, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) -> Void {

        var tempTime = time / 1000

        if( audioPlayer != nil ){
            audioPlayer.currentTime = TimeInterval(Double(tempTime))
            resolve(true)
        } else {
            resolve(false);
        }
    }

    @objc func setTimeInterval(_ timeInterval: Double, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) -> Void {

        var tempTimeInterval = timeInterval / 1000

        if tempTimeInterval < 0.1 {
            resolve(false)
        } else {
            self.timeInterval = tempTimeInterval
            resolve(true)
        }
    }

    @objc func getVolume(_ resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) -> Void {

        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(true)
            var sucess = audioSession.outputVolume
            try audioSession.setActive(false)
            resolve(sucess)
        } catch {
            resolve(false)
        }
    }

    @objc func setAudioOutputRoute(_ type: Int, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {

        let session = AVAudioSession.sharedInstance()
        if type == EARSPEAKER {
            do {
                try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
                try session.overrideOutputAudioPort(AVAudioSessionPortOverride.none)
                try session.setActive(true)
                resolve(true)
            } catch {
                resolve(false)
            }
        } else if type == DEFAULTSPEAKER {
            do {
                // try session.setCategory(AVAudioSessionCategoryPlayback, with: AVAudioSessionCategoryOptions.defaultToSpeaker)
                try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
                try session.overrideOutputAudioPort(AVAudioSessionPortOverride.speaker)
                try session.setActive(true)
                resolve(true)
            } catch {
                resolve(false)
            }
        }
    }

    @objc func getCurrentAudioName(_ fullPath: Bool, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {

        if audioPlayer != nil {
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

        let currentRoute = AVAudioSession.sharedInstance().currentRoute
        if currentRoute.outputs != nil {
            for description in currentRoute.outputs {
                if description.portType == AVAudioSessionPortHeadphones {
                    print("headphone plugged in")
                    resolve(true)
                } else {
                    print("headphone pulled out")
                    resolve(false)
                }
            }
        } else {
            print("requires connection to device")
        }
    }

    dynamic private func audioRouteChangeListener(notification:NSNotification) {

        let audioRouteChangeReason = notification.userInfo![AVAudioSessionRouteChangeReasonKey] as! UInt
        switch audioRouteChangeReason {
            case AVAudioSessionRouteChangeReason.newDeviceAvailable.rawValue:
                bridge.eventDispatcher().sendAppEvent( withName: "onWiredHeadsetPlugged", body: true)
            case AVAudioSessionRouteChangeReason.oldDeviceUnavailable.rawValue:
                bridge.eventDispatcher().sendAppEvent( withName: "onWiredHeadsetPlugged", body: false)
            default:
                break
        }
    }

    @objc func addAppStateListener() {
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: .UIApplicationWillResignActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToActive), name: .UIApplicationDidBecomeActive, object: nil)
    }

    @objc func appMovedToBackground() {
        if audioPlayer != nil && audioPlayer.isPlaying {
            print("native to pause")
            paused = true
            audioPlayer.pause()
            print("native paused")
        }
        bridge.eventDispatcher().sendAppEvent( withName: "onProximityChanged", body: ONBACKGROUND)
    }

    @objc func appMovedToActive() {
        bridge.eventDispatcher().sendAppEvent( withName: "onProximityChanged", body: ONACTIVE)
    }
}
