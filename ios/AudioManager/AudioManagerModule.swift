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

    let TAG: String = "AudioManager"

    // =============================================================================================
    // ATRIBUTES ===================================================================================

    struct Event {
        static let ON_AUDIO_STARTED = "onAudioStarted";
        static let ON_TIME_CHANGED = "onTimeChanged";
        static let ON_AUDIO_FINISHED = "onAudioFinished";
        static let ON_WIREDHEADSET_PLUGGED = "onWiredHeadsetPlugged";
        static let ON_PROXIMITY_CHANGED = "onProximityChanged";
    }

    struct OutputRoute {
        static let DEFAULT_SPEAKER = 0;
        static let EAR_SPEAKER = 1;
    }

    struct Data {
        static let NEAR = 0;
        static let FAR = 1;
        static let ON_BACKGROUND = 2;
        static let ON_ACTIVE = 3;
    }

    var bridge: RCTBridge!
    var audioPlayer: AVAudioPlayer!
    var audioTimer: Timer!
    var vibrateTimer: Timer!
    var paused: Bool = false
    var isRingtone: Bool = false
    var timeInterval = 0.2
    var VIBRATE_TIMER_INTERVAL = 1.9
    var path : String = ""
    var audioOutputType: Int = 0

    // =============================================================================================
    // CONSTRUCTOR =================================================================================

    // =============================================================================================
    // METHODS =====================================================================================

    @objc func load(_ path: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) -> Void {

        self.stop()

        if let url = URL(string: path) {
            do {
                self.audioPlayer = try AVAudioPlayer(contentsOf: url)
                if self.audioPlayer.prepareToPlay() {
                    NSLog(TAG + " load success")
                    self.path = path
                    resolve(audioPlayer.duration * 1000)
                    return
                } else {
                    NSLog(TAG + " load fail: " + path)
                    resolve(false)
                    return
                }
            } catch {
                NSLog(TAG + " load error: " + path)
                resolve(false)
                return
            }
        } else {
            NSLog(TAG + " load error: " + path)
            resolve(false)
            return
        }
    }

    @objc func play(_ loop: Bool, playFromTime: Int, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) -> Void {

        if self.paused {
            resolve(false)
            return
        } else if self.audioPlayer != nil, !self.audioPlayer.isPlaying {

            NSLog(self.TAG + " play")
            self.audioPlayer.numberOfLoops = loop ? -1 : 0
            self.audioPlayer.delegate = self
            self.audioPlayer.currentTime = playFromTime > 0 ? TimeInterval(Double(playFromTime)/1000) : 0

            if (self.audioPlayer.play()) {
                self.setCategory(self.audioOutputType)
                emitEvent(eventName: Event.ON_AUDIO_STARTED, data: Int(audioPlayer.currentTime * 1000))
                DispatchQueue.main.async(execute: {
                    self.audioTimer = Timer.scheduledTimer(
                        timeInterval: self.timeInterval,
                        target: self,
                        selector: #selector(self.timeChanged),
                        userInfo: nil,
                        repeats: true)
                })
                resolve(true)
                return
            } else {
                NSLog(self.TAG + " play error")
                self.stop()
                resolve(false)
                return
            }
        } else {
            NSLog(self.TAG + " play error")
            self.stop()
            resolve(false);
            return
        }
    }

    @objc func playRingtone(_ path: String, type: Int, loop: Bool, vibrate: Bool, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) -> Void {

        self.stop()
        self.isRingtone = true

        if let url = URL(string: "file:///" + path + ".mp3") {
            do {
                self.audioPlayer = try AVAudioPlayer(contentsOf: url)
                if self.audioPlayer.prepareToPlay() {

                    self.path = path
                    self.audioPlayer.numberOfLoops = loop ? -1 : 0
                    self.audioPlayer.play()

                    if vibrate {
                        self.vibrate()
                        DispatchQueue.main.async(execute: {
                            self.audioTimer = Timer.scheduledTimer(
                                timeInterval: self.VIBRATE_TIMER_INTERVAL,
                                target: self,
                                selector: #selector(self.vibrate),
                                userInfo: nil,
                                repeats: true)
                        })
                    }

                    self.setCategory(type)
                    self.emitEvent(eventName: Event.ON_AUDIO_STARTED, data: nil)

                    NSLog(self.TAG + " playRingtone success")
                    resolve(true)
                    return
                } else {
                    NSLog(self.TAG + " playRingtone error")
                    self.stop()
                    resolve(false)
                    return
                }
            } catch {
                NSLog(self.TAG + " playRingtone error")
                self.stop()
                resolve(false)
                return
            }
        } else {
            NSLog(self.TAG + " playRingtone error")
            self.stop()
            resolve(false)
            return
        }
    }

    @objc func vibrate() -> Void {

        NSLog(self.TAG + " vibrate")
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {

        if (!self.isRingtone) {
            self.emitEvent(eventName: Event.ON_AUDIO_FINISHED, data: nil)
        }
        self.stop()
    }

    @objc func timeChanged() {

        if self.audioPlayer != nil, !self.paused {
            self.emitEvent(eventName: Event.ON_TIME_CHANGED, data: Int(self.audioPlayer.currentTime * 1000))
        } else if(self.audioTimer != nil) {
            self.audioTimer.invalidate()
        }
    }

    @objc func pause(_ resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) -> Void {

        if self.audioPlayer != nil, self.audioPlayer.isPlaying {
            self.paused = true
            self.audioPlayer.pause()
            resolve(true)
        } else {
            resolve(false);
        }
    }

    @objc func forcePause(sucess : Bool) {

        if self.audioPlayer != nil, self.audioPlayer.isPlaying {
            self.paused = true
            self.audioPlayer.pause()
        }
    }

    @objc func resume(_ resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) -> Void {

        NSLog(self.TAG + " resume")

        if self.audioPlayer != nil, !self.audioPlayer.isPlaying, self.paused, self.audioPlayer.play() {
            self.paused = false
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

        self.path = ""
        self.paused = false
        self.isRingtone = false

        if self.audioTimer != nil {
            NSLog(self.TAG + " audioTimer invalidate")
            self.audioTimer.invalidate()
            self.audioTimer = nil
        }
        if self.vibrateTimer != nil {
            NSLog(self.TAG + " vibrateTimer invalidate")
            self.vibrateTimer.invalidate()
            self.vibrateTimer = nil
        }
        if( self.audioPlayer != nil ){
            NSLog(self.TAG + " audioPlayer destroy")
            self.audioPlayer.stop()
            self.audioPlayer.currentTime = 0
            self.audioPlayer = nil
            return true
        } else {
            return false
        }
    }

    @objc func seekTime(_ time: Double, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) -> Void {

        let tempTime = time / 1000
        if (self.audioPlayer != nil) {
            self.audioPlayer.currentTime = TimeInterval(Double(tempTime))
            resolve(true)
        } else {
            resolve(false);
        }
    }

    @objc func setTimeInterval(_ timeInterval: Double, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) -> Void {

        let tempTimeInterval = timeInterval / 1000
        if tempTimeInterval < 0.1 {
            resolve(false)
        } else {
            self.timeInterval = tempTimeInterval
            resolve(true)
        }
    }

    @objc func getVolume(_ resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) -> Void {

        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setActive(true)
            var sucess = audioSession.outputVolume
            try audioSession.setActive(false)
            NSLog(self.TAG +  " getVolume")
            resolve(sucess)
        } catch let error {
            NSLog(self.TAG +  " getVolume error:" + error.localizedDescription)
            resolve(false)
        }
    }

    func setCategory(_ type: Int) -> Bool {

        let session = AVAudioSession.sharedInstance()
        if type == OutputRoute.EAR_SPEAKER {
            // ear = 1
            do {
//                try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
                try session.setCategory(.playAndRecord)
                try session.setActive(true)
                NSLog(self.TAG + " setCategory AVAudioSessionCategoryPlayAndRecord")
                return true
            } catch {
                return false
            }
        } else if type == OutputRoute.DEFAULT_SPEAKER {
            // default = 0
            do {
                if self.isRingtone {
//                    try session.setCategory(AVAudioSessionCategorySoloAmbient, with: [AVAudioSessionCategoryOptions.allowBluetooth])
                    try session.setCategory(.soloAmbient, mode: .default, options: .allowBluetooth)
                    NSLog(self.TAG + " setCategory AVAudioSessionCategoryPlayAndRecord")
                } else {
//                    try session.setCategory(AVAudioSessionCategoryPlayback, with: [AVAudioSessionCategoryOptions.allowBluetooth])
                    try session.setCategory(.playback, mode: .default, options: .allowBluetooth)
                    try session.setPreferredInput(session.preferredInput)
                    NSLog(self.TAG + " setCategory AVAudioSessionCategoryPlayAndRecord")
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

        NSLog(self.TAG + " setAudioOutputRoute")
        self.audioOutputType = type
        resolve(self.setCategory(type))
    }

    @objc func setAudioOutputType(_ type: Int, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {

        NSLog(self.TAG + " setAudioOutputType")
        self.audioOutputType = type
        resolve(true)
    }

    @objc func getCurrentAudioName(_ fullPath: Bool, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {

        NSLog(self.TAG + " getCurrentAudioName")
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

        NSLog(self.TAG + " hasWiredheadsetPlugged")
        resolve(self.getDeviceConnected() == "" ? false : true)
    }

    func getDeviceConnected() -> String {

        let currentRoute = AVAudioSession.sharedInstance().currentRoute
        if currentRoute.outputs.count > 0 {
            for description in currentRoute.outputs {
                if description.portType == .headphones {
                    NSLog(self.TAG + " getDeviceConnected headphone plugged in")
                    return description.portType.rawValue
                } else if description.portType == .bluetoothA2DP {
                    NSLog(self.TAG + " getDeviceConnected AVAudioSessionPortBluetoothA2DP connected")
                    return description.portType.rawValue
                } else if description.portType == .bluetoothHFP {
                    NSLog(self.TAG + " getDeviceConnected AVAudioSessionPortBluetoothHFP connected")
                    return description.portType.rawValue
                } else if description.portType == .bluetoothLE {
                    NSLog(self.TAG + " getDeviceConnected AVAudioSessionPortBluetoothLE connected")
                    return description.portType.rawValue
                } else {
                    NSLog(self.TAG + " getDeviceConnected nothing")
                    return ""
                }
            }
        }
        return ""
    }

    @objc dynamic private func audioRouteChangeListener(notification:NSNotification) {
        let audioRouteChangeReason = notification.userInfo![AVAudioSessionRouteChangeReasonKey] as! UInt
        switch audioRouteChangeReason {
            case AVAudioSession.RouteChangeReason.newDeviceAvailable.rawValue:
                emitEvent(eventName: Event.ON_WIREDHEADSET_PLUGGED, data: true)
            case AVAudioSession.RouteChangeReason.oldDeviceUnavailable.rawValue:
                emitEvent(eventName: Event.ON_WIREDHEADSET_PLUGGED, data: false)
            default:
                break
        }
    }

    @objc func addAppStateListener() {

        NotificationCenter.default.addObserver(
            self, selector:
            #selector(self.audioRouteChangeListener),
//            name: .AVAudioSessionRouteChange,
            name: AVAudioSession.routeChangeNotification,
            object: nil)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.appMovedToBackground),
//            name: .UIApplicationWillResignActive,
            name: UIApplication.willResignActiveNotification,
            object: nil)
    }

    @objc func appMovedToBackground() {

        NSLog(self.TAG + " appMovedToBackground")

        if self.audioPlayer != nil, self.audioPlayer.isPlaying {
            self.paused = true
            self.audioPlayer.pause()
        }
    }

    func emitEvent(eventName: String, data: Any?) -> Void {

        if self.bridge != nil, self.bridge.eventDispatcher() != nil {
            self.bridge.eventDispatcher().sendAppEvent(withName: eventName, body: data)
        } else {
            NSLog(self.TAG + " fail to emitEvent: " + eventName);
        }
    }

    @objc static func requiresMainQueueSetup() -> Bool {
        return true
    }
}
